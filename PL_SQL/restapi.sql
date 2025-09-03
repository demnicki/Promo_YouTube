/*
Projekt „Tutorial edukacyjny”. Webservis do obsługi wiadomości od klientów.
*/
DECLARE
    CURSOR sb IS SELECT id, typ, odc FROM yt_k_subs;
    CURSOR wiad IS SELECT id, data_wyslania, tresc FROM yt_k_wiad;
    obj_json   JSON_OBJECT_T;
    tab_sb     JSON_ARRAY_T;
    tab_wiad   JSON_ARRAY_T;
    obj_sb     JSON_OBJECT_T;
    obj_wiad   JSON_OBJECT_T;
    suma_uzytk NUMBER(6);
    suma_subs  NUMBER(9);
BEGIN
    obj_json := json_object_t();
    tab_sb := json_array_t();
    tab_wiad := json_array_t();
    SELECT count(id) INTO suma_uzytk FROM yt_k_uzytkownicy;
    SELECT count(id) INTO suma_subs FROM yt_k_subs;
    FOR i IN sb LOOP
        obj_sb := json_object_t();
        obj_sb.put('id', i.id);
        obj_sb.put('typ', i.typ);
        obj_sb.put('odc', i.odc);
        tab_sb.append(obj_sb);
    END LOOP;
    FOR j IN wiad LOOP
        obj_wiad := json_object_t();
        obj_wiad.put('id', j.id);
        obj_wiad.put('data_wyslania', to_char(j.data_wyslania, 'SS:MI:HH24 DD-MON-YYYY'));
        obj_wiad.put('tresc', j.tresc);
        tab_wiad.append(obj_wiad);
    END LOOP;
    obj_json.put('suma_uzytk', suma_uzytk);
    obj_json.put('suma_subs', suma_subs);
    obj_json.put('tab_sb', tab_sb);
    obj_json.put('tab_wiad',tab_wiad );
    owa_util.mime_header('application/json', true, 'UTF-8');
    htp.p(obj_json.stringify);
END;

/*
Projekt „Kuchenne rewolucje”. Webservisy do obsługi hurtowni JSON, z odcinkami rewolucji.

Metoda GET. Pobranie całej tabeli.
*/
DECLARE
    CURSOR lista IS SELECT * FROM kr_t_odcinki;
    suma_wsz        NUMBER(3);
    suma_przer      NUMBER(3);
    suma_nieudanych NUMBER(3);
    suma_udanych    NUMBER(3);
    caly_json       JSON_OBJECT_T;
    wiersz_json     JSON_OBJECT_T;    
    tab_lista       JSON_ARRAY_T;
BEGIN
    SELECT count(id) INTO suma_wsz FROM kr_t_odcinki;
    SELECT count(id) INTO suma_przer FROM kr_t_odcinki WHERE kategoria = 0;
    SELECT count(id) INTO suma_nieudanych FROM kr_t_odcinki WHERE kategoria = 1;
    SELECT count(id) INTO suma_udanych FROM kr_t_odcinki WHERE kategoria = 2;
    caly_json := json_object_t();
    tab_lista := json_array_t();
    FOR i IN lista LOOP
        wiersz_json := json_object_t();
        wiersz_json.put('id', i.id);
        wiersz_json.put('kat', i.kategoria);
        wiersz_json.put('wojew', i.wojewodztwo);
        wiersz_json.put('sezon', i.sezon);
        wiersz_json.put('odc', i.odcinek);
        wiersz_json.put('geo_szer', i.lokacja.sdo_point.y);
        wiersz_json.put('geo_dlug', i.lokacja.sdo_point.x);
        wiersz_json.put('rest', i.nazwa_rest);
        wiersz_json.put('opis', i.opis);
        tab_lista.append(wiersz_json);
    END LOOP;
    caly_json.put('suma_wsz', suma_wsz);
    caly_json.put('suma_przer', suma_przer);
    caly_json.put('suma_nieudanych', suma_nieudanych);
    caly_json.put('suma_udanych', suma_udanych);
    caly_json.put('lista', tab_lista);
    owa_util.mime_header('application/json', true, 'UTF-8');
    htp.p(caly_json.stringify);
EXCEPTION
    WHEN others THEN
    caly_json := json_object_t();
    caly_json.put('error', 'Nierozpoznany błąd bazy danych');
    owa_util.mime_header('application/json', true, 'UTF-8');
    htp.p(caly_json.stringify);
END;

/*
Metoda POST. Wstawienie nowych lokacji restauracji.
*/
DECLARE
    wiersz          kr_t_odcinki%ROWTYPE;
    plik            BLOB;
    strumien        CLOB;
    praw_wiersze    NUMBER(4) := 0;
    niepraw_wiersze NUMBER(4) := 0;
    caly_json       JSON_OBJECT_T;
    tab_lista       JSON_ARRAY_T;
    wiersz_json     JSON_OBJECT_T;
BEGIN
    SAVEPOINT a;
    SELECT file_content INTO plik FROM apex_workspace_static_files WHERE workspace_file_id = 81049231002863885122;
    -- plik := :body;
    strumien := utl_raw.cast_to_varchar2(plik);
    caly_json := json_object_t();
    tab_lista := json_array_t(strumien);
    FOR i IN 0..tab_lista.get_size() - 1 LOOP
        wiersz_json := json_object_t();
        wiersz_json := treat(tab_lista.get(i) AS JSON_OBJECT_T);
        IF wiersz_json.has('kat')       AND
            wiersz_json.has('wojew')    AND
            wiersz_json.has('sezon')    AND
            wiersz_json.has('odc')      AND
            wiersz_json.has('geo_szer') AND
            wiersz_json.has('geo_dlug') AND
            wiersz_json.has('rest')     THEN
            wiersz.kategoria := wiersz_json.get_number('kat');
            wiersz.wojewodztwo := upper(wiersz_json.get_string('wojew'));
            wiersz.sezon := wiersz_json.get_number('kat');
            wiersz.odcinek := wiersz_json.get_number('odc');
            wiersz.lokacja := sdo_geometry(2001, 4326, sdo_point_type(wiersz_json.get_number('geo_dlug'), wiersz_json.get_number('geo_szer'), NULL), NULL, NULL);
            wiersz.nazwa_rest := wiersz_json.get_string('rest');
            wiersz.opis := wiersz_json.get_string('opis');
            INSERT INTO kr_t_odcinki(kategoria, wojewodztwo, sezon, odcinek, lokacja, nazwa_rest, opis)
                VALUES (wiersz.kategoria,
                wiersz.wojewodztwo,
                wiersz.sezon,
                wiersz.odcinek,
                wiersz.lokacja,
                wiersz.nazwa_rest,
                wiersz.opis);
            praw_wiersze := praw_wiersze + 1;
        ELSE
            niepraw_wiersze := niepraw_wiersze + 1;
       END IF;
    END LOOP;
    COMMIT;
    caly_json.put('wsz_wiersze', tab_lista.get_size());
    caly_json.put('praw_wiersze', praw_wiersze);
    caly_json.put('niepraw_wiersze', niepraw_wiersze);
    owa_util.mime_header('application/json', true, 'UTF-8');
    htp.p(caly_json.stringify);
END;