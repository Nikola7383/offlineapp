import 'package:test/test.dart';
import '../../../lib/mesh/monitoring/anomaly_detector.dart';

void main() {
  late AnomalyDetector detector;

  setUp(() {
    detector = AnomalyDetector();
  });

  group('Model Initialization', () {
    test('Should initialize models', () async {
      expect(detector, isNotNull);

      // Proveri da li se modeli inicijalizuju
      final metrics = _NetworkMetrics(
        messageCount: 100,
        avgMessageSize: 256,
        messageFrequency: 10,
        uniqueNodes: 5,
        networkDensity: 0.8,
        failedAttempts: 0,
        batteryLevel: 0.9,
        signalStrength: 0.85,
        honeypotHits: 0,
      );

      final score = await detector.analyzeMetrics(metrics);
      expect(score, isNotNull);
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(1));
    });
  });

  group('Anomaly Detection', () {
    test('Should detect normal behavior', () async {
      // Simuliraj normalno ponašanje
      final normalMetrics = _NetworkMetrics(
        messageCount: 100,
        avgMessageSize: 256,
        messageFrequency: 10,
        uniqueNodes: 5,
        networkDensity: 0.8,
        failedAttempts: 0,
        batteryLevel: 0.9,
        signalStrength: 0.85,
        honeypotHits: 0,
      );

      final score = await detector.analyzeMetrics(normalMetrics);
      expect(detector.isAnomaly(score), isFalse);
    });

    test('Should detect anomalous behavior', () async {
      // Simuliraj anomaliju
      final anomalousMetrics = _NetworkMetrics(
        messageCount: 1000000, // Ekstremno visok broj poruka
        avgMessageSize: 9999999, // Neuobičajena veličina
        messageFrequency: 1000, // Previsoka frekvencija
        uniqueNodes: 1, // Premalo čvorova
        networkDensity: 0.1, // Preniska gustina
        failedAttempts: 100, // Mnogo neuspelih pokušaja
        batteryLevel: 0.1, // Kritičan nivo baterije
        signalStrength: 0.1, // Slab signal
        honeypotHits: 50, // Mnogo honeypot pogodaka
      );

      final score = await detector.analyzeMetrics(anomalousMetrics);
      expect(score, greaterThan(AnomalyDetector.ANOMALY_THRESHOLD));
      expect(detector.isAnomaly(score), isTrue);
    });
  });

  group('Model Training', () {
    test('Should retrain models with new data', () async {
      // Dodaj nekoliko normalnih metrika
      for (var i = 0; i < 10; i++) {
        await detector.analyzeMetrics(_NetworkMetrics(
          messageCount: 100 + i,
          avgMessageSize: 256,
          messageFrequency: 10,
          uniqueNodes: 5,
          networkDensity: 0.8,
          failedAttempts: 0,
          batteryLevel: 0.9,
          signalStrength: 0.85,
          honeypotHits: 0,
        ));
      }

      // Proveri da li model prepoznaje slične metrike kao normalne
      final similarMetrics = _NetworkMetrics(
        messageCount: 105,
        avgMessageSize: 260,
        messageFrequency: 11,
        uniqueNodes: 6,
        networkDensity: 0.75,
        failedAttempts: 1,
        batteryLevel: 0.85,
        signalStrength: 0.8,
        honeypotHits: 1,
      );

      final score = await detector.analyzeMetrics(similarMetrics);
      expect(detector.isAnomaly(score), isFalse);
    });
  });
}
