import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/monitoring/resource_monitor.dart';

void main() {
  late ResourceMonitor monitor;

  setUp(() {
    monitor = ResourceMonitor(logger: LoggerService());
  });

  group('Resource Usage Tests', () {
    test('Should maintain efficient CPU usage', () async {
      // Startuje monitoring
      await monitor.startMonitoring();

      // Izvršava intenzivne operacije
      await _performIntensiveOperations();

      // Proverava CPU usage
      final cpuStats = await monitor.getCPUStats();
      expect(cpuStats.averageUsage, lessThan(70)); // max 70% CPU
      expect(cpuStats.peakUsage, lessThan(90)); // max 90% peak
    });

    test('Should optimize memory allocation', () async {
      final initialMemory = await monitor.getMemoryUsage();

      // Izvršava operacije sa velikim porukama
      await _processLargeMessages(1000);

      final peakMemory = await monitor.getMemoryUsage();
      final memoryGrowth = peakMemory - initialMemory;

      // Proverava memory leak
      expect(memoryGrowth, lessThan(50 * 1024 * 1024)); // max 50MB rast
    });

    test('Should manage storage efficiently', () async {
      final initialStorage = await monitor.getStorageUsage();

      // Simulira nedelju dana korišćenja
      await _simulateWeeklyUsage();

      final finalStorage = await monitor.getStorageUsage();
      final storageGrowth = finalStorage - initialStorage;

      // Proverava storage rast
      expect(storageGrowth, lessThan(100 * 1024 * 1024)); // max 100MB/nedelja
    });
  });
}
