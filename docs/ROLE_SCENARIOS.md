# Role-Based Scenariji

## Hijerarhija i Verifikacioni Lanac

### Secret Master (SM)
- **Najviši nivo pristupa**
- **Pristup**:
  - Biometrijska autentifikacija
  - Skrivena šifra
  - Tajni meni

- **Inicijalizacija Sistema**:
  1. Generiše inicijalni seed (root seed)
  2. Kreira jedinstveni zvučni/QR pattern za verifikaciju
  3. Uspostavlja "lanac poverenja" (chain of trust)

- **Verifikacija Master Admina**:
  1. Aktivira novi MA nalog kroz:
     - Zvučni pattern verifikacije
     - QR kod verifikacije
  2. Ugrađuje svoj root seed u MA verifikacioni lanac
  3. Potpisuje MA sertifikat svojim ključem

- **Validacija Lanca**:
  1. Periodično proverava integritet seed lanca
  2. Detektuje prekide u lancu poverenja
  3. Može poništiti bilo koji MA nalog koji nema validan lanac do root seed-a

- **Ključne operacije**:
  1. Aktivacija "mutiranog virusa"
  2. Monitoring celokupnog sistema
  3. Analiza sigurnosnih logova
  4. Upravljanje master admin nalozima
  5. Aktivacija emergency protokola

### Master Admin (MA)
- **Puna kontrola nad mrežom (uz validan seed lanac)**
- **Ograničen na 5 instanci**
- **Pristup**:
  - Zvučna verifikacija od SM
  - QR verifikacija od SM
  - Build verifikacija
  - Validnost 30 dana

- **Aktivacija**:
  - Mora imati validan seed lanac do SM root seed-a
  - Verifikacija kroz zvuk/QR od SM-a
  - Periodična re-verifikacija (30 dana)

- **Validacija**:
  1. Pri svakoj kritičnoj operaciji proverava se:
     - Postojanje SM root seed-a u lancu
     - Integritet celog lanca
     - Vremensku validnost verifikacije

- **Ključne operacije**:
  1. Kreiranje i verifikacija seed uređaja
  2. Kreiranje glasnika (privremenih)
  3. Slanje broadcast poruka
  4. Upravljanje semaforom
  5. Blokiranje sumnjivih uređaja

### Seed
- **Pomoćni administratori**
- **Pristup**:
  - Zvučna/QR verifikacija od MA
  - Verifikacija validna samo ako MA ima validan lanac do SM

- **Ključne operacije**:
  1. Proširenje mesh mreže
  2. Distribucija ključeva
  3. Verifikacija regularnih korisnika
  4. Monitoring mreže
  5. Transformacija u "lažni" seed

### Glasnik
- **Privremena uloga (max 48h)**
- **Pristup**:
  - Zvučna/QR verifikacija od MA
  - Vremenski ograničen (48h)

- **Ključne operacije**:
  1. Slanje odobrenih broadcast poruka
  2. Upravljanje semaforom
  3. Monitoring dostave poruka
  4. Prijavljivanje problema u mreži

### Regular User
- **Standardni korisnik**
- **Pristup**:
  - Verifikacija telefonom
  - Kontakt lista

- **Ključne operacije**:
  1. Prijem broadcast poruka
  2. Slanje poruka kontaktima
  3. Praćenje semafora
  4. Pregled statusa mreže

### Guest User
- **Najniži nivo pristupa**
- **Pristup**:
  - Osnovni pristup
  - Bez verifikacije

- **Ključne operacije**:
  1. Prijem broadcast poruka
  2. Praćenje semafora
  3. Pregled osnovnog statusa

## Detekcija Pretnji i Sigurnost

### Verifikacioni Lanac
- Svaki MA mora imati validan seed lanac do SM
- Prekid lanca = automatska deaktivacija
- Pokušaj operacija bez validnog lanca = tretira se kao pretnja

### Automatske Sigurnosne Mere
1. Blokiranje MA naloga bez validnog lanca
2. Obaveštavanje SM o pokušaju kompromitacije
3. Aktivacija dodatnih sigurnosnih mera
4. Logovanje svih sumnjivih aktivnosti

## Permisije

### Secret Master
```dart
const secretMasterPermissions = {
  'system.mutate': true,      // Aktivacija mutiranog virusa
  'system.monitor': true,     // Potpuni monitoring
  'admin.manage': true,       // Upravljanje adminima
  'security.full': true,      // Pun pristup sigurnosti
  'emergency.activate': true,  // Aktivacija emergency moda
  'chain.validate': true,     // Validacija seed lanca
};
```

### Master Admin
```dart
const masterAdminPermissions = {
  'network.manage': true,     // Upravljanje mrežom
  'broadcast.send': true,     // Slanje broadcast poruka
  'users.verify': true,       // Verifikacija korisnika
  'semaphore.control': true,  // Kontrola semafora
  'security.monitor': true,   // Monitoring sigurnosti
  'chain.required': true,     // Zahteva validan seed lanac
};
```

### Seed
```dart
const seedPermissions = {
  'network.extend': true,     // Proširenje mreže
  'keys.distribute': true,    // Distribucija ključeva
  'users.verify': true,       // Verifikacija korisnika
  'network.monitor': true,    // Monitoring mreže
  'chain.verify': true,       // Verifikacija MA lanca
};
```

### Glasnik
```dart
const glasnikPermissions = {
  'broadcast.approved': true,  // Slanje odobrenih poruka
  'semaphore.control': true,  // Kontrola semafora
  'network.status': true,     // Status mreže
  'time.limited': true,       // Vremensko ograničenje (48h)
};
```

### Regular User
```dart
const regularPermissions = {
  'message.receive': true,    // Prijem poruka
  'message.send': true,       // Slanje poruka kontaktima
  'semaphore.view': true,     // Pregled semafora
};
```

### Guest User
```dart
const guestPermissions = {
  'broadcast.receive': true,  // Prijem broadcast poruka
  'semaphore.view': true,    // Pregled semafora
};
```

## UI/UX Implikacije

### Secret Master Interface
- Skriveni pristup kroz specifičnu sekvencu akcija
- Biometrijska potvrda za kritične operacije
- Vizuelni prikaz seed lanca i njegovog integriteta
- Real-time monitoring svih MA aktivnosti

### Master Admin Interface
- Jasna indikacija validnosti seed lanca
- Countdown do sledeće potrebne verifikacije
- Vizuelni prikaz mreže i aktivnih čvorova
- Interfejs za verifikaciju novih Seed-ova i Glasnika

### Verifikacioni Interfejs
- Zvučni pattern generator/skener
- QR kod generator/skener
- Vizuelna potvrda uspešne verifikacije
- Prikaz statusa verifikacionog lanca 