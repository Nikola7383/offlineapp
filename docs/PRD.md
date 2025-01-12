# Product Requirements Document (PRD) - Glasnik

## 1. Uvod

### 1.1 Naziv projekta
Glasnik - Sigurna Offline Komunikacijska Aplikacija

### 1.2 Svrha
Pružanje sigurne, pouzdane i autonomne offline komunikacije na događajima, uz zaštitu od sabotaže, neovlašćenog pristupa i zaštitu privatnosti korisnika.

### 1.3 Ciljna grupa
- Organizatori događaja (Secret Master, Master Admin, Seed)
- Pomoćno osoblje (Glasnici)
- Učesnici na događajima (Regular i Guest korisnici)

## 2. Opis proizvoda

### 2.1 Tip aplikacije
- Mobilna aplikacija za offline komunikaciju (Android i iOS)
- Flutter framework sa Dart programskim jezikom

### 2.2 Mrežna Arhitektura
- Peer-to-peer (P2P) mesh mreža
- Primarni kanali: Bluetooth Mesh i WiFi Direct
- Backup kanal: Zvučni kanal za hitne poruke
- Automatsko prebacivanje između kanala

### 2.3 Sigurnosna Arhitektura
- Višeslojna enkripcija (Diffie-Hellman, AES, HMAC)
- Perfect Forward Secrecy
- Dinamički ključevi (15min i 1h rotacija)
- Anti-tampering mehanizmi
- Obfuskacija koda
- "Kameleon taktika" za dinamičke promene
- "Mutirani virus" za emergency situacije

### 2.4 Verifikacioni Lanac
- Root seed generisan od Secret Master-a
- Lanac poverenja (chain of trust)
- Zvučni i QR kod verifikacioni paterni
- Validacija integriteta lanca
- Automatska deaktivacija pri prekidu lanca

## 3. Funkcionalni zahtevi

### 3.1 Hijerarhija Korisnika

#### Secret Master (SM)
- **Pristup**: 
  - Biometrijska autentifikacija
  - Skrivena šifra
  - Tajni meni
- **Ključne funkcije**:
  - Generisanje root seed-a
  - Verifikacija Master Admin-a
  - Aktivacija "mutiranog virusa"
  - Monitoring sistema
  - Emergency protokoli

#### Master Admin (MA)
- **Ograničenja**: 
  - Maximum 5 instanci
  - Validnost 30 dana
- **Verifikacija**:
  - Zvučni pattern od SM
  - QR kod od SM
  - Build verifikacija
- **Funkcije**:
  - Kreiranje Seed-ova i Glasnika
  - Broadcast poruke
  - Upravljanje semaforom
  - Monitoring mreže

#### Seed
- **Verifikacija**:
  - Zvuk/QR od MA
  - Validnost vezana za MA lanac
- **Funkcije**:
  - Proširenje mreže
  - Distribucija ključeva
  - Verifikacija korisnika
  - Mogućnost transformacije u "lažni" seed

#### Glasnik
- **Ograničenja**:
  - Vremensko ograničenje 48h
- **Verifikacija**:
  - Zvuk/QR od MA
- **Funkcije**:
  - Slanje odobrenih poruka
  - Upravljanje semaforom

#### Regular User
- **Verifikacija**:
  - Telefonska verifikacija
- **Funkcije**:
  - Prijem/slanje poruka
  - Kontakt lista
  - Praćenje semafora

#### Guest User
- **Pristup**:
  - Bez verifikacije
- **Funkcije**:
  - Prijem broadcast poruka
  - Praćenje semafora

### 3.2 Komunikacijske Funkcije
- Broadcast poruke (2KB limit)
- Individualne poruke (samo za verifikovane)
- Automatsko brisanje prepiske
- Prioritetne hitne poruke
- Semafor sistem (crveno, žuto, zeleno)

### 3.3 Sigurnosne Funkcije
- Verifikacioni lanac sa root seed-om
- Dinamički ključevi i algoritmi
- Detekcija i blokiranje pretnji
- Lažni seedovi kao mamci
- Monitoring sumnjivih aktivnosti

## 4. Tehnička Implementacija

### 4.1 Arhitektura
- Clean Architecture pristup
- Modularni dizajn
- Service-based komunikacija
- Event-driven arhitektura

### 4.2 Baza podataka
- Lokalno skladištenje
- Transakcioni sistem
- Kompresija podataka
- Periodično čišćenje
- Backup mehanizmi

### 4.3 AI Sistem
- Autonomni monitoring
- Self-healing mehanizmi
- Detekcija anomalija
- Adaptivna zaštita

## 5. UI/UX Zahtevi

### 5.1 Secret Master Interface
- Skriveni pristup
- Biometrijska potvrda
- Vizuelizacija seed lanca
- Real-time monitoring

### 5.2 Master Admin Interface
- Status seed lanca
- Countdown verifikacije
- Mreža aktivnih čvorova
- Verifikacioni alati

### 5.3 Opšti UI zahtevi
- Minimalistički dizajn
- Jasne indikacije statusa
- Intuitivna navigacija
- Responsive layout

## 6. Testiranje

### 6.1 Sigurnosno testiranje
- Penetration testing
- Verifikacioni lanac
- Enkripcija/dekripcija
- Anti-tamper mere

### 6.2 Funkcionalno testiranje
- Mesh komunikacija
- Verifikacioni procesi
- Semafor sistem
- Recovery mehanizmi

### 6.3 Performance testiranje
- Load testing
- Stress testing
- Battery impact
- Network efficiency

## 7. Deployment

### 7.1 Distribucija
- Offline instalacija
- USB/WiFi Direct transfer
- QR kod instalacija

### 7.2 Održavanje
- Zero-touch maintenance
- Self-healing
- Automatski recovery
- Silent updates

## 8. Očekivani rezultati
- Potpuno autonomna offline aplikacija
- Visok nivo sigurnosti
- Robusna mesh komunikacija
- Efikasan recovery sistem
- Jednostavno korišćenje 