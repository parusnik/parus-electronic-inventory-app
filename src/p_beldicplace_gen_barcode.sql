create or replace procedure p_beldicplace_gen_barcode
(
  ncompany      in number,
  nident        in number,
  sunitcode     in varchar2
)
as
  l_barcode     dicplace.barcode%type;
begin
  if (sunitcode != 'ObjPlace') then
    p_exception(0, 'Данная процедура предназначена для раздела "Местонахождение инвентарных объектов".');
  end if;

  for rec in 
  (
    select t.rn
      from selectlist sl, dicplace t
     where sl.ident = nident
       and sl.company = ncompany
       and sl.unitcode = sunitcode
       and t.rn = sl.document
       and t.barcode is null
  ) 
  loop
    l_barcode := gen_barcode_ex;

    update dicplace
       set barcode = l_barcode
     where rn = rec.rn;
  end loop;
end;
/

show errors procedure p_beldicplace_gen_barcode;

grant execute on p_beldicplace_gen_barcode to public;