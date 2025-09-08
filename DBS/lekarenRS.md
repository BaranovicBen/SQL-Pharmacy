classDiagram
direction BT
class kosik
class liek
class pozicia
class predaj
class predpis
class produkt
class smeny
class ucast
class vernostna_karta
class zakaznik
class zamestnanec
class zmluva

kosik  -->  predaj : id_predaj
kosik  -->  produkt : id_produkt
liek  -->  produkt : id_produkt
predaj  -->  smeny : id_smeny
predaj  -->  zamestnanec : id_zamestnanec
predpis  -->  produkt : id_produkt
predpis  -->  zakaznik : id_zakaznika
predpis  -->  zamestnanec : id_zamestnanec
ucast  -->  smeny : id_smeny
ucast  -->  zamestnanec : id_zamestnanec
vernostna_karta  -->  zakaznik : id_zakaznika
zmluva  -->  pozicia : id_pozicia
zmluva  -->  zamestnanec : id_zamestnanec
