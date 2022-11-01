create or replace package body PKG_BARCODE$PG
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

    function TABLE_A return varchar2 as begin return 'A'; end;
    function TABLE_B return varchar2 as begin return 'B'; end;
    function TABLE_C return varchar2 as begin return 'C'; end;

    function C194 return varchar2 as begin return CHR(194); end;
    function C195 return varchar2 as begin return CHR(195); end;
    function C196 return varchar2 as begin return CHR(196); end;
    function C197 return varchar2 as begin return CHR(197); end;
    function C198 return varchar2 as begin return CHR(198); end;
    function C199 return varchar2 as begin return CHR(199); end;
    function C200 return varchar2 as begin return CHR(200); end;
    function C201 return varchar2 as begin return CHR(201); end;
    function C202 return varchar2 as begin return CHR(202); end;
    function C203 return varchar2 as begin return CHR(203); end;
    function C204 return varchar2 as begin return CHR(204); end;
    function C205 return varchar2 as begin return CHR(205); end;
    function C206 return varchar2 as begin return CHR(206); end;

    /* Общая кодовая таблица Code 128 (Libre Barcode 128 Text) */
    function CODE128_TABLE 
    return varchar2
    as
    begin
        return C194 || '!"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~' ||
            C195 || C196 || C197 || C198 || C199 || C200 || C201 || C202 || C203 || C204 || C205 || C206;
    end;

    /* Кодовая таблица символовм Code 128B */
    function CODE128B
    return varchar2
    as
    begin
        return ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
    end;

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

show errors package body PKG_BARCODE$PG;
