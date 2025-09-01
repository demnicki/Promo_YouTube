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
    element_json    JSON_OBJECT_T;    
    tab_lista       JSON_ARRAY_T;
BEGIN
    SELECT count(id) INTO suma_wsz FROM kr_t_odcinki;
    SELECT count(id) INTO suma_przer FROM kr_t_odcinki WHERE kategoria = 0;
    SELECT count(id) INTO suma_nieudanych FROM kr_t_odcinki WHERE kategoria = 1;
    SELECT count(id) INTO suma_udanych FROM kr_t_odcinki WHERE kategoria = 2;
    caly_json := json_object_t();
    tab_lista := json_array_t();
    FOR i IN lista LOOP
        element_json := json_object_t();
        element_json.put('id', i.id);
        element_json.put('kat', i.kategoria);
        element_json.put('wojew', i.wojewodztwo);
        element_json.put('sezon', i.sezon);
        element_json.put('odc', i.odcinek);

        element_json.put('rest', i.nazwa_rest);
        element_json.put('opis', i.opis);
        tab_lista.append(element_json);
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
    NULL;

END;