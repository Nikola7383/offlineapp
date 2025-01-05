import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

// Importi modela
import 'package:your_package/mesh/models/node.dart';
import 'package:your_package/mesh/models/route.dart';
import 'package:your_package/mesh/models/protocol.dart';
import 'package:your_package/mesh/models/device_context.dart';
import 'package:your_package/mesh/models/power_sample.dart';

// Importi glavnih klasa
import 'package:your_package/mesh/routing/mesh_router.dart';
import 'package:your_package/mesh/protocol/protocol_selector.dart';
import 'package:your_package/mesh/power/power_manager.dart';

void main() {
  late MeshRouter router;
  late ProtocolSelector protocolSelector;
  late PowerManager powerManager;

  setUp(() {
    router = MeshRouter();
    protocolSelector = ProtocolSelector();
    powerManager = PowerManager();
  });

  group('Mesh Router Tests', () {
    test('Should find optimal route between two nodes', () async {
      final source = Node('A', batteryLevel: 0.8, signalStrength: 0.7);
      final destination = Node('B', batteryLevel: 0.9, signalStrength: 0.8);

      final route = await router.findOptimalRoute(source, destination);

      expect(route, isNotNull);
      expect(route.nodes, contains(source));
      expect(route.nodes, contains(destination));
      expect(route.hopCount, lessThanOrEqual(router.maxHops));
    });

    test('Should detect routing loops', () async {
      final source = Node('A', batteryLevel: 0.8, signalStrength: 0.7);
      final destination = Node('A', batteryLevel: 0.8, signalStrength: 0.7);

      expect(() => router.findOptimalRoute(source, destination),
          throwsA(isA<RouteLoopException>()));
    });
  });

  group('Protocol Selector Tests', () {
    test('Should select optimal protocol based on context', () {
      final context = DeviceContext(
          batteryLevel: 0.8,
          signalStrength: 0.7,
          distance: 5.0,
          hasWifi: true,
          hasBluetooth: true);

      final protocol = protocolSelector.selectOptimalProtocol(context);

      expect(protocol, isNotNull);
      expect(protocol, isA<Protocol>());
    });

    test(
        'Should fallback to available protocol when preferred is not available',
        () {
      final context = DeviceContext(
          batteryLevel: 0.8,
          signalStrength: 0.7,
          distance: 5.0,
          hasWifi: false,
          hasBluetooth: true);

      final protocol = protocolSelector.selectOptimalProtocol(context);

      expect(protocol, equals(Protocol.bluetooth));
    });
  });

  group('Power Manager Tests', () {
    test('Should apply power optimizations based on battery level', () async {
      final sample = PowerSample(
          timestamp: DateTime.now(),
          batteryLevel: 0.1,
          powerDraw: 0.5,
          activeProtocols: [Protocol.bluetooth]);

      await powerManager.optimizePowerConsumption();

      // Verify that high-power protocols are disabled
      final activeProtocols = await powerManager.getActiveProtocols();
      expect(activeProtocols, isNot(contains(Protocol.wifiDirect)));
    });
  });
}
