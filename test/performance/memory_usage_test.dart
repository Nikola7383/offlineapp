import 'package:flutter_test/flutter_test.dart';
import 'package:vm_service/vm_service.dart';
import 'package:your_app/main.dart' as app;

void main() {
  late VmService vmService;

  setUp(() async {
    final info = await Service.getInfo();
    vmService = await vmService.connect(info.serverUri!);
  });

  group('Memory Usage Tests', () {
    test('Should maintain stable memory usage during message operations',
        () async {
      final initialMemory = await _getCurrentMemoryUsage(vmService);

      // Izvršava 1000 operacija sa porukama
      for (var i = 0; i < 1000; i++) {
        await app.messageService.sendMessage(
          'Memory test message $i',
          'sender1',
        );
      }

      final finalMemory = await _getCurrentMemoryUsage(vmService);

      // Ne bi trebalo da poraste više od 50MB
      expect(
        finalMemory - initialMemory,
        lessThan(50 * 1024 * 1024), // 50MB
      );
    });

    test('Should cleanup memory after large operations', () async {
      final initialMemory = await _getCurrentMemoryUsage(vmService);

      // Izvršava veliku operaciju
      await _performLargeOperation();

      // Forsira garbage collection
      await vmService.getAllocationProfile();

      final finalMemory = await _getCurrentMemoryUsage(vmService);

      // Memorija bi trebala biti blizu početne
      expect(
        (finalMemory - initialMemory).abs(),
        lessThan(5 * 1024 * 1024), // 5MB tolerancija
      );
    });
  });
}
