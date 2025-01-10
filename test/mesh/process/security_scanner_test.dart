import 'dart:isolate';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/process/security_scanner.dart';

void main() {
  group('SecurityScannerConfig', () {
    test('should create instance with default values', () {
      final config = SecurityScannerConfig();

      expect(config.scanInterval, equals(const Duration(minutes: 5)));
      expect(
        config.threatsToScan,
        equals([
          ThreatType.maliciousTraffic,
          ThreatType.unauthorizedAccess,
          ThreatType.dataLeakage,
          ThreatType.denialOfService,
          ThreatType.anomaly,
        ]),
      );
      expect(config.deepScan, isFalse);
      expect(config.customRules, isNull);
    });

    test('should create instance with custom values', () {
      final customRules = {
        'maxRetries': 3,
        'threshold': 0.75,
      };

      final config = SecurityScannerConfig(
        scanInterval: const Duration(minutes: 10),
        threatsToScan: [ThreatType.maliciousTraffic, ThreatType.dataLeakage],
        deepScan: true,
        customRules: customRules,
      );

      expect(config.scanInterval, equals(const Duration(minutes: 10)));
      expect(
        config.threatsToScan,
        equals([ThreatType.maliciousTraffic, ThreatType.dataLeakage]),
      );
      expect(config.deepScan, isTrue);
      expect(config.customRules, equals(customRules));
    });

    test('should convert to and from JSON', () {
      final customRules = {
        'maxRetries': 3,
        'threshold': 0.75,
      };

      final original = SecurityScannerConfig(
        scanInterval: const Duration(minutes: 10),
        threatsToScan: [ThreatType.maliciousTraffic, ThreatType.dataLeakage],
        deepScan: true,
        customRules: customRules,
      );

      final json = original.toJson();
      final fromJson = SecurityScannerConfig.fromJson(json);

      expect(fromJson.scanInterval, equals(original.scanInterval));
      expect(fromJson.threatsToScan, equals(original.threatsToScan));
      expect(fromJson.deepScan, equals(original.deepScan));
      expect(fromJson.customRules, equals(original.customRules));
    });
  });

  group('ThreatInfo', () {
    test('should create instance with required values', () {
      final now = DateTime.now();
      final details = {
        'confidence': 0.85,
        'indicators': ['indicator1', 'indicator2'],
      };

      final threat = ThreatInfo(
        type: ThreatType.maliciousTraffic,
        severity: ThreatSeverity.high,
        description: 'Test threat',
        details: details,
        detectedAt: now,
      );

      expect(threat.type, equals(ThreatType.maliciousTraffic));
      expect(threat.severity, equals(ThreatSeverity.high));
      expect(threat.description, equals('Test threat'));
      expect(threat.details, equals(details));
      expect(threat.detectedAt, equals(now));
      expect(threat.sourceIp, isNull);
      expect(threat.sourcePort, isNull);
      expect(threat.destinationIp, isNull);
      expect(threat.destinationPort, isNull);
    });

    test('should create instance with all values', () {
      final now = DateTime.now();
      final details = {
        'confidence': 0.85,
        'indicators': ['indicator1', 'indicator2'],
      };

      final threat = ThreatInfo(
        type: ThreatType.maliciousTraffic,
        severity: ThreatSeverity.high,
        description: 'Test threat',
        details: details,
        detectedAt: now,
        sourceIp: '192.168.1.100',
        sourcePort: 12345,
        destinationIp: '10.0.0.1',
        destinationPort: 80,
      );

      expect(threat.type, equals(ThreatType.maliciousTraffic));
      expect(threat.severity, equals(ThreatSeverity.high));
      expect(threat.description, equals('Test threat'));
      expect(threat.details, equals(details));
      expect(threat.detectedAt, equals(now));
      expect(threat.sourceIp, equals('192.168.1.100'));
      expect(threat.sourcePort, equals(12345));
      expect(threat.destinationIp, equals('10.0.0.1'));
      expect(threat.destinationPort, equals(80));
    });

    test('should convert to JSON', () {
      final now = DateTime.now();
      final details = {
        'confidence': 0.85,
        'indicators': ['indicator1', 'indicator2'],
      };

      final threat = ThreatInfo(
        type: ThreatType.maliciousTraffic,
        severity: ThreatSeverity.high,
        description: 'Test threat',
        details: details,
        detectedAt: now,
        sourceIp: '192.168.1.100',
        sourcePort: 12345,
        destinationIp: '10.0.0.1',
        destinationPort: 80,
      );

      final json = threat.toJson();

      expect(json['type'], equals(ThreatType.maliciousTraffic.toString()));
      expect(json['severity'], equals(ThreatSeverity.high.toString()));
      expect(json['description'], equals('Test threat'));
      expect(json['details'], equals(details));
      expect(json['detectedAt'], equals(now.toIso8601String()));
      expect(json['sourceIp'], equals('192.168.1.100'));
      expect(json['sourcePort'], equals(12345));
      expect(json['destinationIp'], equals('10.0.0.1'));
      expect(json['destinationPort'], equals(80));
    });
  });

  group('SecurityScanner', () {
    late ReceivePort receivePort;
    late SecurityScanner scanner;
    late List<ThreatInfo> mockThreats;

    setUp(() {
      receivePort = ReceivePort();
      final now = DateTime.now();

      mockThreats = [
        ThreatInfo(
          type: ThreatType.maliciousTraffic,
          severity: ThreatSeverity.high,
          description: 'Malicious traffic detected',
          details: {
            'confidence': 0.85,
            'indicators': ['indicator1'],
          },
          detectedAt: now,
          sourceIp: '192.168.1.100',
          sourcePort: 12345,
        ),
        ThreatInfo(
          type: ThreatType.dataLeakage,
          severity: ThreatSeverity.critical,
          description: 'Data leakage detected',
          details: {
            'confidence': 0.95,
            'indicators': ['indicator2'],
          },
          detectedAt: now,
          destinationIp: '10.0.0.1',
          destinationPort: 80,
        ),
      ];

      scanner = SecurityScanner(
        receivePort.sendPort,
        SecurityScannerConfig().toJson(),
      );
    });

    tearDown(() {
      scanner.stop();
      receivePort.close();
    });

    test('should start and stop scanning', () async {
      expect(scanner.isRunning, isFalse);
      expect(scanner.scanTimer, isNull);

      scanner.start();
      expect(scanner.isRunning, isTrue);
      expect(scanner.scanTimer, isNotNull);

      scanner.stop();
      expect(scanner.isRunning, isFalse);
      expect(scanner.scanTimer, isNull);
    });

    test('should not start scanning if already running', () {
      scanner.start();
      final timer = scanner.scanTimer;

      scanner.start();
      expect(scanner.scanTimer, equals(timer));
    });

    test('should scan for threats', () async {
      final threats = await scanner.scanForThreats();

      expect(threats, isNotEmpty);
      for (final threat in threats) {
        expect(threat, isA<ThreatInfo>());
        expect(threat.type, isNotNull);
        expect(threat.severity, isNotNull);
        expect(threat.description, isNotEmpty);
        expect(threat.details, isNotEmpty);
        expect(threat.detectedAt, isNotNull);
      }
    });

    test('should filter threats based on config', () async {
      final specificConfig = SecurityScannerConfig(
        threatsToScan: [ThreatType.maliciousTraffic],
      );

      final specificScanner = SecurityScanner(
        receivePort.sendPort,
        specificConfig.toJson(),
      );

      final threats = await specificScanner.scanForThreats();
      for (final threat in threats) {
        expect(threat.type, equals(ThreatType.maliciousTraffic));
      }
    });

    test('should send threats through port', () async {
      final messages = <Map<String, dynamic>>[];
      receivePort.listen((message) {
        if (message is Map<String, dynamic>) {
          messages.add(message);
        }
      });

      await scanner.scanAndReport();

      expect(messages.length, equals(1));
      expect(messages.first['type'], equals('threats'));
      expect(messages.first['data'], isA<List>());
      expect(messages.first['data'], isNotEmpty);
    });

    test('should handle errors gracefully', () async {
      final errorScanner = SecurityScanner(
        receivePort.sendPort,
        SecurityScannerConfig().toJson(),
      )..throwError = true;

      final messages = <Map<String, dynamic>>[];
      receivePort.listen((message) {
        if (message is Map<String, dynamic>) {
          messages.add(message);
        }
      });

      await errorScanner.scanAndReport();

      expect(messages.length, equals(1));
      expect(messages.first['type'], equals('error'));
      expect(messages.first['message'], contains('Test error'));
    });
  });
}
