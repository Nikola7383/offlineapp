# Secure Event App - Sistemska Arhitektura

## 1. Pregled Sistema
Secure Event App je offline-first sistem za bezbednu komunikaciju koji funkcioniše bez interneta.

### 1.1 Ključne Karakteristike
- Potpuno offline operacije
- Mesh networking
- Sound-based komunikacija (backup)
- Višeslojni security model
- Self-healing AI sistem

## 2. Role Sistem
### 2.1 Hijerarhija Rola
1. Secret Master (Nivo 100)
   - Kreiranje drugih Secret Mastera
   - Override svih protokola
   - Potpuna kontrola sistema
   
2. Master Admin (Nivo 90)
   - Upravljanje sistemom
   - Kreiranje Herald-a i Seed-ova
   - Monitoring sistema

3. Herald (Nivo 80)
   - Prenos kritičnih poruka
   - Override komunikacionih protokola
   - Mesh network management

4. Seed (Nivo 70)
   - Širenje mreže
   - File transfer
   - Mesh node operacije

5. Regular (Nivo 20)
   - Tekstualne poruke
   - Osnovne operacije

6. Guest (Nivo 10)
   - Samo tekstualne poruke
   - Ograničena veličina poruka

### 2.2 Permisije i Ograničenja
| Rola          | Text | Files | Images | Override | Wipe |
|---------------|------|-------|--------|----------|------|
| Secret Master | ✓    | ✓     | ✓      | ✓        | ✓    |
| Master Admin  | ✓    | ✓     | ✓      | ✗        | ✓    |
| Herald        | ✓    | ✓     | ✓      | ✓        | ✗    |
| Seed          | ✓    | ✓     | ✓      | ✗        | ✗    |
| Regular       | ✓    | ✗     | ✗      | ✗        | ✗    |
| Guest         | ✓    | ✗     | ✗      | ✗        | ✗    |

## 3. Komunikacioni Protokoli
### 3.1 Mesh Network
- Bluetooth mesh protokol
- Direct WiFi komunikacija
- Store-and-forward mehanizam
- Priority-based routing

### 3.2 Sound Protocol (Backup)
- Ultrazvučna komunikacija
- Error correction
- Automatic fallback

## 4. Security Model
### 4.1 Enkripcija
- End-to-end encryption
- Local key storage
- Role-based encryption levels

### 4.2 Authentication
- Offline authentication
- Role verification
- Device legitimacy check

## 5. AI Self-Healing
### 5.1 Monitoring
- System health checks
- Performance monitoring
- Anomaly detection

### 5.2 Recovery
- Automatic recovery procedures
- Protocol adaptation
- Resource optimization

## 6. Storage
### 6.1 Message Storage
- Encrypted local storage
- Priority-based retention
- Automatic cleanup

### 6.2 System Storage
- Protected configuration storage
- Role information
- Security keys 