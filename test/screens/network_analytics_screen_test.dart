import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/screens/network_analytics_screen.dart';
import '../../lib/mesh/secure_mesh_network.dart';

class MockSecureMeshNetwork extends SecureMeshNetwork {
  @override
  int get messageCount => 100;

  @override
  double get averageMessageSize => 256.0;

  @override
  double get messageFrequency => 10.0;

  @override
  double get networkDensity => 0.8;

  @override
  int get failedAttempts => 0;

  @override
  double get averageBatteryLevel => 0.9;

  @override
  double get averageSignalStrength => 0.85;

  @override
  int get honeypotHits => 0;
}

void main() {
  late MockSecureMeshNetwork mockNetwork;

  setUp(() {
    mockNetwork = MockSecureMeshNetwork();
  });

  testWidgets('Should display charts', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: NetworkAnalyticsScreen(network: mockNetwork),
    ));

    // Proveri da li su grafikoni prikazani
    expect(find.byType(LineChart), findsNWidgets(2));
  });

  testWidgets('Should allow metric selection', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: NetworkAnalyticsScreen(network: mockNetwork),
    ));

    // Otvori dropdown
    await tester.tap(find.byType(DropdownButton));
    await tester.pumpAndSettle();

    // Proveri da li su sve metrike dostupne
    expect(find.text('Broj poruka'), findsOneWidget);
    expect(find.text('Prosečna veličina'), findsOneWidget);
    expect(find.text('Frekvencija'), findsOneWidget);
    expect(find.text('Broj čvorova'), findsOneWidget);
    expect(find.text('Gustina mreže'), findsOneWidget);
    expect(find.text('Neuspeli pokušaji'), findsOneWidget);
    expect(find.text('Nivo baterije'), findsOneWidget);
    expect(find.text('Jačina signala'), findsOneWidget);
    expect(find.text('Honeypot pogoci'), findsOneWidget);
  });

  testWidgets('Should show settings dialog', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: NetworkAnalyticsScreen(network: mockNetwork),
    ));

    // Otvori podešavanja
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Podešavanja'), findsOneWidget);
    expect(find.text('Prikaži prag anomalije'), findsOneWidget);
  });

  testWidgets('Should update threshold visibility', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: NetworkAnalyticsScreen(network: mockNetwork),
    ));

    // Otvori podešavanja
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Promeni vidljivost praga
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Zatvori podešavanja
    await tester.tap(find.text('Zatvori'));
    await tester.pumpAndSettle();

    // Proveri da li je grafikon ažuriran
    expect(find.byType(LineChart), findsNWidgets(2));
  });

  testWidgets('Should display status bar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: NetworkAnalyticsScreen(network: mockNetwork),
    ));

    expect(find.text('Status:'), findsOneWidget);
    expect(find.text('Normalno'), findsOneWidget);
  });

  testWidgets('Should update charts periodically', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: NetworkAnalyticsScreen(network: mockNetwork),
    ));

    // Sačekaj nekoliko ažuriranja
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));

    // Proveri da li su grafikoni i dalje prikazani
    expect(find.byType(LineChart), findsNWidgets(2));
  });
}
