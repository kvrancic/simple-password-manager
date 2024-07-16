## Demo Walkthrough with `demo.sh`

For a comprehensive and colorful walkthrough of use cases, you can use the provided `demo.sh` script. This script will guide you through various functionalities of the system with a step-by-step interactive demonstration.


# Opis Sustava Password Manager

Sustav za upravljanje zaporkama osmišljen je tako da korisniku omogućava sigurnu pohranu i dohvat zaporki, koristeći se kriptografskim standardima i tehnikama. 

## Sigurnosni Principi i Zaštita

Jedan od ključnih aspekata našeg Password Managera jest da se master password nikada ne sprema u izvornom obliku niti kao hash vrijednost na disku ili u memoriji programa. Umjesto toga, koristi se kombinacija soli i funkcije za izvođenje ključa (PBKDF2) za stvaranje šifrirnog ključa iz master lozinke. Ova metoda omogućava da se svaki put generira jedinstveni šifrirni ključ čak i ako su dvije master lozinke identične, zahvaljujući jedinstvenosti soli koja se nasumično generira pri svakoj inicijalizaciji sustava. 

Korištenje soli u procesu derivacije ključa zajedno s velikim brojem iteracija (310000) dodatno zaštićuje sustav od napada pomoću rainbow tablica. Rainbow tablice su sofisticirani oblik prethodno izračunatih hash vrijednosti koji se mogu koristiti za brzo pronalaženje lozinki iz njihovih hash vrijednosti. Međutim, jedinstvena sol za svaku master lozinku osigurava da čak i ako dva korisnika imaju istu lozinku, rezultirajući ključevi (i time i hash vrijednosti) bit će različiti. To znači da bi napadač, koristeći rainbow tablice, morao izračunati tablicu za svaku moguću sol, što je izvedbeno neizvedivo zahvaljujući velikom broju mogućih soli.

Osim toga, AES-GCM šifriranje pruža i autentifikaciju podataka, osiguravajući integritet i autentičnost šifriranih informacija. Autentikacijski tag koji se generira tijekom šifriranja i provjerava prilikom dešifriranja, osigurava da svaka neautorizirana promjena podataka bude detektirana prije nego što program pokuša koristiti kompromitirane podatke.

Ukratko, sustav je dizajniran s fokusom na maksimalnu sigurnost korisničkih podataka. Nigdje ne pohranjujući master lozinku niti njezin hash, koristeći sol i veliki broj iteracija za izradu ključa, te primjenjujući AES-GCM šifriranje za zaštitu i autentifikaciju podataka, osigurava se zaštita od najčešćih metoda napada, uključujući brute-force napade i napade pomoću rainbow tablica.

## Kriptografske Metode

1. **PBKDF2**: Funkcija za derivaciju ključa koristi se za generiranje kriptografskog ključa iz master lozinke i soli (salt), koristeći veliki broj iteracija. To osigurava otpornost na brute-force napade.
2. **SHA-256**: Hash funkcija se koristi za stvaranje sažetka master lozinke koji se šifrira i pohranjuje. Ovo omogućava autentifikaciju bez potrebe za pohranom same lozinke.
3. **AES u GCM modu**: Simetrični algoritam šifriranja koristi se za šifriranje podataka (uključujući zaporku) koristeći ključ generiran iz master lozinke. GCM mod osigurava autentifikaciju i integritet podataka.

## Sigurnosni Zahtjevi

1. **Povjerljivost Zaporki**: Implementacijom AES šifriranja u GCM modu, sustav osigurava da napadač ne može odrediti informacije o zaporkama, uključujući njihovu duljinu ili usporedbu između različitih zaporki.
2. **Povjerljivost Adresa**: Korištenjem iste metode šifriranja, sustav također štiti adrese na kojima se zaporke koriste, ograničavajući informacije dostupne napadaču samo na broj različitih adresa u bazi.
3. **Integritet Adresa i Zaporki**: GCM mod osigurava da bilo kakva neautorizirana modifikacija šifriranih podataka bude otkrivena, čime se sprečava mogućnost da napadač zamijeni zaporku jedne adrese s zaporkom druge.

## Implementacija i struktura koda

Sustav je implementiran u Pythonu koristeći biblioteku `pycryptodome` za kriptografske operacije. Demonstracija funkcionalnosti sustava pružena je kroz shell skriptu koja vodi korisnika kroz procese inicijalizacije, dodavanja, dohvatovanja i ažuriranja zaporki.

### Inicijalizacija (`initialisation`)
Ova funkcija postavlja temelje za sigurno pohranjivanje zaporki. Kada se izvrši s master lozinkom kao argumentom, funkcija generira nasumičnu sol i koristi PBKDF2 algoritam za izvođenje ključa iz master lozinke i soli. Ovaj ključ se potom koristi za šifriranje hash-a master lozinke pomoću AES-GCM algoritma, koji osigurava povjerljivost i integritet podataka. Šifrirani podaci zajedno s soli, nonce (inicijalizacijski vektor za AES-GCM), i autentikacijskim tagom se spremaju u datoteku, pripremajući sustav za sigurnu pohranu korisničkih zaporki.

### Provjera Master Lozinke (`check_master_password`)
Pri svakom pokušaju pristupa pohranjenim zaporkama, potrebno je verificirati master lozinku. Ova funkcija čita sol, nonce, i šifrirani hash master lozinke iz datoteke, te koristi unesenu master lozinku za generiranje ključa pomoću PBKDF2. Ključ se koristi za dešifriranje hash-a i njegova provjera s hashom izvedenim iz unesene master lozinke. Ako hashovi odgovaraju, pristup je autoriziran i funkcija vraća dešifrirane podatke; u suprotnom, izvršenje se prekida s porukom o grešci.

### Dodavanje Zaporke (`add_password`)
Ova funkcija omogućuje korisniku da pohrani novu zaporku za određenu adresu. Prvo se provjerava ispravnost master lozinke pomoću funkcije `check_master_password`. Nakon uspješne verifikacije, funkcija generira novi set soli i ključeva, koristi ih za šifriranje postojećih podataka zajedno s novim parom adresa-zaporka, i sprema ažurirane šifrirane podatke u datoteku. Korištenjem novog seta soli i ključeva pri svakom dodavanju zaporki povećava se sigurnost sustava.

### Ažuriranje Podataka (`update_password_data`)
Funkcija služi za ažuriranje unosa zaporki unutar internog spremnika podataka koji se održava u memoriji. Ona prima postojeće podatke, adresu i novu zaporku, ažurira odgovarajući unos i vraća ažurirani set podataka spreman za šifriranje i pohranjivanje.

### Dohvaćanje Zaporke (`get_password`)
Kada korisnik želi dohvatiti zaporku za određenu adresu, ova funkcija prvo verificira master lozinku. Nakon provjere, funkcija pretražuje dešifrirane podatke za traženu adresu i ispisuje pripadajuću zaporku. Ako adresa nije pronađena, korisniku se prikazuje obavijest.

## Pokretanje Demonstracije

Za pokretanje demonstracije, korisnik treba izvršiti sljedeće korake:

1. Dodijeliti izvršna prava skripti: ```chmod +x demo.sh```
2. Pokrenuti skriptu: ```./demo.sh```

Eventualno, možemo i pokrenuti skriptu samo s ```bash demo.sh``` naredbom.

Skripta vodi korisnika kroz različite funkcionalnosti sustava, demonstrirajući sigurnosne značajke i kriptografsku zaštitu zaporki.

## Izvori Informacija

Za izradu ovog sustava koristili su se sljedeći izvori:

- [Sigurnost Računalnih Sustava na FER-u](https://www.fer.unizg.hr/predmet/srs)
- [Key Derivation Functions Explained](https://www.comparitech.com/blog/information-security/key-derivation-function-kdf/#What_are_key_derivation_functions_KDFs_used_for): Osnovni principi i važnost funkcija za derivaciju ključeva u kriptografskim sustavima.
- ChatGPT: Općenite informacije o kriptografskim metodama i sigurnosnim praksama.
- FER Discord: Diskusije s kolegama

