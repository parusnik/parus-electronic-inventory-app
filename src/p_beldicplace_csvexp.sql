create or replace procedure P_BELDICPLACE_CSVEXP
(
  nCOMPANY          in number,
  nIDENT            in number,
  nPROCESS          in number,
  sDOC_NUMB         in varchar2,
  sDOC_PREF         in varchar2,
  sDOC_TYPE         in varchar2
)
as
  sHEADERS          PKG_STD.tSTRING;
  sROW              PKG_STD.tLSTRING;
  cCONTENT          clob;
  sFILENAME         PKG_STD.tSTRING;
  nDOCTYPE          PKG_STD.tREF;
  nELINVENTORY      PKG_STD.tREF;
begin
  /* определение типа документа */
  FIND_DOCTYPES_CODE_EX(0, 0, nCOMPANY, sDOC_TYPE, nDOCTYPE);

  /* определение документа инвентаризации */
  begin
    select RN
      into nELINVENTORY
      from ELINVENTORY
     where COMPANY = nCOMPANY
       and DOC_NUMB = trimnumb(sDOC_NUMB, 10)
       and DOC_PREF = trimnumb(sDOC_PREF, 10)
       and DOC_TYPE = nDOCTYPE;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Не удалось определить идентификатор для документа электронной инвентаризации "%s"', PKG_DOCUMENT.MAKE_NUMBER(sDOC_TYPE, sDOC_PREF, sDOC_NUMB));
  end;

  DBMS_LOB.CREATETEMPORARY(cCONTENT, true);

  sHEADERS := 'DocumentId;LocationName;LocationSku;' || CR;
  dbms_lob.writeappend(cCONTENT, length(sHEADERS), sHEADERS);

  for REC in 
  (
    select T.PLACE_NAME as LocationName,
           T.BARCODE    as LocationSku
      from DICPLACE T, 
           SELECTLIST SL
     where SL.IDENT = nIDENT
       and SL.UNITCODE = 'ObjPlace'
       and T.RN = SL.DOCUMENT
  ) 
  loop
    sROW := nELINVENTORY || ';' || REC.LocationName || ';' || REC.LocationSku || ';' || CR;
    dbms_lob.writeappend(cCONTENT, length(sROW), sROW);
  end loop;

  sFILENAME := 'Locations.csv';

  insert into FILE_BUFFER (IDENT, FILENAME, BDATA)
  values (nPROCESS, sFILENAME, CLOB2BLOB(cCONTENT));

  dbms_lob.freetemporary(cCONTENT);
exception
  when OTHERS then
    dbms_lob.freetemporary(cCONTENT);
end;
/

show errors procedure P_BELDICPLACE_CSVEXP;

grant execute on P_BELDICPLACE_CSVEXP to PUBLIC;