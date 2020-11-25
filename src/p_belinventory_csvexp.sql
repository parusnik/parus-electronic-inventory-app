create or replace procedure p_belinventory_csvexp
(
  ncompany      in number,
  nident        in number
)
as
  l_headers     pkg_std.tstring;
  l_row         pkg_std.tlstring;
  l_content     clob;
  l_date        date;
  l_filename    pkg_std.tstring;
begin
  l_date := sysdate;

  dbms_lob.createtemporary(l_content, true);

  l_headers := 'DocumentId;ItemName;ItemSku;UserName;FirstName;LastName;LocationName;LocationSku;' || cr;
  dbms_lob.writeappend(l_content, length(l_headers), l_headers);

  for rec in 
  (
    select t.rn                                                                                                                  as DocumentId, 
           ei.rn                                                                                                                 as ObjectRn,
           n.nomen_name                                                                                                          as ItemName,
           decode(ps.rn, null, decode(ei.invpack, null, decode(ei.invsubst, null, i.barcode, u.barcode), p.barcode), ps.barcode) as ItemSku,
           frp.agnabbr                                                                                                           as UserName,
           frp.agnfirstname                                                                                                      as FirstName,
           frp.agnfamilyname                                                                                                     as LastName,
           decode(ei.invpack, null, o.place_mnemo, op.place_mnemo)                                                               as LocationName,
           decode(ei.invpack, null, o.barcode, op.barcode)                                                                       as LocationSku
      from selectlist sl,
           elinventory t,
           elinvobject ei 
             inner join inventory i
               inner join dicnomns n on n.rn = i.nomenclature
               inner join agnlist frp on frp.rn = i.executive
                 left join dicplace o on o.rn = i.object_place
               on i.rn = ei.inventory
               left join invpack p
                 left join invpackpos ps on ps.prn = p.rn
                 left join dicplace op on op.rn = p.object_place
               on p.rn = ei.invpack
               left join invsubst u on u.rn = ei.invsubst
     where sl.ident = nident 
       and t.rn = sl.document
       and t.company = ncompany
       and ei.prn = t.rn
  )
  loop 
    l_row := rec.DocumentId || ';' ||
        convert(rec.ItemName, 'UTF8', 'CL8MSWIN1251') || ';' || 
        convert(rec.ItemSku, 'UTF8', 'CL8MSWIN1251') || ';' || 
        convert(rec.UserName, 'UTF8', 'CL8MSWIN1251') || ';' || 
        convert(rec.FirstName, 'UTF8', 'CL8MSWIN1251') || ';' ||
        convert(rec.LastName, 'UTF8', 'CL8MSWIN1251') || ';' || 
        convert(rec.LocationName, 'UTF8', 'CL8MSWIN1251') || ';' || 
        convert(rec.LocationSku, 'UTF8', 'CL8MSWIN1251') || ';' ||
        cr;
    dbms_lob.writeappend(l_content, length(l_row), l_row);

    update elinvobject
       set unload_date = l_date
     where rn = rec.ObjectRn;
  end loop;

  l_filename := 'Objects.csv';

  insert into file_buffer (ident, authid, filename, data)
  values (nident, utilizer, l_filename, l_content);

  dbms_lob.freetemporary(l_content);
exception
  when others then
    dbms_lob.freetemporary(l_content);
end;
/

show error procedure p_belinventory_csvexp;

grant execute on p_belinventory_csvexp to public;