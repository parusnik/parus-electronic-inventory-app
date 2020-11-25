create or replace procedure p_beldicplace_csvexp
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

  l_headers := 'LocationName;LocationSku;' || cr;
  dbms_lob.writeappend(l_content, length(l_headers), l_headers);

  for rec in 
  (
    select t.place_name as LocationName,
           t.barcode    as LocationSku
      from dicplace t, 
           selectlist sl
     where sl.ident = nident
       and sl.unitcode = 'ObjPlace'
       and t.rn = sl.document
  ) 
  loop
    l_row := rec.LocationName || ';' || rec.LocationSku || ';' || cr;
    dbms_lob.writeappend(l_content, length(l_row), l_row);
  end loop;

  l_filename := 'Locations.csv';

  insert into file_buffer (ident, authid, filename, data)
  values (nident, utilizer, l_filename, l_content);

  dbms_lob.freetemporary(l_content);
exception
  when others then
    dbms_lob.freetemporary(l_content);
end;
/

show errors procedure p_beldicplace_csvexp;

grant execute on p_beldicplace_csvexp to public;