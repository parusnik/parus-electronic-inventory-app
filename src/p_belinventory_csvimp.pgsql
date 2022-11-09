CREATE OR REPLACE FUNCTION p_belinventory_csvimp(
    ncompany        numeric,
    nident          numeric
)
RETURNS void AS $$
DECLARE
    relinvobject    elinvobject;
    scompany_name   character varying(160);
    ninvpersons     numeric(17);
    nrn             numeric(17);
    file            record;
    line            record;
BEGIN
    scompany_name := get_company_name(0::numeric, ncompany);

    FOR file IN
        SELECT parus.blob2clob(bdata, pkg_charset$charset_win_()) AS "DATA" FROM file_buffer WHERE ident = nident
    LOOP
        FOR line IN
            SELECT regexp_replace(t.c[1], '[^[[:digit:]]]*')::numeric   AS documentid,
                   t.c[2]::character varying                            AS itemname,
                   t.c[3]::character varying                            AS itemsku,
                   t.c[4]::character varying                            AS inventoringperson,
                   t.c[5]::character varying                            AS actuallocationsku,
                   t.c[6]::character varying                            AS datetimeofinventory
              FROM (SELECT regexp_split_to_array(l, ';') AS c
                      FROM regexp_split_to_table(file."DATA", '\n') AS l) AS t
        LOOP
            IF (line.documentid IS NOT NULL) THEN
                -- Считывание записи
                BEGIN
                    SELECT t.*
                      INTO relinvobject
                      FROM elinvobject t
                            LEFT JOIN invpack p ON p.rn = t.invpack
                            LEFT JOIN invpackpos ps ON ps.prn = p.rn
                            LEFT JOIN invsubst u ON u.rn = t.invsubst
                            INNER JOIN inventory i ON i.rn = t.inventory
                     WHERE t.company = ncompany
                       AND t.prn = line.documentid
                       AND (CASE WHEN ps.rn IS NULL THEN 
                                CASE WHEN t.invpack IS NULL THEN 
                                    CASE WHEN t.invsubst IS NULL THEN i.barcode ELSE u.barcode END 
                                ELSE p.barcode 
                                END 
                            ELSE ps.barcode 
                            END = line.itemsku);
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE EXCEPTION 'Ошибка определения записи электронной инвентаризации.';
                END;

                ninvpersons := find_invpersons_code(1::numeric, 1::numeric, ncompany, line.inventoringperson);

                IF (ninvpersons IS NULL) THEN
                    nrn := p_msgjournal_base_insert(nident, 1::numeric, format('Инвентаризирующее лицо "%" не найдено в организации "%".', line.inventoringperson, scompany_name));
                END IF;

                PERFORM p_elinvobject_base_update(ncompany, relinvobject.rn, relinvobject.unload_date, to_date(line.datetimeofinventory, 'yyyymmdd hh24miss'::character varying),
                    ninvpersons, pkg_ext$iif(line.actuallocationsku = '', null, line.actuallocationsku), 0::numeric, null);
            END IF;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
