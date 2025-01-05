import 'package:test/test.dart';
import '../../lib/guides/user_guide_system.dart';

void main() {
  late UserGuideSystem guideSystem;
  late MockUser testUser;
  late MockAdmin testAdmin;

  setUp(() {
    guideSystem = UserGuideSystem();
    testUser = MockUser(id: 'test_user');
    testAdmin = MockAdmin(id: 'test_admin');
  });

  group('Basic User Guide', () {
    test('Should show all basic steps', () async {
      final progress = await guideSystem.showBasicGuide(testUser);

      expect(progress.completedSteps, equals(BASIC_GUIDE_STEPS));
      expect(progress.isBasicGuideCompleted, isTrue);
    });

    test('Should save progress', () async {
      await guideSystem.showBasicGuide(testUser);

      final savedProgress = await guideSystem.getUserProgress(testUser);
      expect(savedProgress.isBasicGuideCompleted, isTrue);
    });
  });

  group('Emergency Guide', () {
    test('Should show emergency steps in order', () async {
      final progress = await guideSystem.showEmergencyGuide(testUser);

      expect(progress.steps, hasLength(3));
      expect(progress.steps.first.priority, equals(EmergencyPriority.high));
    });

    test('Should handle interrupted guide', () async {
      // Simuliraj prekid
      await _simulateInterruption();

      final progress = await guideSystem.showEmergencyGuide(testUser);
      expect(progress.wasInterrupted, isTrue);
      expect(progress.canResume, isTrue);
    });
  });

  group('Admin Guide', () {
    test('Should verify admin before showing guide', () async {
      final progress = await guideSystem.showAdminGuide(testAdmin);

      expect(progress.wasVerified, isTrue);
      expect(progress.securityCheckPassed, isTrue);
    });

    test('Should show all admin features', () async {
      final progress = await guideSystem.showAdminGuide(testAdmin);

      expect(progress.demonstratedFeatures, contains('emergency_protocols'));
      expect(progress.demonstratedFeatures, contains('user_management'));
    });
  });

  group('Progress Tracking', () {
    test('Should track user progress', () async {
      await guideSystem.showBasicGuide(testUser);

      final progress = await guideSystem.getUserProgress(testUser);

      expect(progress.completedSteps, isNotEmpty);
      expect(progress.lastCompletedStep, isNotNull);
    });
  });
}
