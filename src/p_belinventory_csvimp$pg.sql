create or replace procedure P_BELINVENTORY_CSVIMP$PG
(
  nCOMPANY          in number,
  nIDENT            in number
)
as
begin
  P_NECESSARY_RECREATE_STABLE('P_BELINVENTORY_CSVIMP');
end;
/

show errors procedure P_BELINVENTORY_CSVIMP$PG;