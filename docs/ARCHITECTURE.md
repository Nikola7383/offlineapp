# Secure Event App - Arhitektura Sistema

## 1. Role Sistem
### 1.1 Advanced Roles
- **Secret Master**: Najviši nivo pristupa, može kreirati druge Secret Mastere
- **Master Admin**: Upravlja sistemom, ne može kreirati Secret Mastere
- **Herald**: Glasnik sa posebnim pravima za prenos poruka
- **Seed**: Node sa pravima za širenje mreže
- **Regular**: Standardni korisnik
- **Guest**: Ograničeni pristup

### 1.2 Bezbednosni Nivoi
Implementirani u `AdvancedPermissions`:
- Nivo 100: Secret Master
- Nivo 90: Master Admin
- Nivo 80: Herald
- Nivo 70: Seed

## 2. Implementirane Komponente
### 2.1 Secret Master Service
- Kreiranje novih Secret Mastera
- Override sistemskih protokola
- Upravljanje kritičnim operacijama

## 3. TODO Lista
- [ ] Master Admin Service
- [ ] Herald Service
- [ ] Sound Protocol
- [ ] Hardened Security 