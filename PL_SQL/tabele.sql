/*
Sekwencje do tabel.
*/

CREATE SEQUENCE yt_sek_odcinki
MINVALUE 10
MAXVALUE 99
START WITH 10;

CREATE SEQUENCE yt_sek_pliki
MINVALUE 100
MAXVALUE 999
START WITH 100;

CREATE SEQUENCE yt_sek_czesci
MINVALUE 100
MAXVALUE 999
START WITH 100;

CREATE SEQUENCE yt_sek_rozdz
MINVALUE 100
MAXVALUE 999
START WITH 100;

/*
Tabele.
*/

CREATE TABLE yt_k_uzytkownicy(
	id              CHAR(6 CHAR) NOT NULL,
	data_utworzenia DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT yt_i_uzytkownicy_id PRIMARY KEY (id)
);

CREATE TABLE yt_k_logi(
	id        CHAR(6 CHAR) NOT NULL,
	data_logu DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ip        VARCHAR2(60 CHAR),
	agent     VARCHAR2(300 CHAR),
	CONSTRAINT yt_i_uzytkownicy_logi FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id)
);

CREATE TABLE yt_k_profile(
	id     CHAR(6 CHAR) NOT NULL,
	nip    CHAR(10 CHAR),
	nr_tel CHAR(9 CHAR),
	url    VARCHAR2(100 CHAR),
	CONSTRAINT yt_i_uzytkownicy_profile FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id),
	CONSTRAINT yt_i_profile UNIQUE (id)
);

CREATE TABLE yt_k_trenerzy(
	id_trenera NUMBER(1),
	nazwa      VARCHAR2(30 CHAR),
	CONSTRAINT yt_i_trenerzy PRIMARY KEY (id_trenera)
);

CREATE TABLE yt_k_wiad(
	id            CHAR(6 CHAR) NOT NULL,
	id_trenera    NUMBER(1),
	data_wyslania DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	tresc         CLOB,
	zalacznik     BLOB,
	CONSTRAINT yt_i_uzytkownicy_wiad FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id),
	CONSTRAINT yt_i_id_trenera FOREIGN KEY (id_trenera) REFERENCES yt_k_trenerzy(id_trenera)
);

CREATE TABLE yt_k_promo_posty(
	id            CHAR(6 CHAR) NOT NULL,
	data_wyslania DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	screen        BLOB,
	CONSTRAINT yt_i_uzytkownicy_promo_posty FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id)
);

CREATE TABLE yt_k_btc_hash(
	id         CHAR(6 CHAR) NOT NULL,
	data_trans DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	hash       CHAR(65 CHAR) NOT NULL,
	CONSTRAINT yt_i_uzytkownicy_btc_hash FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id),
	CONSTRAINT yt_i_hash_trans UNIQUE (hash)
);

CREATE TABLE yt_k_sezony(
	id    NUMBER(1) NOT NULL,
	tytul VARCHAR2(100 CHAR),
	CONSTRAINT yt_i_sezony PRIMARY KEY (id)
);

CREATE TABLE yt_k_odcinki(
	id    NUMBER(2) DEFAULT ON NULL yt_sek_odcinki.NEXTVAL NOT NULL,
	sezon NUMBER(1) NOT NULL,
	nr    NUMBER(2) NOT NULL,
	tytul VARCHAR2(100 CHAR),
	opis  CLOB,
	CONSTRAINT yt_i_odcinki PRIMARY KEY (id),
	CONSTRAINT yt_i_sezony_odcinki FOREIGN KEY (sezon) REFERENCES yt_k_sezony(id)
);

CREATE TABLE yt_k_subs(
	id  CHAR(6 CHAR) NOT NULL,
	typ CHAR(1 CHAR) DEFAULT 'z' NOT NULL,
	odc NUMBER(2) NOT NULL,
	CONSTRAINT yt_i_subs UNIQUE (id, odc),
	CONSTRAINT yt_i_uzytkownicy_subs FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id),
	CONSTRAINT yt_o_subs CHECK ((typ) in ('z','d')),
	CONSTRAINT yt_i_odcinki_subs FOREIGN KEY (odc) REFERENCES yt_k_odcinki(id)
);

CREATE TABLE yt_k_pliki_odc(
	id    NUMBER(3) DEFAULT ON NULL yt_sek_pliki.NEXTVAL NOT NULL,
	odc   NUMBER(2) NOT NULL,
	nazwa VARCHAR2(100 CHAR),
	pdf   BLOB,
	CONSTRAINT yt_i_pliki_odc PRIMARY KEY (id),
	CONSTRAINT yt_i_odcinki_pliki FOREIGN KEY (odc) REFERENCES yt_k_odcinki(id)
);

CREATE TABLE yt_k_czesci(
	id    NUMBER(3) DEFAULT ON NULL yt_sek_czesci.NEXTVAL NOT NULL,
	odc   NUMBER(2) NOT NULL,
	typ   CHAR(1 CHAR) DEFAULT 'p' NOT NULL,
	nr    NUMBER(1) NOT NULL,
	id_yt VARCHAR2(12 CHAR) NOT NULL,
	CONSTRAINT yt_i_czesci PRIMARY KEY (id),
	CONSTRAINT yt_i_odcinki_czesci FOREIGN KEY (odc) REFERENCES yt_k_odcinki(id),
	CONSTRAINT yt_o_czesci CHECK ((typ) in ('p','d')),
	CONSTRAINT yt_i_id_yt UNIQUE (id_yt)
);

CREATE TABLE yt_k_rozdz(
	id      NUMBER(3) DEFAULT ON NULL yt_sek_rozdz.NEXTVAL NOT NULL,
	czesc   NUMBER(3) NOT NULL,
	sekunda NUMBER(5) NOT NULL,
	tytul   VARCHAR2(100 CHAR),
	CONSTRAINT yt_i_rozdz PRIMARY KEY (id),
	CONSTRAINT yt_i_czesci_rozdz FOREIGN KEY (czesc) REFERENCES yt_k_czesci(id)
);
/*
Widoki.
*/
CREATE VIEW yt_w_rozdz AS
SELECT yt_k_odcinki.id odc, yt_k_czesci.typ typ, 'Część nr: '||yt_k_czesci.nr||' '||CASE WHEN yt_k_czesci.typ = 'd' THEN 'Darmowa' WHEN yt_k_czesci.typ = 'p' THEN 'Płatna' END AS nr, yt_k_czesci.id_yt id_yt, yt_k_rozdz.sekunda sekunda, yt_k_rozdz.tytul tytul
FROM yt_k_odcinki 
LEFT JOIN yt_k_czesci ON yt_k_odcinki.id = yt_k_czesci.odc
LEFT JOIN yt_k_rozdz ON yt_k_czesci.id = yt_k_rozdz.czesc;

CREATE VIEW yt_w_rozdz_d AS
SELECT yt_k_odcinki.id odc, yt_k_czesci.typ typ, 'Część nr: '||yt_k_czesci.nr||' '||CASE WHEN yt_k_czesci.typ = 'd' THEN 'Darmowa' WHEN yt_k_czesci.typ = 'p' THEN 'Płatna' END AS nr, yt_k_czesci.id_yt id_yt, yt_k_rozdz.sekunda sekunda, yt_k_rozdz.tytul tytul
FROM yt_k_odcinki 
LEFT JOIN yt_k_czesci ON yt_k_odcinki.id = yt_k_czesci.odc
LEFT JOIN yt_k_rozdz ON yt_k_czesci.id = yt_k_rozdz.czesc
WHERE yt_k_czesci.typ = 'd';

/*
Kontrolery RESTapi.
*/
DECLARE
	z_pdf BLOB;
	n NUMBER(1);
BEGIN
	SELECT count(id) INTO n FROM yt_k_pliki_odc WHERE id = :id;
	IF n = 1 THEN
		SELECT pdf INTO z_pdf FROM yt_k_pliki_odc WHERE id = :id;
		owa_util.mime_header('application/pdf', true, 'UTF-8');
		wpg_docload.download_file(z_pdf);
	ELSE
		owa_util.mime_header('text/html', true, 'UTF-8');
		htp.p('<h1>Nie ma takiego pliku...</h1>');
	END IF;
END;