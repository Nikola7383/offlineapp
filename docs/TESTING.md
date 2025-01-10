# Testiranje

## Pregled

Sistem koristi sveobuhvatnu test strategiju koja pokriva sve nivoe aplikacije, od unit testova do end-to-end testova.

## Vrste Testova

### Unit Testovi
- Testiranje individualnih komponenti
- Mockovanje zavisnosti
- Testiranje edge cases
- Testiranje error handling-a

### Integration Testovi
- Testiranje interakcije između komponenti
- Testiranje komunikacije sa eksternim servisima
- Testiranje database operacija

### End-to-End Testovi
- Testiranje kompletnog flow-a
- UI testiranje
- Performance testiranje

## Test Infrastruktura

### Test Setup
```dart
void main() {
  setUp(() {
    // Initialize test environment
    TestSetup.initialize();
  });

  tearDown(() {
    // Clean up after tests
    TestSetup.cleanup();
  });

  // Test cases
}
```

### Mocking
```dart
// Primer mock implementacije
class MockProcessManager extends Mock implements ProcessManager {
  @override
  Future<void> startProcess() async {
    // Mock implementation
  }
}
```

### Test Utilities
```dart
// Primer test helper funkcije
Future<void> setupTestEnvironment() async {
  await TestDatabase.initialize();
  await TestNetwork.setup();
  await TestSecurity.configure();
}
```

## Test Kategorije

### Process Management Tests
- Testiranje životnog ciklusa procesa
- Testiranje process recovery-ja
- Testiranje process monitoring-a

### Mesh Network Tests
- Testiranje P2P komunikacije
- Testiranje load balancing-a
- Testiranje network recovery-ja

### Security Tests
- Testiranje autentikacije
- Testiranje autorizacije
- Testiranje enkripcije

## Performance Testiranje

### Load Testing
- Testiranje pod različitim opterećenjima
- Testiranje skalabilnosti
- Testiranje resource usage-a

### Stress Testing
- Testiranje pod ekstremnim uslovima
- Testiranje recovery mehanizama
- Testiranje stabilnosti

### Benchmark Testing
- Merenje performansi ključnih operacija
- Poređenje različitih implementacija
- Praćenje performance trendova

## Test Coverage

### Code Coverage
- Minimum 80% coverage za production kod
- 100% coverage za kritične komponente
- Automatsko praćenje coverage-a

### Scenario Coverage
- Pokrivanje svih user story-ja
- Pokrivanje error scenarios-a
- Pokrivanje edge cases-a

## Continuous Testing

### CI/CD Integration
- Automatsko pokretanje testova
- Test reporting
- Coverage reporting

### Test Automation
- Automatizovani regression testovi
- Automatizovani performance testovi
- Automatizovani security testovi

## Best Practices

### Test Organization
- Jasna struktura test fajlova
- Konzistentno imenovanje
- Dobra dokumentacija

### Test Maintenance
- Redovno ažuriranje testova
- Cleanup test data
- Monitoring test performance-a

## Primeri

### Unit Test Primer
```dart
test('Process should start successfully', () async {
  final processManager = ProcessManager();
  final result = await processManager.startProcess();
  expect(result.status, equals(ProcessStatus.running));
});
```

### Integration Test Primer
```dart
testWidgets('User can start new process', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.byType(StartProcessButton));
  await tester.pumpAndSettle();
  expect(find.text('Process Started'), findsOneWidget);
});
```

### Performance Test Primer
```dart
test('Message routing should complete within 100ms', () async {
  final stopwatch = Stopwatch()..start();
  await meshNetwork.routeMessage(testMessage);
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(100));
}); 