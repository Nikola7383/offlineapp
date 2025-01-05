import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/ai/local_ai_service.dart';

void main() {
  late LocalAIService ai;

  setUp(() {
    ai = LocalAIService(logger: LoggerService());
  });

  group('Local AI Tests', () {
    test('Should perform message analysis offline', () async {
      final message = Message(
        content: 'Hitno! Sastanak u 15h kod Marka.',
        senderId: 'user1',
        timestamp: DateTime.now(),
      );

      final analysis = await ai.analyzeMessage(message);

      expect(analysis.priority, equals(Priority.high));
      expect(analysis.extractedTime, equals(DateTime.now().copyWith(hour: 15)));
      expect(analysis.entities, contains('Marko'));
    });

    test('Should maintain privacy during analysis', () async {
      final sensitiveData = await ai.checkPrivacyCompliance();

      expect(sensitiveData.dataStaysLocal, isTrue);
      expect(sensitiveData.noExternalCalls, isTrue);
      expect(sensitiveData.modelEncrypted, isTrue);
    });

    test('Should optimize resource usage', () async {
      // Pokreće intenzivnu AI analizu
      final performance = await ai.benchmarkPerformance(
        messageCount: 1000,
        complexity: AnalysisComplexity.high,
      );

      expect(performance.memoryUsage, lessThan(100 * 1024 * 1024)); // Max 100MB
      expect(performance.cpuUsage, lessThan(0.3)); // Max 30% CPU
      expect(performance.batteryImpact, isMinimal);
    });
  });
}
