# Plan refaktorisanja aplikacije

## Trenutno stanje i izazovi

### 1. Struktura projekta
- Mikroservisna arhitektura sa izolovanim domenima
- Svaki direktorijum predstavlja zaseban domen koji mora ostati nezavisan
- Bezbednosna izolacija je ključni aspekt arhitekture

### 2. Identifikovani problemi
- Nedostajući generisani fajlovi
- Problemi sa dependency injection-om
- Duple implementacije nekih servisa

## Plan stabilizacije i unapređenja

### Faza 1 - Stabilizacija
1. Generisanje nedostajućih fajlova
   - Čišćenje build keša
   - Regeneracija svih potrebnih fajlova
   - Verifikacija generisanih fajlova

2. Rešavanje dependency injection problema
   - Konsolidacija interfejsa u core/interfaces
   - Osiguravanje pravilne implementacije interfejsa
   - Verifikacija DI konfiguracije

3. Održavanje postojeće strukture
   - Bez izmena postojećih direktorijuma
   - Očuvanje bezbednosne izolacije
   - Zadržavanje mikroservisne arhitekture

### Faza 2 - Konsolidacija servisa
1. Identifikacija duplih implementacija
2. Plan migracije za svaki servis
3. Izolovano testiranje svake promene

### Faza 3 - Postepena reorganizacija
1. Konsolidacija očiglednih duplikata
2. Održavanje izolacije između modula
3. Dokumentovanje namene svakog modula

## Struktura projekta koja se održava

```
lib/
  ├── core/                    # Osnovne komponente
  │   ├── di/                  # Dependency injection
  │   ├── interfaces/          # Interfejsi servisa
  │   └── base/               # Bazne klase
  ├── security/               # Bezbednosni moduli
  ├── mesh/                   # Mesh networking
  ├── ai/                     # AI komponente
  │   ├── health/
  │   └── recovery/
  ├── events/                 # Event handling (konsolidovano)
  │   ├── coordination/
  │   └── processing/
  ├── messaging/              # Messaging (konsolidovano)
  │   ├── transport/
  │   └── encryption/
  └── monitoring/            # Monitoring i dijagnostika
```

## Principi refaktorisanja

1. **Bezbednost pre svega**
   - Održavanje izolacije komponenti
   - Očuvanje bezbednosnih mehanizama
   - Pažljivo rukovanje sa osetljivim modulima

2. **Postepene promene**
   - Svaka promena mora biti testirana
   - Inkrementalni pristup
   - Verifikacija nakon svake promene

3. **Održavanje funkcionalnosti**
   - Bez narušavanja postojećih funkcionalnosti
   - Očuvanje interfejsa između modula
   - Kompatibilnost sa postojećim sistemom

## Koraci implementacije

1. **Priprema build sistema**
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

2. **Konsolidacija interfejsa**
- Kreiranje/ažuriranje ILoggerService
- Kreiranje/ažuriranje IDatabaseService
- Kreiranje/ažuriranje IMessageService
- Kreiranje/ažuriranje IEventService

3. **Verifikacija implementacija**
- Provera implementacije svakog interfejsa
- Testiranje funkcionalnosti
- Dokumentovanje promena

## Napomene

- Svaka promena mora biti odobrena i testirana
- Održavati dokumentaciju ažurnom
- Pratiti principe definisane u PRD-u
- Redovno proveravati usklađenost sa bezbednosnim zahtevima 