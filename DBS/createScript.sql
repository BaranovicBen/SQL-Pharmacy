-- DROP TABLES IF EXISTS (in correct dependency order)
DROP VIEW IF EXISTS draheProdukty;
DROP TABLE IF EXISTS Kosik;
DROP TABLE IF EXISTS Predaj;
DROP TABLE IF EXISTS Predpis;
DROP TABLE IF EXISTS Ucast;
DROP TABLE IF EXISTS Smeny;
DROP TABLE IF EXISTS Zmluva;
DROP TABLE IF EXISTS Zamestnanec;
DROP TABLE IF EXISTS Pozicia;
DROP TABLE IF EXISTS Liek;
DROP TABLE IF EXISTS Produkt;
DROP TABLE IF EXISTS Vernostna_karta;
DROP TABLE IF EXISTS Zakaznik;

-- ZAKAZNIK
CREATE TABLE Zakaznik (
  id_zakaznik BIGINT PRIMARY KEY,
  meno VARCHAR(100) NOT NULL,
  priezvysko VARCHAR(100) NOT NULL
);

-- VERNOSTNA KARTA (1:1 so ZAKAZNIK)
CREATE TABLE Vernostna_karta (
  id_zakaznik BIGINT PRIMARY KEY,
  body INTEGER NOT NULL,
  FOREIGN KEY (id_zakaznik) REFERENCES Zakaznik(id_zakaznik) ON DELETE CASCADE
);

-- POZICIA
CREATE TABLE Pozicia (
  id_pozicia SERIAL PRIMARY KEY,
  nazov VARCHAR(50) NOT NULL
);

-- ZAMESTNANEC
CREATE TABLE Zamestnanec (
  id_zamestnanec SERIAL PRIMARY KEY,
  meno VARCHAR(100) NOT NULL,
  priezvysko VARCHAR(100) NOT NULL
);

-- ZMLUVA (1:1 so Zamestnanec)
CREATE TABLE Zmluva (
  id_zamestnanec INTEGER PRIMARY KEY,
  id_pozicia INTEGER NOT NULL,
  datum DATE NOT NULL,
  mzda NUMERIC(10,2) NOT NULL,
  FOREIGN KEY (id_zamestnanec) REFERENCES Zamestnanec(id_zamestnanec) ON DELETE CASCADE,
  FOREIGN KEY (id_pozicia) REFERENCES Pozicia(id_pozicia) ON DELETE CASCADE
);

-- SMENY
CREATE TABLE Smeny (
  id_smeny SERIAL PRIMARY KEY,
  cas_od TIME NOT NULL,
  cas_do TIME NOT NULL,
  den INTEGER NOT NULL
);

-- UCAST (asociatívna tabuľka)
CREATE TABLE Ucast (
  id_zamestnanec INTEGER NOT NULL,
  id_smeny INTEGER NOT NULL,
  PRIMARY KEY (id_smeny, id_zamestnanec),
  FOREIGN KEY (id_smeny) REFERENCES Smeny(id_smeny) ON DELETE CASCADE,
  FOREIGN KEY (id_zamestnanec) REFERENCES Zamestnanec(id_zamestnanec) ON DELETE CASCADE
);

-- PRODUKT
CREATE TABLE Produkt (
  id_produkt SERIAL PRIMARY KEY,
  nazov VARCHAR(255) UNIQUE NOT NULL,
  typ VARCHAR(50) NOT NULL,
  cena NUMERIC(10,2) NOT NULL,
  ks INTEGER NOT NULL
);

-- LIEK (špecializácia PRODUKTU)
CREATE TABLE Liek (
  id_produkt INTEGER PRIMARY KEY,
  forma VARCHAR(50) NOT NULL,
  latka VARCHAR(100) NOT NULL,
  choroba VARCHAR(100),
  cielovka VARCHAR(100),
  FOREIGN KEY (id_produkt) REFERENCES Produkt(id_produkt) ON DELETE CASCADE
);

--Predaj
CREATE TABLE Predaj (
  id_predaj BIGINT PRIMARY KEY,
  cena NUMERIC(10,2) NOT NULL,
  mnozstvi INTEGER NOT NULL,
  id_zamestnanec INTEGER NOT NULL,
  id_smeny BIGINT NOT NULL,
  id_zakaznik BIGINT,
  FOREIGN KEY (id_zamestnanec, id_smeny) REFERENCES Ucast(id_zamestnanec, id_smeny) ON DELETE RESTRICT,
  FOREIGN KEY (id_zakaznik) REFERENCES Vernostna_karta(id_zakaznik) ON DELETE SET NULL
);

-- KOSIK
CREATE TABLE Kosik (
  id_predaj  BIGINT  NOT NULL,
  id_produkt  INTEGER NOT NULL,
  PRIMARY KEY (id_predaj, id_produkt),
  FOREIGN KEY (id_predaj) REFERENCES Predaj(id_predaj) ON DELETE CASCADE,
  FOREIGN KEY (id_produkt) REFERENCES Produkt(id_produkt) ON DELETE CASCADE
);

-- PREDPIS
CREATE TABLE Predpis (
  id_predpis BIGINT PRIMARY KEY,
  datum DATE NOT NULL,
  davkovanie VARCHAR(256) NOT NULL,
  id_zakaznik BIGINT NOT NULL,
  id_zamestnanec INTEGER NOT NULL,
  id_produkt INTEGER NOT NULL,
  FOREIGN KEY (id_produkt) REFERENCES Liek(id_produkt) ON DELETE CASCADE,
  FOREIGN KEY (id_zakaznik) REFERENCES Zakaznik(id_zakaznik) ON DELETE CASCADE,
  FOREIGN KEY (id_zamestnanec) REFERENCES Zamestnanec(id_zamestnanec) ON DELETE CASCADE
);

-- IO1: id_smeny + id_zamestnanec v Ucast je unikátne (vynútené PK)
-- IO2: Predpis musí byť na registrovaného Zakaznika (vynútené FK)
-- IO3: Iba Lekarnik (pozícia = 10) môže vydávať predpisy
CREATE OR REPLACE FUNCTION validate_lekarnik_predpis()
RETURNS trigger AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Zmluva WHERE id_zamestnanec = NEW.id_zamestnanec AND id_pozicia = 10
  ) THEN
    RAISE EXCEPTION 'Predpis môže vydať iba zamestnanec s pozíciou lekárnik (10)';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_lekarnik_predpis
BEFORE INSERT OR UPDATE ON Predpis
FOR EACH ROW EXECUTE FUNCTION validate_lekarnik_predpis();