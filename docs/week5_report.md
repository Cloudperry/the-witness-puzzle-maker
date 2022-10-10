# 5. viikkoraportti
Tällä viikolla korjasin viime viikolla tehtyä tasojen renderöintikoodia, lisäsin yhden pelin logiikkasymbolin grafiikat, paransin verkkokirjastoa ja dokumentaatiota. Nyt tasojen renderöinti toimii hyvin, mutta 
renderöintikoodissa on jonkun verran refaktoroitavaa. Käytin tällä viikolla n. 10 tuntia projektin tekemiseen, mutta melko paljon siitä meni ei niin olennaisiin dokumentaatiomuutoksiin ja projektin testaamiseen eri 
alustoilla. Projekti on selvästi jäljessä, mutta luulisin pääseväni tekemään tasoeditoria ja itse peliä ensi viikon alussa. Nyt on jo paljon pohjakirjastoja kasassa näiden toteutukseen. Seuraavaksi lisään loputkin pelin
sokkeloissa esiintyvät symbolit (onnistuu tod.näk. päivässä) ja aloitan tasoeditoria sekä peliä.

# Kysymyksiä ohjaajalle
- Tein verkon vieruslistan hajautustauluna, jonka avain on jokin solmu ja arvo on hajautusjoukko solmun naapureista. Syy tähän on 2-ulotteisten liukulukukoordinaattien käyttö verkon solmuina. Varmistin, että naapureiden
iterointi on nopeaa ja vieruslista ei vie kohtuuttomia määriä muistia. Vertaisarvioinnissa sain palautetta, että verkon vieruslista voisi olla tavalliseen tapaan kaksi sisäkkäistä listaa ja solmujen koordinaatit voisi 
varastoida muualla. Tätä perusteltiin käyttämäni rakenteen hitaalla naapureiden iteroinnilla ja ylimääräisellä muistinkäytöllä. Oletko samaa mieltä vertaisarvioijan kanssa?
