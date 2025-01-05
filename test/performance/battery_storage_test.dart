import 'package:flutter_test/flutter_test.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:your_app/main.dart';

void main() {
  late Battery battery;
  
  setUp(() {
    battery = Battery();
  });

  group('Battery & Storage Impact Tests', () {
    test('Should maintain reasonable battery usage', () async {
      final initialLevel = await battery.batteryLevel;
      
      // Simulira intenzivnu upotrebu - 1 sat
      await _simulateHeavyUsage(duration: const Duration(hours: 1));
      
      final finalLevel = await battery.batteryLevel;
      final batteryDrain = initialLevel - finalLevel;
      
      // Ne bi trebalo da potroši više od 15% baterije za sat vremena
      expect(batteryDrain, lessThan(15));
    });

    test('Should maintain reasonable storage growth', () async {
      final dir = await getApplicationDocumentsDirectory();
      final initialSize = await _calculateDirSize(dir);
      
      // Simulira nedelju dana korišćenja
      await _simulateWeekUsage();
      
      final finalSize = await _calculateDirSize(dir);
      final growth = finalSize - initialSize;
      
      // Ne bi trebalo da poraste više od 100MB za nedelju dana
      expect(growth, lessThan(100 * 1024 * 1024));
    });
  });
}

Future<void> _simulateHeavyUsage({required Duration duration}) async {
  final endTime = DateTime.now().add(duration);
  
  while (DateTime.now().isBefore(endTime)) {
    // Simulira aktivno korišćenje
    await messageService.sendMessage('Test message', 'sender1');
    await meshNetwork.broadcast(Message(...));
    await Future.delayed(const Duration(seconds: 1));
  }
}

Future<void> _simulateWeekUsage() async {
  // Simulira prosečno korišćenje tokom nedelje dana
  for (var day = 0; day < 7; day++) {
    for (var hour = 0; hour < 24; hour++) {
      // Simulira aktivnost tokom dana
      if (hour >= 8 && hour <= 22) { // Aktivni sati
        await _simulateHourlyUsage();
      }
    }
  }
} 