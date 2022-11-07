create or replace procedure P_BELINVPERSONS_CSVEXP
(
    nCOMPANY                in number,
    nIDENT                  in number,
    nPROCESS                in number
)
as
    sFILENAME               PKG_STD.tSTRING;
begin
    sFILENAME := 'Persons.csv';

    PKG_CLOB.PROLOGUE('P_BELINVPERSONS_CSVEXP', 'cINVPERS');
    PKG_CLOB.WRITE('P_BELINVPERSONS_CSVEXP', 'cINVPERS', 'UserName;FirstName;LastName;Password;;' || CR);

    for rec in 
    (
        select A.AGNABBR        as UserName,
               A.AGNFIRSTNAME   as FirstName,
               A.AGNFAMILYNAME  as LastName,
               T.PASSWORD       as Password
          from INVPERSONS T,
               AGNLIST A,
               SELECTLIST SL
         where SL.IDENT = nIDENT
           and SL.UNITCODE = 'InventoryPersons'
           and T.RN = SL.DOCUMENT
           and T.COMPANY = nCOMPANY
           and A.RN = T.AGNLIST
    ) 
    loop
        PKG_CLOB.WRITE('P_BELINVPERSONS_CSVEXP', 'cINVPERS', rec.UserName || ';' || rec.FirstName || ';' || rec.LastName || ';' || rec.Password || ';' || CR);
    end loop;


    insert into FILE_BUFFER (IDENT, FILENAME, BDATA)
        values (nPROCESS, sFILENAME, PKG_CLOB.SERIALIZE_TO_BLOB('P_BELINVPERSONS_CSVEXP', 'cINVPERS', PKG_CHARSET.CHARSET_UTF_));

exception
    when OTHERS then
        PKG_CLOB.EPILOGUE('P_BELINVPERSONS_CSVEXP');
end;
/

show errors procedure P_BELINVPERSONS_CSVEXP;

grant execute on P_BELINVPERSONS_CSVEXP to PUBLIC;