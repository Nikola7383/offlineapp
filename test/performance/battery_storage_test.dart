import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/interfaces/message_service_interface.dart';
import 'package:secure_event_app/core/interfaces/mesh_network_interface.dart';
import '../test_helper.mocks.dart';

void main() {
  late Battery battery;
  late IMessageService messageService;
  late IMeshNetwork meshNetwork;

  setUp(() {
    battery = Battery();
    messageService = MockIMessageService();
    meshNetwork = MockIMeshNetwork();
  });

  group('Battery & Storage Impact Tests', () {
    test('Should maintain reasonable battery usage', () async {
      final initialLevel = await battery.batteryLevel;

      // Simulira intenzivnu upotrebu - 1 sat
      await _simulateHeavyUsage(
        duration: const Duration(hours: 1),
        messageService: messageService,
        meshNetwork: meshNetwork,
      );

      final finalLevel = await battery.batteryLevel;
      final batteryDrain = initialLevel - finalLevel;

      // Ne bi trebalo da potroši više od 15% baterije za sat vremena
      expect(batteryDrain, lessThan(15));
    });

    test('Should maintain reasonable storage growth', () async {
      final dir = await getApplicationDocumentsDirectory();
      final initialSize = await _calculateDirSize(dir);

      // Simulira nedelju dana korišćenja
      await _simulateWeekUsage(
        messageService: messageService,
        meshNetwork: meshNetwork,
      );

      final finalSize = await _calculateDirSize(dir);
      final growth = finalSize - initialSize;

      // Ne bi trebalo da poraste više od 100MB za nedelju dana
      expect(growth, lessThan(100 * 1024 * 1024));
    });
  });
}

Future<void> _simulateHeavyUsage({
  required Duration duration,
  required IMessageService messageService,
  required IMeshNetwork meshNetwork,
}) async {
  final endTime = DateTime.now().add(duration);

  while (DateTime.now().isBefore(endTime)) {
    // Simulira slanje poruka
    for (var i = 0; i < 10; i++) {
      await messageService.sendMessage(
        recipientId: 'test_recipient',
        content: 'Test message content $i',
        type: 'text',
        priority: 1,
      );

      // Simulira broadcast poruke
      if (i % 3 == 0) {
        await meshNetwork.sendMessage(
          'Broadcast test message $i',
          recipientId: 'all',
          connectionType: ConnectionType.direct,
          metadata: {
            'type': 'broadcast',
            'priority': 0,
          },
        );
      }
    }

    await Future.delayed(const Duration(seconds: 1));
  }
}

Future<void> _simulateWeekUsage({
  required IMessageService messageService,
  required IMeshNetwork meshNetwork,
}) async {
  // Simulira korišćenje aplikacije tokom nedelju dana
  for (var day = 0; day < 7; day++) {
    // Simulira 8 sati aktivnog korišćenja dnevno
    await _simulateHourlyUsage(
      duration: const Duration(hours: 8),
      messageService: messageService,
      meshNetwork: meshNetwork,
    );
  }
}

Future<void> _simulateHourlyUsage({
  required Duration duration,
  required IMessageService messageService,
  required IMeshNetwork meshNetwork,
}) async {
  final endTime = DateTime.now().add(duration);

  while (DateTime.now().isBefore(endTime)) {
    // Simulira normalno korišćenje - 5 poruka na svakih 5 minuta
    for (var i = 0; i < 5; i++) {
      await messageService.sendMessage(
        recipientId: 'test_recipient',
        content: 'Test message content $i',
        type: 'text',
        priority: 1,
      );
    }

    await Future.delayed(const Duration(minutes: 5));
  }
}

Future<int> _calculateDirSize(Directory dir) async {
  int size = 0;
  try {
    await for (var entity in dir.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
  } catch (e) {
    print('Error calculating directory size: $e');
  }
  return size;
}
