create or replace procedure P_BELINVENTORY_CSVIMP
(
    nCOMPANY                in number,
    nIDENT                  in number
)
as
    rELINVOBJECT            ELINVOBJECT%rowtype;
    nINVPERSONS             PKG_STD.tSTRING;
    sCOMPANY_NAME           COMPANIES.NAME%type;
    nRN                     PKG_STD.tREF;
begin
    sCOMPANY_NAME := GET_COMPANY_NAME(0, nCOMPANY);

    for file in 
    (
        select BLOB2CLOB(BDATA, PKG_CHARSET.CHARSET_UTF_) as DATA from FILE_BUFFER where IDENT = nIDENT
    ) 
    loop
        for rec in 
        (
            select to_number(regexp_replace(T.COLUMN1,'[^[[:digit:]]]*')) as DOCUMENTID,
                   T.COLUMN2                                              as ITEMNAME,
                   T.COLUMN3                                              as ITEMSKU,
                   T.COLUMN4                                              as INVENTORINGPERSON,
                   T.COLUMN5                                              as ACTUALLOCATIONSKU,
                   T.COLUMN6                                              as DATETIMEOFINVENTORY
              from table(lob2table.separatedColumns(file.DATA, CHR(13), ';')) T
             where regexp_replace(T.COLUMN1,'[^[[:digit:]]]*') <> 'DocumentId' or T.COLUMN1 <> null
        )
        loop
            if (rec.DOCUMENTID is not null) then
                /* считывание записи */
                begin
                    select T.*
                      into rELINVOBJECT
                      from ELINVOBJECT T
                            left join INVPACK P 
                                left join INVPACKPOS PS on PS.PRN = P.RN
                            on P.RN = T.INVPACK
                            left join INVSUBST U on U.RN = T.INVSUBST,
                            INVENTORY I
                     where T.COMPANY = nCOMPANY
                       and T.PRN = rec.DOCUMENTID
                       and T.INVENTORY = I.RN
                       and decode(PS.RN, null, decode(T.INVPACK, null, decode(T.INVSUBST, null, I.BARCODE, U.BARCODE), P.BARCODE), PS.BARCODE) = rec.ITEMSKU;
                exception
                    when OTHERS then
                        PKG_STATE.DIAGNOSTICS_STACKED;
                        P_EXCEPTION(0, 'Ошибка определения записи электронной инвентаризации "%s".', PKG_STATE.SQL_ERRT(PKG_STATE.SQL_CODE(), PKG_STATE.SQL_ERRM()));
                end;

                FIND_INVPERSONS_CODE(1, 1, nCOMPANY, rec.INVENTORINGPERSON, nINVPERSONS);

                if (nINVPERSONS is null) then
                    if (rtrim(rec.INVENTORINGPERSON) is not null) then
                        P_MSGJOURNAL_BASE_INSERT(nIDENT, 1, 'Инвентаризирующее лицо "' || rec.INVENTORINGPERSON || '" не найдено в организации "' || sCOMPANY_NAME || '".', nRN);
                    end if;
                end if;

                P_ELINVOBJECT_BASE_UPDATE
                (
                    nCOMPANY      => nCOMPANY,
                    nRN           => rELINVOBJECT.rn,
                    dUNLOAD_DATE  => rELINVOBJECT.unload_date,
                    dINV_DATE     => to_date(rec.DATETIMEOFINVENTORY, 'yyyymmdd hh24miss'),
                    nINVPERSONS   => nINVPERSONS,
                    sBARCODE      => rec.ACTUALLOCATIONSKU,
                    nIS_LOADED    => 0,
                    sRFID         => null
                );
            end if;
        end loop;
    end loop;
end;
/

show errors procedure P_BELINVENTORY_CSVIMP;

grant execute on P_BELINVENTORY_CSVIMP to PUBLIC;