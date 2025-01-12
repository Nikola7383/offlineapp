# Event Handling Modul

## Pregled

Event handling modul je odgovoran za procesiranje različitih tipova događaja u sistemu. Implementira pattern za rukovanje događajima koji omogućava:
- Procesiranje hitnih događaja
- Procesiranje bezbednosnih događaja
- Upravljanje redom događaja
- Praćenje statusa procesiranja

## Struktura

```
events/
├── coordination/        # Koordinacija događaja
│   └── event_coordinator.dart
├── processing/         # Procesiranje događaja
│   ├── emergency_event_processor.dart
│   └── security_event_processor.dart
└── models/            # Modeli događaja
    ├── emergency_event.dart
    └── security_event.dart
```

## Komponente

### Event Model

Bazna `Event` klasa definiše zajedničku strukturu za sve tipove događaja:
- ID događaja
- Tip događaja
- Podaci događaja
- Vremenska oznaka
- Prioritet
- Metapodaci

Specijalizovani tipovi događaja:
- `EmergencyEvent`: Za hitne događaje (požar, poplava, itd.)
- `SecurityEvent`: Za bezbednosne događaje (upadi, pokušaji pristupa, itd.)

### Event Processors

#### EmergencyEventProcessor
- Procesira hitne događaje
- Validira tip događaja
- Upravlja redom hitnih događaja
- Prati status procesiranja

#### SecurityEventProcessor
- Procesira bezbednosne događaje
- Validira tip događaja
- Upravlja redom bezbednosnih događaja
- Prati status procesiranja

### Event Coordinator
- Koordinira procesiranje događaja
- Upravlja prioritetima
- Usmerava događaje ka odgovarajućim procesorima

## Dependency Injection

Event handling modul koristi dependency injection za registraciju procesora:
```dart
@module
abstract class EventsModule {
  @singleton
  IEmergencyEventProcessor get emergencyEventProcessor =>
      EmergencyEventProcessor();

  @singleton
  ISecurityEventProcessor get securityEventProcessor =>
      SecurityEventProcessor();
}
```

## Testiranje

Svaka komponenta ima odgovarajuće testove:
- `emergency_event_processor_test.dart`
- `security_event_processor_test.dart`

Testovi pokrivaju:
- Inicijalizaciju procesora
- Procesiranje događaja
- Upravljanje redom
- Stream procesiranih događaja

## Korišćenje

```dart
// Kreiranje hitnog događaja
final emergencyEvent = Event.emergency(
  id: '1',
  type: 'FIRE_ALARM',
  data: {'location': 'Building A'},
  timestamp: DateTime.now(),
  priority: 1,
);

// Procesiranje događaja
final result = await emergencyEventProcessor.processEvent(emergencyEvent);

// Praćenje procesiranih događaja
emergencyEventProcessor.processedEvents.listen((event) {
  // Handling procesiranog događaja
});
``` 