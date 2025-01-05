import 'package:test/test.dart';
import '../../../lib/mesh/routing/mesh_router.dart';
import '../../../lib/mesh/models/node.dart';

void main() {
  late MeshRouter router;

  setUp(() {
    router = MeshRouter();
  });

  group('Route Management', () {
    test('Should add new routes', () {
      final route = RouteInfo(
        sourceId: 'A',
        targetId: 'B',
        path: ['A', 'B'],
        hopCount: 1,
      );

      router.updateRoute(route);
      final found = router.findRoute('A', 'B');

      expect(found, isNotNull);
      expect(found!.hopCount, equals(1));
      expect(found.path, equals(['A', 'B']));
    });

    test('Should update existing routes with better paths', () {
      final route1 = RouteInfo(
        sourceId: 'A',
        targetId: 'B',
        path: ['A', 'C', 'B'],
        hopCount: 2,
      );

      final route2 = RouteInfo(
        sourceId: 'A',
        targetId: 'B',
        path: ['A', 'B'],
        hopCount: 1,
      );

      router.updateRoute(route1);
      router.updateRoute(route2);

      final found = router.findRoute('A', 'B');
      expect(found!.hopCount, equals(1));
      expect(found.path, equals(['A', 'B']));
    });

    test('Should not update routes with worse paths', () {
      final route1 = RouteInfo(
        sourceId: 'A',
        targetId: 'B',
        path: ['A', 'B'],
        hopCount: 1,
      );

      final route2 = RouteInfo(
        sourceId: 'A',
        targetId: 'B',
        path: ['A', 'C', 'D', 'B'],
        hopCount: 3,
      );

      router.updateRoute(route1);
      router.updateRoute(route2);

      final found = router.findRoute('A', 'B');
      expect(found!.hopCount, equals(1));
    });
  });

  group('Route Discovery', () {
    test('Should find existing routes', () {
      final route = RouteInfo(
        sourceId: 'A',
        targetId: 'B',
        path: ['A', 'B'],
        hopCount: 1,
      );

      router.updateRoute(route);
      final found = router.findRoute('A', 'B');

      expect(found, isNotNull);
    });

    test('Should return null for non-existent routes', () {
      final found = router.findRoute('A', 'B');
      expect(found, isNull);
    });

    test('Should handle expired routes', () {
      final route = RouteInfo(
        sourceId: 'A',
        targetId: 'B',
        path: ['A', 'B'],
        hopCount: 1,
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      );

      router.updateRoute(route);
      final found = router.findRoute('A', 'B');

      expect(found, isNull);
    });
  });

  group('Node Updates', () {
    test('Should update routes from available nodes', () {
      final nodes = {
        Node('A', batteryLevel: 1.0, signalStrength: 1.0, managers: {}),
        Node('B', batteryLevel: 1.0, signalStrength: 1.0, managers: {}),
      };

      router.updateFromNodes(nodes);

      final routeAB = router.findRoute('A', 'B');
      expect(routeAB, isNotNull);
      expect(routeAB!.hopCount, equals(1));
    });

    test('Should clear old routes when updating from nodes', () {
      // Dodaj staru rutu
      final oldRoute = RouteInfo(
        sourceId: 'X',
        targetId: 'Y',
        path: ['X', 'Y'],
        hopCount: 1,
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      );
      router.updateRoute(oldRoute);

      // Ažuriraj sa novim čvorovima
      final nodes = {
        Node('A', batteryLevel: 1.0, signalStrength: 1.0, managers: {}),
        Node('B', batteryLevel: 1.0, signalStrength: 1.0, managers: {}),
      };
      router.updateFromNodes(nodes);

      // Stara ruta treba da bude obrisana
      expect(router.findRoute('X', 'Y'), isNull);

      // Nove rute treba da postoje
      expect(router.findRoute('A', 'B'), isNotNull);
    });
  });

  group('Routing Table', () {
    test('Should generate readable routing table', () {
      final routes = [
        RouteInfo(
          sourceId: 'A',
          targetId: 'B',
          path: ['A', 'B'],
          hopCount: 1,
        ),
        RouteInfo(
          sourceId: 'A',
          targetId: 'C',
          path: ['A', 'B', 'C'],
          hopCount: 2,
        ),
      ];

      for (var route in routes) {
        router.updateRoute(route);
      }

      final table = router.generateRoutingTable();

      expect(table, contains('B'));
      expect(table, contains('C'));
      expect(table, contains('1'));
      expect(table, contains('2'));
      expect(table, contains('A -> B'));
      expect(table, contains('A -> B -> C'));
    });
  });

  group('Resource Management', () {
    test('Should clear all routes', () {
      final route = RouteInfo(
        sourceId: 'A',
        targetId: 'B',
        path: ['A', 'B'],
        hopCount: 1,
      );

      router.updateRoute(route);
      router.clear();

      expect(router.findRoute('A', 'B'), isNull);
    });
  });
}
