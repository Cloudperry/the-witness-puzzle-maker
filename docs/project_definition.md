# Projekti
Ajattelin tehdä pelattavan 2D version [The Witness](https://store.steampowered.com/app/210970/The_Witness/) -pelin tauluissa olevista sokkelopuzzleista ja (alkeellisen) tasoeditorin niille. [Täällä](https://thewitness.fandom.com/wiki/Puzzle_elements) on lyhyt kuvaus pelin sokkeloista ja niissä esiintyvien symbolien merkityksistä. 

# Ohjelmointikieli
Teen projektin [Nimillä](nim-lang.org). Nim on melko lähellä Python koodia, jossa on tyyppimerkinnät. Osaan Nimin lisäksi Pythonia, Luaa ja C#:ia (käytin pitkän aikaa sitten, mutta ymmärrän yksinkertaista koodia).

# Vaadittavat algoritmit ja tietorakenteet
Pelin tasojen esittämiseen vaaditaan tietorakenne, jossa on sokkelon tyyppi, aloituspiste(et), lopetuspiste(et) ja symbolit. Peliä pelatessa täytyy pitää kirjaa pelaajan piirtämästä viivasta. Puzzlen ratkaisua tarkistaessa jokainen symboli lisää omat vaatimuksensa piirrettävälle viivalle, ja jokaiseen symboliin liittyy siis omanlainen tarkistusalgoritmi. Esim. [pelin kuvauksessa](https://thewitness.fandom.com/wiki/Puzzle_elements) kuusikulmion tarkistamiseen riittää yksinkertainen tarkistus, että viiva kulkee sen läpi. Toisaalta pelissä on myös monimutkaisempia symboleita, kuten palikat (äskeisellä sivulla blocks). Niitä tarkistaessa viivan pitää rajata sokkelosta alue, jolle voi sijoittaa kaikki palikat alueen sisällä. Tarkemmista algoritmeista en vielä ole varma, koska ne tulevat olemaan täysin peliä varten räätälöityjä.

# Ohjelman syöte ja mihin sitä käytetään
Ohjelma käyttää syötteenä pelin tasoja, jotka ladataan tiedostosta. Taso näytetään pelaajalle ja puzzlen ratkaisu tarkistetaan, kun pelaaja on piirtänyt viivan sokkelon alkupisteestä loppuun.

# Tavoitteena olevat aika- ja tilavaativuudet
En tiedä vielä, mutta useimpien puzzlen symbolien tarkistaminen pitäisi onnistua tosi nopeasti. Esim. yksittäisen kuusikulmiosymbolin tarkistaminen tapahtuu vakioajassa. Toisaalta palikoiden tarkistamisen aikavaativuus saattaisi olla esim. O(n + m), jossa n on pelaajan rajaaman alueen pinta-ala ja m on muiden palikkasymboleiden määrä alueella.

# Lähteet
Pelin puzzleista on tehty [selaimessa toimiva versio](https://windmill.thefifthmatt.com/), jonka lähdekoodi löytyy [täältä](https://github.com/thefifthmatt/windmill-client). Saatan käyttää sen lähdekoodia apuna.

# Opinto-ohjelma 
Olen tietojenkäsittelytieteen kandiopiskelija.

# Projektin kieli
Tekisin mieluiten koodin sekä git repositorion tiedostot englanniksi, ja kaiken muun suomeksi. Jos pelkän koodin (muuttujat ja funktioiden nimet) tekeminen englanniksi haittaa niin voin tehdä kaiken englanniksi.
