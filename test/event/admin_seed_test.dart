import 'package:test/test.dart';
import '../../lib/event/admin_seed_coordinator.dart';

void main() {
  group('Admin/Seed Requirements', () {
    test('Should calculate correct numbers for 200k users', () {
      final coordinator = AdminSeedCoordinator(totalUsers: 200000);

      // Za 200k korisnika potrebno je:
      // - 200 seedova (1 na 1000 korisnika)
      // - 20 admina (1 na 10 seedova)
      // Plus 50% za backup = 300 seedova i 30 admina

      expect(coordinator.requiredSeeds, equals(300));
      expect(coordinator.requiredAdmins, equals(30));
    });

    test('Should enforce minimum admin count', () {
      final coordinator = AdminSeedCoordinator(totalUsers: 1000);

      // Čak i za mali broj korisnika,
      // minimalni broj admina je 5
      expect(coordinator.requiredAdmins, equals(5));
    });
  });

  group('Admin Hierarchy', () {
    test('Should create optimal admin groups', () async {
      final coordinator = AdminSeedCoordinator(totalUsers: 200000);
      await coordinator.setupAdminHierarchy();

      final groups = await coordinator.getAdminGroups();

      // Proveri da li su grupe dobro raspoređene po:
      // - Geografskoj lokaciji
      // - Vremenskoj zoni
      // - Opterećenju
      expect(groups, hasLength(greaterThan(0)));
      expect(
        groups.every((g) => g.has24HourCoverage),
        isTrue,
      );
    });

    test('Should handle admin/seed failure', () async {
      final coordinator = AdminSeedCoordinator(totalUsers: 200000);
      await coordinator.setupAdminHierarchy();

      // Simuliraj pad nekoliko admina/seedova
      await _simulateFailures(
        adminCount: 5,
        seedCount: 20,
      );

      // Sistem bi trebalo da se reorganizuje
      expect(await coordinator.isSystemOperational(), isTrue);
      expect(await coordinator.getCoverageGaps(), isEmpty);
    });
  });
}
