create or replace procedure p_belinventory_csvimp
(
  ncompany          in number,
  nident            in number
)
as
  l_elinvobject     elinvobject%rowtype;
  l_invperson_rn    pkg_std.tstring;
  l_company         companies.name%type;
  l_rn              pkg_std.tref;

  function get_elinvobject(ncompany in number, ndocument in number, sbarcode in varchar2) return elinvobject%rowtype
  as
    l_result    elinvobject%rowtype;
    l_tmp       pkg_std.tref;
  begin
    /* считывание записи */
    begin
      select t.*
        into l_result
        from elinvobject t
               left join invpack p 
                 left join invpackpos ps on ps.prn = p.rn
               on p.rn = t.invpack
               left join invsubst u on u.rn = t.invsubst,
             inventory i
       where t.company = ncompany
         and t.prn = ndocument
         and t.inventory = i.rn
         and decode(ps.rn, null, decode(t.invpack, null, decode(t.invsubst, null, i.barcode, u.barcode), p.barcode), ps.barcode) = sbarcode;
    exception
      when others then
        pkg_state.diagnostics_stacked;
        p_exception(0, 'Ошибка определения записи электронной инвентаризации "%s".', pkg_state.sql_errt(pkg_state.sql_code(), pkg_state.sql_errm()));
    end;

    /* возврат результата */
    return l_result;
  end;
begin
  l_company := get_company_name(0, ncompany);

  for file in 
  (
    select data from file_buffer where ident = nident
  ) 
  loop
    for rec in 
    (
      select to_number(regexp_replace(t.column1,'[^[[:digit:]]]*')) as DocumentId,
             convert(t.column2, 'CL8MSWIN1251', 'UTF8')             as ItemName,
             convert(t.column3, 'CL8MSWIN1251', 'UTF8')             as ItemSku,
             convert(t.column4, 'CL8MSWIN1251', 'UTF8')             as InventoringPerson,
             convert(t.column5, 'CL8MSWIN1251', 'UTF8')             as ActualLocationSku,
             convert(t.column6, 'CL8MSWIN1251', 'UTF8')             as DateTimeOfInventory
        from table(lob2table.separatedColumns(file.data, chr(13), ';')) t
       where regexp_replace(t.column1,'[^[[:digit:]]]*') != 'DocumentId' or t.column1 != null
    )
    loop
      if (rec.DocumentId is not null) then
        l_elinvobject := get_elinvobject(ncompany, rec.DocumentId, rec.ItemSku);

        find_invpersons_code(1, 1, ncompany, rec.InventoringPerson, l_invperson_rn);

        if (l_invperson_rn is null) then
          p_msgjournal_base_insert(nident, 1, 'Инвентаризирующее лицо "' || rec.InventoringPerson || '" не найдено в организации "' || l_company || '".', l_rn);
        end if;

        p_elinvobject_base_update
        (
          ncompany      => ncompany,
          nrn           => l_elinvobject.rn,
          dunload_date  => l_elinvobject.unload_date,
          dinv_date     => to_date(rec.DateTimeOfInventory, 'yyyymmdd hh24miss'),
          ninvpersons   => l_invperson_rn,
          sbarcode      => rec.ActualLocationSku,
          nis_loaded    => 0
        );
      end if;
    end loop;
  end loop;
end;
/

show errors procedure p_belinventory_csvimp;

grant execute on p_belinventory_csvimp to public;