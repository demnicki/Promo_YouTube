/*
Dynamiczna akcja do regionu Dane użytkownika.
*/

DECLARE
	n     NUMBER(1);
    z_nip yt_k_profile.nip%TYPE;
    z_url yt_k_profile.url%TYPE;
BEGIN
    htp.p('<div id="dane_uzytkownika" onmouseover="text_background(''dane_uzytkownika'', 0)" onmouseout="text_background(''dane_uzytkownika'', 1)">');
    htp.p('<center><h1>Twoje dane</h1></center>');
    htp.p('<p class="text_left">Cześć. Twój identyfikator klienta to „<b>'||:ID_UZYTK||'</b>”. Jeśli chcesz się przelogować na inne konto: Kliknij w Twoje ID, w prawym górnym rogu, i następnie kliknij Przeloguj mnie. Podaj swój 6-cyfrowy identyfikator.</p>');
    SELECT count(id) INTO n FROM yt_k_profile WHERE id = :ID_UZYTK;
    IF n = 1 THEN
        SELECT nip, url INTO z_nip, z_url FROM yt_k_profile WHERE id = :ID_UZYTK;
        htp.p('<p class="text_left">Twój Numer Identyfikacji Podatkowej, do wystawienia faktury VAT to: <b>'||z_nip||'</b>.</p>');
        htp.p('<p class="text_left">Link do Twojego profilu na Facebooku lub Linkedinie. <a href="'||z_url||'" target=_blank>'||z_url||'</a></p>');
    ELSE
        htp.p('<p class="text_left"><u>Twój profil jeszcze nie był edytowany.</u> Uzupełnij swój profil, o dane kontaktowe, aby ułatwić zakup naszych materiałów edukacyjnych.</p>');
    END IF;
    htp.p('</div>');
END;

/*
Dynamiczna akcja do regionu Instrukcja płatności.
*/

DECLARE
	n        NUMBER(2);
    suma_pln VARCHAR2(15 CHAR);
    suma_btc VARCHAR2(15 CHAR);
BEGIN
    htp.p('<div id="subs" class="box_column" onmouseover="text_background(''subs'', 0)" onmouseout="text_background(''subs'', 1)">');
    htp.p('<div class="text_center">');
    htp.p('<h1>Płatność</h1>');
    htp.p('</div>');
    SELECT count(id) INTO n FROM yt_k_subs WHERE id = :ID_UZYTK AND typ = 'z';
    IF n > 0 THEN
        SELECT to_char((count(id) * 9), '999,99'), to_char((count(id) * 9 * :KURS_BTC), 'fm9.99999999') INTO suma_pln, suma_btc FROM yt_k_subs WHERE id = :ID_UZYTK AND typ = 'z';
        htp.p('<div class="box_row">');
        htp.p('<div class="qr">');
        htp.p('<img src="https://oracleapex.com/ords/r/premium/files/static/v688/ad_btc.png">');
        htp.p('</div>');
        htp.p('<div>');
        htp.p('<p class="text_left">Łączny koszt Twojego zamówienia, to: <b>'||suma_pln||' PLN</b>.</p>');
        htp.p('<p class="text_left">W przypadku płatności BLIK-iem, operatorem płatności jest serwis <a href="https://buycoffee.to/demnicki" target="_blank">Buy Coffee</a>.</p>');
        htp.p('<p class="text_left">A w przypadku płatności kryptowalutą BitCoina, przelej kwotę <b>0'||suma_btc||' BTC</b> na adres <b>3FgSnLUPCiYvHfebNkxopovDA1GLZ7Mogz</b> . Możesz użyć do tego widoecznego po lewej stronie obrazu QR.</p>');
        htp.p('<p class="text_left">Po dokonaniu przelewu BitCoin, wstaw w polu po lewej stronie, 64-znakowy hash tej transakcji BitCoin. I kliknij Potwierdź płatność BitCoinem. Nasz system znajdzie Twoją transakcję w sieci blockchain. Jeśli wszystko się zgadza, kwota i adres portfela. Wówczas odblokuje cię dostępu do całego odcinka, wraz materiałami edukacyjnymi, do niego załączonymi.</p>');
        htp.p('</div>');
        htp.p('</div>');
    ELSE
        htp.p('<p class="text_center">Twoje zamówienie jest puste. Wybierz odcinek lub cały sezon jaki chcesz zakupić.</p>');
    END IF;
    htp.p('</div>');
END;