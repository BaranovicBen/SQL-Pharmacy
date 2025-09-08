# SQL-Pharmacy

Projekt predstavuje návrh databázy lekárne, implementovaný v SQL s podporou XML dokumentácie (DTD + XSLT).  

## Obsah projektu
- **`create.sql`** – SQL skript na vytvorenie databázovej schémy (tabuľky, väzby, obmedzenia, trigger pre kontrolu vydávania predpisov iba lekárnikom).  
- **`insert.sql`** – SQL skript na vloženie testovacích dát (pozície, zamestnanci, smeny, produkty, zákazníci, predaje, predpisy...).  
- **`relational_schema.png`** – obrázok relačného modelu databázy.  
- **`main.xml`** – hlavný XML dokument so štruktúrou semestrálnej práce.  
- **`sproject.dtd`** – DTD definícia pre validáciu XML dokumentu.  
- **`sproject_html.xsl`** – XSLT transformácia pre generovanie HTML výstupu zo súboru `main.xml`.  
- **`sproject_html.css`** – CSS štýl pre formátovanie výsledného HTML.  

## Databázová schéma
Databáza modeluje procesy v lekárni:  
- **Zákazník** a jeho **Vernostná karta** (1:1).  
- **Zamestnanec**, jeho **Zmluva** (1:1) a priradená **Pozícia**.  
- **Smeny** a **Účasť zamestnancov na smenách** (M:N).  
- **Produkty**, špeciálny typ **Liek** (1:1 s Produktom).  
- **Predaj** produktov počas smien, vrátane **Košíka**.  
- **Predpis** vydaný zákazníkovi oprávneným zamestnancom (iba lekárnik). 

## Relačný model
![Relačný model](relational_schema.png)
 

Schéma zahŕňa obmedzenia:  
- Predpis môže vydať iba zamestnanec s pozíciou **lekárnik (id_pozicia = 10)** – implementované triggerom v PL/pgSQL.  

## Ako použiť
1. Spusti **`create.sql`** v PostgreSQL – vytvorí tabuľky a väzby.  
2. Spusti **`insert.sql`** – vloží testovacie dáta.  
3. Na vizualizáciu schémy použi **`relational_schema.png`**.  
4. Na vygenerovanie dokumentácie spusti XSL transformáciu:  
   ```bash
   xsltproc sproject_html.xsl main.xml > output.html
