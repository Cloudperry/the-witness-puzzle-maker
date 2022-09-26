# Ohjelma ja testaus
Tällä viikolla tein kirjaston suuntaamattomia verkkoja varten, jota tulen käyttämään projektissa paljon. Kirjoitin sitä varten yksikkötestit, jotka kattaa tällä hetkellä koko kirjaston. Yritin saada automaattista testien
haarakattavuuden tarkistusta toimimaan [tämän kirjaston](https://github.com/yglukhov/coverage) avulla, mutta se antoi sekavia tuloksia yksinkertaisimmillakin ohjelmilla.
[Tällä ohjelmalla](https://github.com/binhonglee/coco) sain haarakattavuuden toimimaan, mutta sen gitissä on raportoitu jonkun verran haarakattavuuden tarkkuuteen vaikuttavia bugeja. Kun katsoin haarakattavuuden ainoaa
testiä varten se kuitenkin vaikutti tarkalta. En vielä ehtinyt laittamaan ohjelman tuottamaa html kattavuusraporttia gittiin, mutta teen sen mahdollisimman ajoissa maanantaina.

# Dokumentaatio ja koodin laatu
Paransin määrittelydokumenttia ja tein sen selvemmäksi käytettyjen algoritmien suhteen. Lisäsin testausdokumentin, jossa kerrotaan miten testit voi suorittaa. tuntia. Checkstylen kaltainen ohjelma, jota Nimin kanssa käytän
on Nimin mukana tuleva nimpretty, joka seuraa [tätä tyyliohjetta](https://nim-lang.org/docs/nep1.html).

# Mitä opin
Suunnittelin tasoformaatin yksityiskohtia ja alotin hieman sen toteutusta (ei vielä repositorioon laitettavassa kunnossa). Törmäsin [Dynamic connectivity -ongelmaan](https://en.wikipedia.org/wiki/Dynamic_connectivity) ja
huomasin, että siitä ei kuitenkaan ole hyötyä omassa projektissani, koska "huoneisiin jakoa" ei jouduta päivittämään dynaamisesti.

# Ajankäyttö ja suunnitelma seuraavaa viikkoa varten
Käytin projektin tekoon ja suunnitteluun tällä viikolla noin 8 tuntia. Projekti on melko laaja ja joudun selvästi käyttämään siihen enemmän aikaa tulevilla viikoilla. Seuraavaksi jatkan ohjelman toteutusta tekemällä pelin
tasoja esittävät tietorakenteet, tasoeditorin ekan version ja tasojen renderöintikoodia sekä yksinkertaisen pelattavan sokkelon.

# Kysymyksiä ohjaajalle
 - Nimiä voi ymmärtää melko hyvin jos osaa Pythonia (ja esim. C++:n osaaminen auttaa). Kannattaako projektiin lisätä vähän kommentteja, jotka selittää suurimpia eroja Pythoniin verrattuna kohtiin, missä koodi ei ole
Pythonin kaltaista?
 - Haittaako, jos haarakattavuudessa on pieniä yksittäisiä virheitä (muutamien rivien verran)?
