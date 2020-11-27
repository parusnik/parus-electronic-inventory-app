create or replace procedure p_beldicplace_csvexp
(
  ncompany      in number,
  nident        in number,
  sdoc_numb     in varchar2,
  sdoc_pref     in varchar2,
  sdoc_type     in varchar2
)
as
  l_headers     pkg_std.tstring;
  l_row         pkg_std.tlstring;
  l_content     clob;
  l_filename    pkg_std.tstring;
  l_doctype     pkg_std.tref;
  l_elinventory pkg_std.tref;
begin
  /* определение типа документа */
  find_doctypes_code_ex(0, 0, ncompany, sdoc_type, l_doctype);

  /* определение документа инвентаризации */
  begin
    select rn
      into l_elinventory
      from elinventory
     where company = ncompany
       and doc_numb = sdoc_numb
       and doc_pref = sdoc_pref
       and doc_type = l_doctype;
  exception
    when no_data_found then
      p_exception(0, 'Не удалось определить идентификатор для документа электронной инвентаризации "%s"', pkg_document.make_number(sdoc_type, sdoc_pref, sdoc_numb));
  end;

  dbms_lob.createtemporary(l_content, true);

  l_headers := 'DocumentId;LocationName;LocationSku;' || cr;
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
    l_row := l_elinventory || ';' || rec.LocationName || ';' || rec.LocationSku || ';' || cr;
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