create or replace package body PKG_BARCODE
as
    /**
     * The MIT License (MIT)
     *
     * Copyright (c) 2022 Parusnik
     *
     * All rights reserved.
     *
     * Permission is hereby granted, free of charge, to any person obtaining a copy
     * of this software and associated documentation files (the "Software"), to deal
     * in the Software without restriction, including without limitation the rights
     * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     * copies of the Software, and to permit persons to whom the Software is
     * furnished to do so, subject to the following conditions:
     *
     * The above copyright notice and this permission notice shall be included in all
     * copies or substantial portions of the Software.
     *
     * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
     * SOFTWARE.
     */

    TABLE_A         constant PKG_STD.tSTRING := 'A';
    TABLE_B         constant PKG_STD.tSTRING := 'B';
    TABLE_C         constant PKG_STD.tSTRING := 'C';

    C194            constant PKG_STD.tSTRING := CHR(194);
    C195            constant PKG_STD.tSTRING := CHR(195);
    C196            constant PKG_STD.tSTRING := CHR(196);
    C197            constant PKG_STD.tSTRING := CHR(197);
    C198            constant PKG_STD.tSTRING := CHR(198);
    C199            constant PKG_STD.tSTRING := CHR(199);
    C200            constant PKG_STD.tSTRING := CHR(200);
    C201            constant PKG_STD.tSTRING := CHR(201);
    C202            constant PKG_STD.tSTRING := CHR(202);
    C203            constant PKG_STD.tSTRING := CHR(203);
    C204            constant PKG_STD.tSTRING := CHR(204);
    C205            constant PKG_STD.tSTRING := CHR(205);
    C206            constant PKG_STD.tSTRING := CHR(206);

    /* Общая кодовая таблица Code 128 (Libre Barcode 128 Text) */
    CODE128_TABLE   constant PKG_STD.tSTRING := C194 || '!"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~' ||
        C195 || C196 || C197 || C198 || C199 || C200 || C201 || C202 || C203 || C204 || C205 || C206;

    /* Кодовая таблица символовм Code 128B */
    CODE128B        constant PKG_STD.tSTRING := ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

    /* Преобразование строки в кодировку Code 128 */
    function ENCODE128(sVALUE in varchar2) 
    return varchar2
    as
        nSUM            PKG_STD.tNUMBER;
        nINDEX          PKG_STD.tNUMBER := 1;
        nPOSITION       PKG_STD.tNUMBER;
        sTEMP           PKG_STD.tSTRING;
        sRESULT         PKG_STD.tSTRING;
        sENCODING_PART  PKG_STD.tSTRING;
        sENCODE_SYMB    PKG_STD.tSTRING;
        sCODE_SYMB      PKG_STD.tSTRING;
        sCURRENT_TABLE  PKG_STD.tSTRING;
        nSTART_CUT      PKG_STD.tNUMBER;
        nEND_CUT        PKG_STD.tNUMBER;
    begin
        if (rtrim(sVALUE) is null or length(sVALUE) < 2) then
            p_exception(0, 'Входящая строка должна состоять из 2х или более символов.');
        end if;

        sTEMP := sVALUE;

        nSTART_CUT := regexp_instr(sTEMP, '[[:digit:]]{4,}');

        /* начальная кодовая таблица */
        if (nSTART_CUT = 1) then
            nSUM := 105;
            sRESULT := C205;
            sCURRENT_TABLE := TABLE_C;
        else
            nSUM := 104;
            sRESULT := C204;
            sCURRENT_TABLE := TABLE_B;
        end if;

        while (sTEMP is not null and length(sTEMP) > 0)
        loop
            if (nSTART_CUT = 1) then
                /* переключение с кодовой таблицы B на C */
                if (sCURRENT_TABLE = TABLE_B) then
                    sCURRENT_TABLE := TABLE_C;
                    sRESULT := sRESULT || C199;
                    nSUM := nSUM + nINDEX * 99;
                    nINDEX := nINDEX + 1;
                end if;

                /* получение строки с четным количеством символов */
                sENCODING_PART := regexp_substr(sTEMP, '[[:digit:]]{4,}');
                nEND_CUT := length(sENCODING_PART);
                nEND_CUT := nEND_CUT - mod(nEND_CUT, 2);
                sENCODING_PART := substr(sTEMP, 1, nEND_CUT);

                /* кодирование по таблице С */
                while (sENCODING_PART is not null and length(sENCODING_PART) > 0)
                loop
                    sENCODE_SYMB := substr(sENCODING_PART, 1, 2);
                    nPOSITION := to_number(sENCODE_SYMB) + 1;
                    nSUM := nSUM + nINDEX * (nPOSITION - 1);
                    sRESULT := sRESULT || substr(CODE128_TABLE, nPOSITION, 1);
                    sENCODING_PART := substr(sENCODING_PART, 3);
                    nINDEX := nINDEX + 1;
                end loop;
            else
                /* переключение с кодовой таблицы C на B */
                if (sCURRENT_TABLE = TABLE_C) then
                    sCURRENT_TABLE := TABLE_B;
                    sRESULT := sRESULT || C200;
                    nSUM := nSUM + nINDEX * 100;
                    nINDEX := nINDEX + 1;
                end if;

                nEND_CUT := PKG_EXT.IIF(nSTART_CUT = 0, length(sTEMP), nSTART_CUT - 1);

                sENCODING_PART := substr(sTEMP, 1, nEND_CUT);

                /* кодирование по таблице B */
                while (sENCODING_PART is not null and length(sENCODING_PART) > 0)
                loop
                    sENCODE_SYMB := substr(sENCODING_PART, 1, 1);
                    nPOSITION := instr(CODE128B, sENCODE_SYMB);
                    if (nPOSITION = 0) then
                        p_exception(0, 'Входящая строка содержит некорректный символ: позиция %s - %s', nPOSITION, sENCODE_SYMB);
                    end if;

                    nSUM := nSUM + nINDEX * (nPOSITION - 1);
                    sRESULT := sRESULT || substr(CODE128_TABLE, nPOSITION, 1);
                    sENCODING_PART := substr(sENCODING_PART, 2);
                    nINDEX := nINDEX + 1;
                end loop;
            end if;

            sTEMP := substr(sTEMP, nEND_CUT + 1);
            nSTART_CUT := regexp_instr(sTEMP, '[[:digit:]]{4,}');
        end loop;

        nPOSITION := mod(nSUM, 103) + 1;
        sRESULT := sRESULT || substr(CODE128_TABLE, nPOSITION, 1) || C206;

        return sRESULT;
    end;
end;
/

show errors package body PKG_BARCODE;
