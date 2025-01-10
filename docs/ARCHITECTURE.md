# Arhitektura Sistema

## Pregled

Secure Event App koristi slojevitu arhitekturu sa jasno definisanim odgovornostima za svaki sloj:

```
UI Layer
   ↓
Business Logic Layer (BLL)
   ↓
Service Layer
   ↓
Data Access Layer (DAL)
```

## Slojevi

### UI Layer
- Implementiran koristeći Flutter widgets
- Koristi Provider pattern za state management
- Implementira MVVM pattern za odvajanje logike
- Responsive dizajn koji se prilagođava različitim veličinama ekrana

### Business Logic Layer (BLL)
- Implementira core poslovnu logiku
- Upravlja procesima i njihovim stanjima
- Implementira recovery strategije
- Koordinira komunikaciju između servisa

### Service Layer
- Implementira mesh networking
- Upravlja komunikacijom između čvorova
- Implementira load balancing
- Upravlja sigurnosnim aspektima

### Data Access Layer (DAL)
- Upravlja lokalnim skladištenjem
- Implementira sinhronizaciju podataka
- Upravlja keširanje

## Ključne Komponente

### Process Management
- ProcessManager: Upravlja životnim ciklusom procesa
- ProcessStarter: Inicijalizuje nove procese
- ProcessStatsCollector: Prikuplja metrike i statistike

### Mesh Networking
- MeshNetwork: Implementira P2P komunikaciju
- LoadBalancer: Distribuira opterećenje između čvorova
- MeshSecurity: Implementira sigurnosne protokole

### Recovery System
- RecoveryManager: Upravlja recovery strategijama
- RecoveryStrategy: Definiše specifične strategije oporavka
- StateManager: Prati i upravlja stanjem sistema

## Komunikacija

### Interna Komunikacija
- Koristi Observer pattern za praćenje promena
- Implementira Event Bus za asinhronu komunikaciju
- Koristi Dependency Injection za labavo povezivanje komponenti

### Eksterna Komunikacija
- Implementira sigurne P2P protokole
- Koristi enkripciju za sve podatke u tranzitu
- Implementira retry mehanizme za robusnost

## Sigurnost

### Autentikacija i Autorizacija
- Implementira JWT za autentikaciju
- Koristi RBAC za kontrolu pristupa
- Implementira audit logging

### Enkripcija
- Koristi AES-256 za podatke u mirovanju
- Implementira E2E enkripciju za komunikaciju
- Koristi sigurne random generatore

## Performanse

### Optimizacije
- Implementira efikasno keširanje
- Koristi lazy loading gde je moguće
- Optimizuje mesh komunikaciju

### Monitoring
- Prati ključne metrike sistema
- Implementira automatsko alerting
- Prikuplja performance statistike 