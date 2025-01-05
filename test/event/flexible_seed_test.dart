import 'package:test/test.dart';
import '../../lib/event/flexible_seed_system.dart';

void main() {
  late FlexibleSeedSystem seedSystem;

  setUp(() async {
    seedSystem = FlexibleSeedSystem();
    await seedSystem.initialize();
  });

  group('System Initialization', () {
    test('Should work with single admin/seed', () async {
      // Počni samo sa jednim admin/seedom
      final singleSeed = await PermanentSeed.create(
        userId: 'admin_1',
        isAdmin: true,
      );

      await seedSystem.addPermanentSeed(singleSeed);

      expect(seedSystem.isOperational, isTrue);
      expect(await seedSystem.canHandleTraffic(), isTrue);
    });

    test('Should create temporary seeds when needed', () async {
      // Ne dodajemo permanentne seedove
      expect(seedSystem.temporarySeeds.isNotEmpty, isTrue);
      expect(seedSystem.isOperational, isTrue);
    });

    test('Should maintain fake seeds', () {
      expect(seedSystem.fakeSeeds.length, greaterThanOrEqual(10));
    });
  });

  group('Seed Rotation', () {
    test('Should rotate temporary seeds', () async {
      final initialSeeds = [...seedSystem.temporarySeeds.values];

      // Sačekaj rotaciju
      await Future.delayed(FlexibleSeedSystem.TEMP_SEED_ROTATION);

      final newSeeds = [...seedSystem.temporarySeeds.values];
      expect(newSeeds, isNot(equals(initialSeeds)));
    });

    test('Should rotate fake seeds more frequently', () async {
      final initialFakes = [...seedSystem.fakeSeeds.values];

      // Sačekaj rotaciju
      await Future.delayed(FlexibleSeedSystem.FAKE_SEED_ROTATION);

      final newFakes = [...seedSystem.fakeSeeds.values];
      expect(newFakes, isNot(equals(initialFakes)));
    });
  });

  group('System Adaptation', () {
    test('Should gradually replace temporary seeds', () async {
      // Dodaj permanentne seedove postepeno
      for (var i = 0; i < 5; i++) {
        await seedSystem.addPermanentSeed(
          await PermanentSeed.create(userId: 'permanent_$i'),
        );
      }

      // Broj privremenih seedova bi trebalo da se smanji
      expect(
        seedSystem.temporarySeeds.length,
        lessThan(seedSystem.initialTemporaryCount),
      );
    });

    test('Should maintain minimum operational capacity', () async {
      // Simuliraj pad nekoliko seedova
      await _simulateSeedFailures(count: 5);

      // Sistem bi trebalo da ostane operativan
      expect(seedSystem.isOperational, isTrue);
      expect(
        await seedSystem.getOperationalCapacity(),
        greaterThanOrEqual(0.8), // min 80%
      );
    });
  });

  group('Security', () {
    test('Should detect fake seed tampering', () async {
      // Pokušaj manipulacije lažnim seedom
      await _attemptFakeSeedTampering();

      // Sistem bi trebalo da detektuje i prijavi pokušaj
      expect(seedSystem.securityBreaches.length, equals(1));
    });

    test('Should validate temporary seeds', () async {
      // Pokušaj dodavanja nevalidnog privremenog seeda
      expect(
        () => seedSystem.addTemporarySeed(invalidSeed),
        throwsA(isA<SeedException>()),
      );
    });
  });
}
