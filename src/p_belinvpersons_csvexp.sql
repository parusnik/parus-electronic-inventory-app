create or replace procedure p_belinvpersons_csvexp
(
  ncompany      in number,
  nident        in number
)
as
  l_headers     pkg_std.tstring;
  l_row         pkg_std.tlstring;
  l_content     clob;
  l_filename    pkg_std.tstring;
begin
  dbms_lob.createtemporary(l_content, true);

  l_headers := 'UserName;FirstName;LastName;Password;' || cr;
  dbms_lob.writeappend(l_content, length(l_headers), l_headers);

  for rec in 
  (
    select convert(a.agnabbr, 'UTF8', 'CL8MSWIN1251')        as UserName,
           convert(a.agnfirstname, 'UTF8', 'CL8MSWIN1251')   as FirstName,
           convert(a.agnfamilyname, 'UTF8', 'CL8MSWIN1251')  as LastName,
           convert(t.password, 'UTF8', 'CL8MSWIN1251')       as Password
      from invpersons t,
           agnlist a,
           selectlist sl
     where sl.ident = nident
       and sl.unitcode = 'InventoryPersons'
       and t.rn = sl.document
       and t.company = ncompany
       and a.rn = t.agnlist
  ) 
  loop
    l_row := rec.UserName || ';' || rec.FirstName || ';' || rec.LastName || ';' || rec.Password || ';' || cr;
    dbms_lob.writeappend(l_content, length(l_row), l_row);
  end loop;

  l_filename := 'Persons.csv';

  insert into file_buffer (ident, authid, filename, data)
  values (nident, utilizer, l_filename, l_content);

  dbms_lob.freetemporary(l_content);
exception
  when others then
    dbms_lob.freetemporary(l_content);
end;
/

show errors procedure p_belinvpersons_csvexp;

grant execute on p_belinvpersons_csvexp to public;