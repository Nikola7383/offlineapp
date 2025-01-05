import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/screens/security_monitor_screen.dart';
import '../../lib/mesh/secure_mesh_network.dart';
import '../../lib/mesh/security/security_types.dart';

void main() {
  late MockSecureMeshNetwork mockNetwork;

  setUp(() {
    mockNetwork = MockSecureMeshNetwork();
  });

  testWidgets('Should display security status', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SecurityMonitorScreen(network: mockNetwork),
    ));

    expect(find.text('Status Sistema:'), findsOneWidget);
    expect(find.text('BEZBEDAN'), findsOneWidget);
  });

  testWidgets('Should show security metrics when expanded', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SecurityMonitorScreen(network: mockNetwork),
    ));

    // Klikni na expand dugme
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pump();

    expect(find.text('Detektovani napadi:'), findsOneWidget);
    expect(find.text('Anomalije:'), findsOneWidget);
    expect(find.text('Phoenix regeneracije:'), findsOneWidget);
  });

  testWidgets('Should display security events', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SecurityMonitorScreen(network: mockNetwork),
    ));

    // Simuliraj bezbednosni događaj
    mockNetwork.emitSecurityEvent(SecurityEvent.attackDetected);
    await tester.pump();

    expect(find.text('Detektovan napad'), findsOneWidget);
  });

  testWidgets('Should show event details dialog', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SecurityMonitorScreen(network: mockNetwork),
    ));

    mockNetwork.emitSecurityEvent(SecurityEvent.attackDetected);
    await tester.pump();

    // Tap na event
    await tester.tap(find.text('Detektovan napad'));
    await tester.pumpAndSettle();

    expect(find.text('Detalji Događaja'), findsOneWidget);
    expect(find.text('Tip: SecurityEvent.attackDetected'), findsOneWidget);
  });

  testWidgets('Should show security analysis', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SecurityMonitorScreen(network: mockNetwork),
    ));

    // Tap na FAB
    await tester.tap(find.byIcon(Icons.analytics));
    await tester.pumpAndSettle();

    expect(find.text('Analiza Bezbednosti'), findsOneWidget);
  });
}

class MockSecureMeshNetwork extends SecureMeshNetwork {
  final _eventController = StreamController<SecurityEvent>.broadcast();

  @override
  Stream<SecurityEvent> get securityEvents => _eventController.stream;

  @override
  bool get isCompromised => false;

  void emitSecurityEvent(SecurityEvent event) {
    _eventController.add(event);
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
