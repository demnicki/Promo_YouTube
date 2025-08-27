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
*/