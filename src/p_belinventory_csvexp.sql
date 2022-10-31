create or replace procedure P_BELINVENTORY_CSVEXP
(
  nCOMPANY          in number,
  nIDENT            in number,
  nPROCESS          in number
)
as
  sHEADERS          PKG_STD.tSTRING;
  sROW              PKG_STD.tLSTRING;
  cCONTENT          clob;
  dDATE             date;
  sFILENAME         PKG_STD.tSTRING;
begin
  dDATE := sysdate;

  dbms_lob.createtemporary(cCONTENT, true);

  sHEADERS := 'DocumentId;ItemName;ItemSku;UserName;FirstName;LastName;LocationName;LocationSku;' || CR;
  dbms_lob.writeappend(cCONTENT, length(sHEADERS), sHEADERS);

  for REC in 
  (
    select T.RN                                                                                                                  as DocumentId, 
           EI.RN                                                                                                                 as ObjectRn,
           N.NOMEN_NAME                                                                                                          as ItemName,
           decode(PS.RN, null, decode(EI.INVPACK, null, decode(EI.INVSUBST, null, I.BARCODE, U.BARCODE), P.BARCODE), PS.BARCODE) as ItemSku,
           FRP.AGNABBR                                                                                                           as UserName,
           FRP.AGNFIRSTNAME                                                                                                      as FirstName,
           FRP.AGNFAMILYNAME                                                                                                     as LastName,
           decode(EI.INVPACK, null, O.PLACE_NAME, OP.PLACE_NAME)                                                                 as LocationName,
           decode(EI.INVPACK, null, O.BARCODE, OP.BARCODE)                                                                       as LocationSku
      from SELECTLIST SL,
           ELINVENTORY T,
           ELINVOBJECT EI 
             inner join INVENTORY I
               inner join DICNOMNS N on N.RN = I.NOMENCLATURE
               inner join AGNLIST FRP on FRP.RN = I.EXECUTIVE
                 left join DICPLACE O on O.RN = I.OBJECT_PLACE
               on I.RN = EI.INVENTORY
               left join INVPACK P
                 left join INVPACKPOS PS on PS.PRN = P.RN
                 left join DICPLACE OP on OP.RN = P.OBJECT_PLACE
               on P.RN = EI.INVPACK
               left join INVSUBST U on U.RN = EI.INVSUBST
     where SL.IDENT = nIDENT 
       and T.RN = SL.DOCUMENT
       and T.COMPANY = nCOMPANY
       and EI.PRN = T.RN
  )
  loop 
    sROW := REC.DocumentId || ';' ||
        REC.ItemName || ';' || 
        REC.ItemSku || ';' || 
        REC.UserName || ';' || 
        REC.FirstName || ';' ||
        REC.LastName || ';' || 
        REC.LocationName || ';' || 
        REC.LocationSku || ';' ||
        CR;
    dbms_lob.writeappend(cCONTENT, length(sROW), sROW);

    update ELINVOBJECT
       set UNLOAD_DATE = dDATE
     where RN = REC.ObjectRn;
  end loop;

  sFILENAME := 'Objects.csv';

  insert into FILE_BUFFER (IDENT, FILENAME, BDATA)
  values (nPROCESS, sFILENAME, CLOB2BLOB(cCONTENT));

  dbms_lob.freetemporary(cCONTENT);
exception
  when OTHERS then
    dbms_lob.freetemporary(cCONTENT);
end;
/

show error procedure P_BELINVENTORY_CSVEXP;

grant execute on P_BELINVENTORY_CSVEXP to PUBLIC;