create or replace procedure P_BELDICPLACE_GEN_BARCODE
(
  nCOMPANY          in number,
  nIDENT            in number
)
as
  sBARCODE          DICPLACE.BARCODE%type;
begin
  for REC in 
  (
    select T.RN
      from SELECTLIST SL, DICPLACE T
     where SL.IDENT = nIDENT
       and SL.COMPANY = nCOMPANY
       and T.RN = SL.DOCUMENT
       and T.BARCODE is null
  ) 
  loop
    sBARCODE := GEN_BARCODE_EX;

    update DICPLACE
       set BARCODE = sBARCODE
     where RN = REC.RN;
  end loop;
end;
/

show errors procedure P_BELDICPLACE_GEN_BARCODE;

grant execute on P_BELDICPLACE_GEN_BARCODE to PUBLIC;