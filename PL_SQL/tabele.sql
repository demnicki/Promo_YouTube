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
ip        VARCHAR(60 CHAR),
agent     VARCHAR(300 CHAR), 
CONSTRAINT yt_i_uzytkownicy_logi FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id)
);

CREATE TABLE yt_k_profile(
id     CHAR(6 CHAR) NOT NULL,
nip    CHAR(10 CHAR),
nr_tel CHAR(9 CHAR),
url    VARCHAR(100 CHAR),
CONSTRAINT yt_i_uzytkownicy_profile FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id)
);

CREATE TABLE yt_k_trenerzy(
	id_trenera NUMBER(1),
	nazwa VARCHAR2(30 CHAR),
	CONSTRAINT yt_i_trenerzy PRIMARY KEY (id)
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
CONSTRAINT yt_i_uzytkownicy_btc_hash FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id)
);

CREATE TABLE yt_k_sezony(
id    NUMBER(1) NOT NULL,
tytul VARCHAR(100 CHAR),
CONSTRAINT yt_i_sezony PRIMARY KEY (id)
);

CREATE TABLE yt_k_odcinki(
id    NUMBER(2) DEFAULT ON NULL yt_sek_odcinki.NEXTVAL NOT NULL,
sezon NUMBER(1) NOT NULL,
nr NUMBER(2) NOT NULL,
tytul VARCHAR(100 CHAR),
CONSTRAINT yt_i_odcinki PRIMARY KEY (id),
CONSTRAINT yt_i_sezony_odcinki FOREIGN KEY (sezonu) REFERENCES yt_k_sezony(id)
);

CREATE TABLE yt_k_subs(
id  CHAR(6 CHAR) NOT NULL,
typ CHAR(1 CHAR) DEFAULT 'z' NOT NULL,
odc NUMBER(2) NOT NULL,
CONSTRAINT yt_i_uzytkownicy_subs FOREIGN KEY (id) REFERENCES yt_k_uzytkownicy(id),
CONSTRAINT yt_o_subs CHECK ((typ) in ('z','d')),
CONSTRAINT yt_i_odcinki_subs FOREIGN KEY (odc) REFERENCES yt_k_odcinki(id)
);