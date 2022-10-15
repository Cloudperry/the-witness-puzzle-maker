# Mitä tein tällä viikolla
Tällä viikolla paransin tasojen luontiin käytettäviä kirjastofunktioita huomattavasti ja päätin, että en tee tasoeditoria, koska siihen ei ole aikaa. Tasojen luonti onnistuu nyt ihan riittävän ketterästi koodilla. Tein pari
alkuperäisestä pelistä kopioitua tasoa (tiedostoon levels/copiedHexLevels.nim). Lisäsin viivoihin liittyviä työkaluja ja tietorakenteen pelaajan piirtämän ratkaisuviivan esittämiseen. Tein tätä käyttäen alustavan version
tason ratkaisun tarkistusalgoritmista (joka tällä hetkellä osaa tarkistaa vain hexa symboleita). Tein testin, joka tarkistaa, että ratkaisun tarkistusalgoritmi toimii oikein copiedHexLevels.nim generoimissa tasoissa. Käytin
projektin tekoon tällä viikolla n. 15 tuntia.

# Suunnitelmat seuraaville viikoille
Ratkaisun eli pelaajan piirtämän viivan tarkistusalgoritmi on tämän kurssin näkökulmasta tärkein osa tätä projektia (vaikka muuallakin käytetään kohtuullisen vaativia algoritmeja). Seuraavaksi lisään tarkistusalgoritmiin
kaikki muut symbolit, paitsi polyominot (blocks). Teen joitain tasoja käyttäen näitä symboleita ja kirjoitan testejä niitä varten. Vasta sen jälkeen lisään polyomino symbolit, koska niiden tarkistusalgoritmi on vaikein.
Ihan viimisenä lisään pelin käyttöliittymään mahdollisuuden pelata peliä hiirellä, koska tämä on kurssin kannalta epäolennaisin osa projektia.
