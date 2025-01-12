# Secure Event App - Arhitektura Sistema

## 1. Struktura Projekta

### 1.1 Security Modul
```
lib/security/
├── di/                 # Dependency injection
├── interfaces/         # Interfejsi
├── managers/          # Menadžeri
├── core/              # Jezgro sigurnosti
├── encryption/        # Enkripcija
├── audit/            # Revizija
├── integrity/        # Integritet
├── threat/           # Pretnje
└── ... (50+ specijalizovanih direktorijuma)
```

### 1.2 Core Modul
```
lib/core/
├── di/               # Dependency injection
├── interfaces/       # Osnovni interfejsi
├── services/         # Osnovni servisi
└── database/         # Baza podataka
```

## 2. Trenutno Stanje

### 2.1 Implementirano
- ✅ Osnovna struktura projekta
- ✅ Dependency injection konfiguracija (`build.yaml`)
- ✅ Bazne klase:
  - `InjectableService` - osnovna klasa za sve servise
  - `Disposable` - interfejs za upravljanje resursima
  - `Database` - osnovna klasa za rad sa bazom
- ✅ Servisi:
  - `DatabasePool` - implementiran pool konekcija
  - `LoggerService` - osnovna implementacija (bez file logging-a)

### 2.2 U Procesu
- 🔄 Logger sistem:
  - ✅ `ILoggerService` interfejs
  - ✅ `LoggerService` implementacija
  - ⏳ File logging
  - ⏳ Log rotacija
  - ⏳ Log nivoi

### 2.3 Poznati Problemi
1. Dependency Injection:
   - Duplirana registracija `SecurityDecisionManager`
   - Nedostaju registracije za preko 50 tipova
   - Problem sa `@injectable` anotacijama

2. Arhitektura:
   - Nekonzistentno korišćenje interfejsa
   - Nedostaje proper inicijalizacija servisa
   - Ciklične zavisnosti između modula

## 3. Plan Implementacije

### Faza 1: Core Infrastruktura
1. Logger sistem:
   - Dodati file logging
   - Implementirati log rotaciju
   - Dodati log nivoe
   - Integrisati sa ostalim servisima

2. Database sistem:
   - Implementirati `DatabaseService` interfejs
   - Dodati podršku za transakcije
   - Implementirati migracije
   - Dodati indeksiranje

3. Dependency Injection:
   - Rešiti duplirane registracije
   - Registrovati nedostajuće tipove
   - Rešiti ciklične zavisnosti

### Faza 2: Security Infrastruktura
1. Encryption sistem:
   - Implementirati `EncryptionService`
   - Dodati key rotation
   - Implementirati secure storage

2. Authentication:
   - Implementirati `AuthService`
   - Dodati token management
   - Implementirati session handling

3. Authorization:
   - Implementirati RBAC
   - Dodati permission management
   - Implementirati audit logging

## 4. Build Sistem

### 4.1 Dependency Injection (`build.yaml`)
```yaml
targets:
  $default:
    builders:
      injectable_generator|injectable_builder:
        enabled: true
        generate_for:
          - lib/**.dart
        options:
          auto_register: true
          class_name_pattern: "Service$|Repository$|Manager$"
```

### 4.2 Pravila
1. Svaki servis mora implementirati odgovarajući interfejs
2. Svaki servis mora biti pravilno registrovan u DI sistemu
3. Svaki servis mora imati jedinstvenu registraciju
4. Svi dependency-ji moraju biti jasno definisani

## 5. Sledeći Koraci

1. Rešavanje dupliranih registracija:
   - Locirati sve instance `SecurityDecisionManager`
   - Konsolidovati u jedan fajl
   - Ažurirati reference

2. Implementacija nedostajućih tipova:
   - Kreirati sve potrebne enume
   - Implementirati interfejse
   - Dodati proper anotacije

3. Kompletiranje logger sistema:
   - Implementirati file logging
   - Dodati log rotaciju
   - Integrisati sa ostalim servisima 