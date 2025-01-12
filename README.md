# Secure Event App

Aplikacija za sigurno upravljanje događajima sa distribuiranom mesh arhitekturom.

## Pregled

Secure Event App je Flutter aplikacija dizajnirana za sigurno i efikasno upravljanje događajima u distribuiranom okruženju. Aplikacija koristi mesh arhitekturu za poboljšanu skalabilnost i otpornost.

## Ključne Funkcionalnosti

- Distribuirano upravljanje procesima
- Mesh networking sa load balancing-om
- Sigurna komunikacija između čvorova
- Robusno praćenje stanja i statistika
- Recovery mehanizmi za slučaj otkaza
- Role-based pristup i kontrola

## Arhitektura

Aplikacija je organizovana u sledeće glavne module:

- **Core** - osnovne funkcionalnosti i servisi
- **Mesh** - implementacija mesh networking-a
- **Process** - upravljanje procesima
- **Security** - sigurnosni mehanizmi
- **Stats** - prikupljanje i analiza statistika

Detaljnija dokumentacija dostupna je u sledećim fajlovima:
- [Arhitektura](./docs/ARCHITECTURE.md)
- [API Dokumentacija](./docs/API.md)
- [Mesh Implementacija](./docs/MESH.md)
- [Sigurnost](./docs/SECURITY.md)
- [Testiranje](./docs/TESTING.md)
- [Role-Based Scenariji](./docs/ROLE_SCENARIOS.md)

## Razvoj

### Preduslovi

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code sa Flutter/Dart pluginovima

### Pokretanje

1. Klonirajte repozitorijum
```bash
git clone https://github.com/your-username/secure_event_app.git
```

2. Instalirajte zavisnosti
```bash
flutter pub get
```

3. Pokrenite aplikaciju
```bash
flutter run
```

### Testiranje

Za pokretanje testova:
```bash
flutter test
```

Za pokretanje integration testova:
```bash
flutter test integration_test
```

## Licenca

MIT License - pogledajte [LICENSE](LICENSE) fajl za detalje.
