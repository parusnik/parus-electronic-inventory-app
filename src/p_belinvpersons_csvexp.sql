create or replace procedure P_BELINVPERSONS_CSVEXP
(
  nCOMPANY          in number,
  nIDENT            in number,
  nPROCESS          in number
)
as
  sHEADERS          PKG_STD.tSTRING;
  sROW              PKG_STD.tLSTRING;
  cCONTENT          clob;
  sFILENAME         PKG_STD.tSTRING;
begin
  dbms_lob.createtemporary(cCONTENT, true);

  sHEADERS := 'UserName;FirstName;LastName;Password;' || CR;
  dbms_lob.writeappend(cCONTENT, length(sHEADERS), sHEADERS);

  for REC in 
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
    sROW := REC.UserName || ';' || REC.FirstName || ';' || REC.LastName || ';' || REC.Password || ';' || CR;
    dbms_lob.writeappend(cCONTENT, length(sROW), sROW);
  end loop;

  sFILENAME := 'Persons.csv';

  insert into FILE_BUFFER (IDENT, FILENAME, DATA)
  values (nPROCESS, sFILENAME, cCONTENT);

  dbms_lob.freetemporary(cCONTENT);
exception
  when OTHERS then
    dbms_lob.freetemporary(cCONTENT);
end;
/

show errors procedure P_BELINVPERSONS_CSVEXP;

grant execute on P_BELINVPERSONS_CSVEXP to PUBLIC;