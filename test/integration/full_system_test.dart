import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full System Integration Tests', () {
    testWidgets('Should perform complete message flow', (tester) async {
      await tester.pumpWidget(const MyApp());

      // 1. Login i inicijalizacija
      await _performLogin(tester);
      await tester.pumpAndSettle();

      // 2. Slanje poruke
      await _sendMessage(tester, 'Test integration message');
      await tester.pumpAndSettle();

      // 3. Verifikacija mesh propagacije
      final meshStatus = await getMeshStatus();
      expect(meshStatus.messagesPropagated, isTrue);
      expect(meshStatus.peersReceived, greaterThan(0));

      // 4. Verifikacija storage-a
      final dbStatus = await getDatabaseStatus();
      expect(dbStatus.messagesSaved, isTrue);
      expect(dbStatus.encryptionValid, isTrue);

      // 5. Verifikacija UI ažuriranja
      expect(find.text('Test integration message'), findsOneWidget);
    });

    testWidgets('Should handle complete offline-online cycle', (tester) async {
      await tester.pumpWidget(const MyApp());

      // 1. Početak u offline modu
      await _simulateOfflineMode();

      // 2. Slanje više poruka
      for (var i = 0; i < 10; i++) {
        await _sendMessage(tester, 'Offline message $i');
        await tester.pumpAndSettle();
      }

      // 3. Prelazak u online mod
      await _simulateOnlineMode();
      await tester.pumpAndSettle();

      // 4. Verifikacija sinhronizacije
      final syncStatus = await getSyncStatus();
      expect(syncStatus.allMessagesSynced, isTrue);
      expect(syncStatus.dataConsistent, isTrue);
    });
  });
}
