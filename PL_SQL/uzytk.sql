/*
Dynamiczna akcja do regionu Dane użytkownika.
*/

DECLARE
	n NUMBER(1);
BEGIN
    htp.p('<div id="dane_uzytkownika" onmouseover="text_background(''dane_uzytkownika'', 0)" onmouseout="text_background(''dane_uzytkownika'', 1)">');
    htp.p('<center><h1>Twoje dane</h1></center>');
    htp.p('<p class="text_left">Cześć. Twój identyfikator klienta to „<b>'||:ID_UZYTK||'</b>”. Jeśli chcesz się przelogować na inne konto: Kliknij w Twoje ID, w prawym górnym rogu, i następnie kliknij Przeloguj mnie. Podaj swój 6-cyfrowy identyfikator.</p>');
	htp.p('');
    SELECT count(id) INTO n FROM yt_k_profile WHERE id = :ID_UZYTK;
    IF n = 1 THEN
        SELECT nip, url INTO :P2_NIP, :P2_URL FROM yt_k_profile WHERE id = :ID_UZYTK;
        htp.p('<p class="text_left">Twój Numer Identyfikacji Podatkowej, do wystawienia faktury VAT to: <b>'||:P2_NIP||'</b>.</p>');
        htp.p('<p class="text_left">Link do Twojego profilu na Facebooku lub Linkedinie. <a href="'||:P2_URL||'" target=_blank>'||:P2_URL||'</a></p>');
    ELSE
        htp.p('<p class="text_left"><u>Twój profil jeszcze nie był edytowany.</u> Uzupełnij swój profil, o dane kontaktowe, aby ułatwić zakup naszych materiałów edukacyjnych.</p>');
    END IF;
    htp.p('</div>');
END;