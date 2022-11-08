create or replace procedure P_BELINVENTORY_BARCODE_2022
(
    nIDENT                  in number,      -- идентификатор отмеченных записей
    nONLY_PLACE             in number
                                default 0   -- формировать только местонахождения
)
as
    SHEET                   constant PKG_STD.tSTRING := 'BARCODE';          -- лист

    LINE1                   constant PKG_STD.tSTRING := 'LINE1';            -- линия 1
    L1_DOC                  constant PKG_STD.tSTRING := 'L1_DOC';           -- документ
    L1_JURPERS              constant PKG_STD.tSTRING := 'L1_JURPERS';       -- принадлежность

    LINE2                   constant PKG_STD.tSTRING := 'LINE2';            -- линия 2
    L2_PLACE                constant PKG_STD.tSTRING := 'L2_PLACE';         -- местонахождение
    L2_PLACE_CODE           constant PKG_STD.tSTRING := 'L2_PLACE_CODE';    -- местонахождение (код)
    L2_PLACE_SKU            constant PKG_STD.tSTRING := 'L2_PLACE_SKU';     -- местонахождение (sku)

    LINE3                   constant PKG_STD.tSTRING := 'LINE3';            -- линия 3
    L3_NAME1                constant PKG_STD.tSTRING := 'L3_NAME1';         -- наименование 1
    L3_NAME2                constant PKG_STD.tSTRING := 'L3_NAME2';         -- наименование 2
    L3_NAME3                constant PKG_STD.tSTRING := 'L3_NAME3';         -- наименование 3
    L3_CODE1                constant PKG_STD.tSTRING := 'L3_CODE1';         -- штрих-код 1
    L3_CODE2                constant PKG_STD.tSTRING := 'L3_CODE2';         -- штрих-код 2
    L3_CODE3                constant PKG_STD.tSTRING := 'L3_CODE3';         -- штрих-код 3
    L3_SKU1                 constant PKG_STD.tSTRING := 'L3_SKU1';          -- штрих-код 1 (sku)
    L3_SKU2                 constant PKG_STD.tSTRING := 'L3_SKU2';          -- штрих-код 2 (sku)
    L3_SKU3                 constant PKG_STD.tSTRING := 'L3_SKU3';          -- штрих-код 3 (sku)

    iLINE_IDX1              integer;
    iLINE_IDX2              integer;
    iLINE_IDX3              integer;
    iCOL                    integer;

    sLINE                   PKG_STD.tSTRING := null;
begin
    /* пролог */    
    PRSG_EXCEL.PREPARE;

    /* установка текущего рабочего листа */
    PRSG_EXCEL.SHEET_SELECT(SHEET);

    /* описание */
    PRSG_EXCEL.LINE_DESCRIBE(LINE1);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, L1_DOC);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, L1_JURPERS);

    PRSG_EXCEL.LINE_DESCRIBE(LINE2);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE2, L2_PLACE);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE2, L2_PLACE_CODE);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE2, L2_PLACE_SKU);

    PRSG_EXCEL.LINE_DESCRIBE(LINE3);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE3, L3_NAME1);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE3, L3_NAME2);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE3, L3_NAME3);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE3, L3_CODE1);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE3, L3_CODE2);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE3, L3_CODE3);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE3, L3_SKU1);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE3, L3_SKU2);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE3, L3_SKU3);

    /* формирование данных для печати */
    for rec in
    (
        select T.RN,
               D.DOCCODE,
               T.DOC_PREF,
               T.DOC_NUMB,
               T.DOC_DATE,
               J.CODE
          from SELECTLIST S,
               ELINVENTORY T,
               JURPERSONS J,
               DOCTYPES D
         where S.IDENT = nIDENT
           and T.RN = S.DOCUMENT
           and T.JUR_PERS = J.RN
           and T.DOC_TYPE = D.RN
         order by J.CODE, D.DOCCODE, T.DOC_PREF, T.DOC_NUMB, T.DOC_DATE
    )
    loop
        if (sLINE is null) then
            iLINE_IDX1 := PRSG_EXCEL.LINE_APPEND(LINE1);
        else
            iLINE_IDX1 := PRSG_EXCEL.LINE_APPEND(LINE1, sLINE);
        end if;

        if (iLINE_IDX1 > 1) then
            PRSG_EXCEL.LINE_PAGE_BREAK;
        end if;

        PRSG_EXCEL.CELL_VALUE_WRITE(L1_DOC, 0, iLINE_IDX1, trim(rec.DOCCODE) || ' ' || trim(rec.DOC_PREF) || '-' || trim(rec.DOC_NUMB) || ' ' || to_char(rec.DOC_DATE, 'DD.MM.YYYY'));
        PRSG_EXCEL.CELL_VALUE_WRITE(L1_JURPERS, 0, iLINE_IDX1, rec.CODE);

        sLINE := LINE1;

        for obj in
        (
            select OBJ.OBJECT_PLACE, OBJ.BARCODE
              from (select distinct
                           decode(T.INVPACK, null, O.PLACE_MNEMO, OP.PLACE_MNEMO)   as OBJECT_PLACE,
                           decode(T.INVPACK, null, O.BARCODE, OP.BARCODE)           as BARCODE
                      from ELINVOBJECT T
                            inner join INVENTORY I on I.RN = T.INVENTORY
                            left join DICPLACE O on O.RN = I.OBJECT_PLACE
                            left join INVPACK P on P.RN = T.INVPACK
                            left join DICPLACE OP on OP.RN = P.OBJECT_PLACE
                     where T.PRN = rec.RN) OBJ
             order by OBJ.OBJECT_PLACE
        )
        loop
            if (sLINE = LINE2) then
                iLINE_IDX2 := PRSG_EXCEL.LINE_APPEND(LINE2);
            else
                iLINE_IDX2 := PRSG_EXCEL.LINE_APPEND(LINE2, sLINE);
            end if;

            PRSG_EXCEL.CELL_VALUE_WRITE(L2_PLACE, 0, iLINE_IDX2, obj.OBJECT_PLACE);
            PRSG_EXCEL.CELL_VALUE_WRITE(L2_PLACE_CODE, 0, iLINE_IDX2, obj.BARCODE);
            PRSG_EXCEL.CELL_VALUE_WRITE(L2_PLACE_SKU, 0, iLINE_IDX2, PKG_BARCODE.ENCODE128(obj.BARCODE));

            sLINE := LINE2;

            iCOL := 1;

            if (nONLY_PLACE = 0) then
                for spec in
                (
                    select distinct
                           NL.NOMEN_CODE                                                                                                        as NOMEN_CODE,
                           decode(T.INVPACK, null, I.INV_NUMBER, P.INV_NUMBER)                                                                  as INV_NUMBER,
                           decode(PS.RN, null, decode(T.INVPACK, null, decode(T.INVSUBST, null, I.BARCODE, U.BARCODE), P.BARCODE), PS.BARCODE)  as SKU,
                           J.CODE                                                                                                               as JUR_PERS
                      from ELINVOBJECT T
                            inner join INVENTORY I on I.RN = T.INVENTORY
                            left join DICPLACE O on O.RN = I.OBJECT_PLACE
                            left join INVPACK P on P.RN = T.INVPACK
                            left join DICPLACE OP on OP.RN = P.OBJECT_PLACE
                            inner join DICNOMNS NL on NL.RN = I.NOMENCLATURE
                            inner join JURPERSONS J on J.RN = I.JUR_PERS
                            left join INVPACKPOS PS on PS.PRN = T.INVPACK and PS.INVSUBST = T.INVSUBST
                            left join INVSUBST U on U.RN = T.INVSUBST
                     where T.PRN = rec.RN
                       and cmp_vc2(decode(T.INVPACK, null, O.BARCODE, OP.BARCODE), OBJ.BARCODE) = 1
                       and cmp_vc2(decode(T.INVPACK, null, O.PLACE_MNEMO, OP.PLACE_MNEMO), OBJ.OBJECT_PLACE) = 1
                     order by NL.NOMEN_CODE
                )
                loop
                    if (iCOL = 1) then
                        if (sLINE = LINE3) then
                            iLINE_IDX3 := PRSG_EXCEL.LINE_APPEND(LINE3);
                        else
                            iLINE_IDX3 := PRSG_EXCEL.LINE_APPEND(LINE3, sLINE);
                        end if;
                    end if;

                    PRSG_EXCEL.CELL_VALUE_WRITE(L3_NAME1, 0, iLINE_IDX3, trim(spec.NOMEN_CODE));
                    PRSG_EXCEL.CELL_VALUE_WRITE(L3_CODE1, 0, iLINE_IDX3, spec.SKU);
                    PRSG_EXCEL.CELL_VALUE_WRITE(L3_SKU1, 0, iLINE_IDX3, PKG_BARCODE.ENCODE128(spec.SKU));

                    iCOL := PKG_EXT.IIF(iCOL <> 3, iCOL + 1, 1);

                    sLINE := LINE3;
                end loop; 
            end if;
        end loop;
    end loop;

    PRSG_EXCEL.LINE_DELETE(LINE1, 0);
    PRSG_EXCEL.LINE_DELETE(LINE2, 0);
    PRSG_EXCEL.LINE_DELETE(LINE3, 0);
end;
/

show errors procedure P_BELINVENTORY_BARCODE_2022;

grant execute on P_BELINVENTORY_BARCODE_2022 to PUBLIC;