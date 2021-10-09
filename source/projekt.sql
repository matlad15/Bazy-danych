CREATE TABLE Gracz (
	ID_gracza NUMBER(10) NOT NULL PRIMARY KEY,
	punktacja_ogolna NUMBER(10) NOT NULL CHECK (punktacja_ogolna = 0),
	typ_gracza VARCHAR2(20) NOT NULL CHECK (typ_gracza IN ('czlowiek', 'komputer')),
	czas_zalozenia_konta DATE NOT NULL
);

CREATE TABLE Gracz_czlowiek (
	ID_gracza NUMBER(10) NOT NULL PRIMARY KEY REFERENCES Gracz,
	imie VARCHAR2(20) NOT NULL,
	nazwisko VARCHAR2(20) NOT NULL,
	wiek NUMBER(10) NOT NULL
);

CREATE TABLE Gracz_komputer (
	ID_gracza NUMBER(10) NOT NULL PRIMARY KEY REFERENCES Gracz,
	poziom_zaawansowania NUMBER(10) NOT NULL CHECK (poziom_zaawansowania IN ('podstawowy', 'zaawansowany', 'legendarny'))
);

CREATE TABLE Gra (
	typ VARCHAR2(20) NOT NULL PRIMARY KEY,
	min_ilosc_graczy NUMBER(10) NOT NULL CHECK (min_ilosc_graczy > 0),
	max_ilosc_graczy NUMBER(10) NOT NULL CHECK (max_ilosc_graczy > 0)
);

CREATE TABLE Rozgrywka (
	ID_rozgrywki NUMBER(10) NOT NULL PRIMARY KEY,
	typ_gry VARCHAR2(20) NOT NULL REFERENCES Gra,
	ilosc_zawodnikow NUMBER(10) NOT NULL,
	ID_zwyciezcy NUMBER(10) NOT NULL REFERENCES Gracz,
	czas_trwania_rozgrywki NUMBER(10) NOT NULL,
	czas_rozpoczecia DATE NOT NULL
);

CREATE TABLE Relacja_gracz_rozgrywka (
	ID_rozgrywki NUMBER(10) NOT NULL REFERENCES Rozgrywka,
	ID_gracza NUMBER(10) NOT NULL REFERENCES Gracz,
	czy_wygral NUMBER(10) NOT NULL,
	CONSTRAINT relacja_gracz_rozgrywka_pk PRIMARY KEY (ID_rozgrywki, ID_gracza)
);

CREATE TABLE Ranking (
	ID_rankingu NUMBER(10) NOT NULL PRIMARY KEY,
	sposob_wyliczania VARCHAR2(20) NOT NULL CHECK (sposob_wyliczania IN ('punkty', 'procent zwyciestw')),
	typ_rankingu VARCHAR2(20) NOT NULL CHECK (typ_rankingu IN ('calosciowy', 'gry'))
);

CREATE TABLE Ranking_gry (
	ID_rankingu NUMBER(10) NOT NULL PRIMARY KEY REFERENCES Ranking,
	typ_gry VARCHAR2(20) NOT NULL REFERENCES Gra
);

CREATE TABLE Ranking_calosciowy (
	ID_rankingu NUMBER(10) NOT NULL PRIMARY KEY REFERENCES Ranking
);

CREATE TABLE Relacja_gracz_ranking (
	ID_gracza NUMBER(10) NOT NULL REFERENCES Gracz,
	ID_rankingu NUMBER(10) NOT NULL REFERENCES Ranking,
	punkty NUMBER(10) NOT NULL,
	CONSTRAINT relacja_gracz_ranking_pk PRIMARY KEY (ID_gracza, ID_rankingu)
);

CREATE TABLE Ruch (
	nr_ruchu NUMBER(10) NOT NULL,
	ID_rozgrywki NUMBER(10) NOT NULL REFERENCES Rozgrywka,
	ID_gracza NUMBER(10) NOT NULL REFERENCES Gracz,
	szczegoly_ruchu VARCHAR2(20) NOT NULL,
	CONSTRAINT ruch_pk PRIMARY KEY (nr_ruchu, ID_rozgrywki),
	CONSTRAINT ruch_fk FOREIGN KEY (ID_rozgrywki, ID_gracza) REFERENCES Relacja_gracz_rozgrywka
);

CREATE OR REPLACE TRIGGER gracz_tr
AFTER INSERT OR UPDATE ON Gracz
FOR EACH ROW
BEGIN
	IF :NEW.czas_zalozenia_konta > SYSDATE THEN
		raise_application_error(-20000, 'Zła data założenia konta !');
	END IF;

	IF INSERTING THEN
		FOR row IN (SELECT * FROM Ranking) LOOP
			INSERT INTO Relacja_gracz_ranking VALUES (:NEW.ID_gracza, row.ID_rankingu, 0);
		END LOOP;
	END IF;
END;
/

CREATE OR REPLACE TRIGGER rozgrywka_tr
AFTER INSERT OR UPDATE ON Rozgrywka
FOR EACH ROW
DECLARE
	minim NUMBER(10) := 0;
	maxim NUMBER(10) := 0;
BEGIN
	SELECT min_ilosc_graczy INTO minim FROM Gra WHERE Gra.typ = :NEW.typ_gry;
	SELECT max_ilosc_graczy INTO maxim FROM Gra WHERE Gra.typ = :NEW.typ_gry;

	IF :NEW.ilosc_zawodnikow < minim OR :NEW.ilosc_zawodnikow > maxim THEN
		raise_application_error(-20000, 'Zła liczba zawodników !');
	END IF;

	IF :NEW.czas_rozpoczecia > SYSDATE() THEN
		raise_application_error(-20000, 'Zła data rozpoczęcia !');
	END IF;
END;
/

CREATE OR REPLACE TRIGGER rgr_tr
BEFORE INSERT ON Relacja_gracz_rozgrywka
FOR EACH ROW
DECLARE
	ind NUMBER(10) := 0;
	ind1 NUMBER(10) := 0;
	ind2 NUMBER(10) := 0;
	ind3 NUMBER(10) := 0;
	typ VARCHAR2(20) := '';
	typ1 VARCHAR2(20) := '';
	licznik NUMBER(10) := 0;
	ile NUMBER(10) := 0;
	licznik1 NUMBER(10) := 0;
	ile1 NUMBER(10) := 0;
BEGIN
	SELECT typ_gry INTO typ FROM Rozgrywka WHERE Rozgrywka.ID_rozgrywki = :NEW.ID_rozgrywki;

	SELECT A.ID_rankingu INTO ind FROM Ranking A JOIN Ranking_gry B ON A.ID_rankingu = B.ID_rankingu 
		WHERE B.typ_gry = typ AND A.sposob_wyliczania = 'punkty';
	SELECT A.ID_rankingu INTO ind1 FROM Ranking A JOIN Ranking_gry B ON A.id_rankingu = B.id_rankingu 
		WHERE B.typ_gry = typ AND A.sposob_wyliczania = 'procent zwyciestw';

	SELECT A.ID_rankingu INTO ind2 FROM Ranking A JOIN Ranking_calosciowy B ON A.ID_rankingu = B.ID_rankingu 
		WHERE A.sposob_wyliczania = 'punkty';
	SELECT A.ID_rankingu INTO ind3 FROM Ranking A JOIN Ranking_calosciowy B ON A.id_rankingu = B.id_rankingu 
		WHERE A.sposob_wyliczania = 'procent zwyciestw';	

	FOR row IN (SELECT * FROM Relacja_gracz_rozgrywka) LOOP
		IF :NEW.ID_gracza = row.ID_gracza THEN
			SELECT typ_gry INTO typ1 FROM Rozgrywka WHERE Rozgrywka.ID_rozgrywki = row.ID_rozgrywki;
			ile1 := ile1 + 1;
			licznik1 := licznik1 + row.czy_wygral;
			IF typ = typ1 THEN
				ile := ile + 1;
				licznik := licznik + row.czy_wygral;
			END IF;
		END IF;
	END LOOP;

	ile := ile + 1;
	licznik := licznik + :NEW.czy_wygral;

	ile1 := ile1 + 1;
	licznik1 := licznik1 + :NEW.czy_wygral;

	UPDATE Relacja_gracz_ranking
	SET ID_gracza = ID_gracza, ID_rankingu = ID_rankingu, punkty = licznik * 10 - (ile - licznik) * 10
	WHERE ID_gracza = :NEW.ID_gracza AND ID_rankingu = ind;

	UPDATE Relacja_gracz_ranking
	SET ID_gracza = ID_gracza, ID_rankingu = ID_rankingu, punkty = licznik1 * 10 - (ile1 - licznik1) * 10
	WHERE ID_gracza = :NEW.ID_gracza AND ID_rankingu = ind2;

	UPDATE Relacja_gracz_ranking
	SET ID_gracza = ID_gracza, ID_rankingu = ID_rankingu, punkty = licznik * 100 / ile
	WHERE ID_gracza = :NEW.ID_gracza AND ID_rankingu = ind1;

	UPDATE Relacja_gracz_ranking
	SET ID_gracza = ID_gracza, ID_rankingu = ID_rankingu, punkty = licznik1 * 100 / ile1
	WHERE ID_gracza = :NEW.ID_gracza AND ID_rankingu = ind3;
END;
/