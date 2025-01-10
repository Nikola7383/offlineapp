import 'dart:async';
import 'dart:io';
import 'dart:isolate';

/// Tip bezbednosne pretnje
enum ThreatType {
  maliciousTraffic,
  unauthorizedAccess,
  dataLeakage,
  denialOfService,
  anomaly,
  other,
}

/// Nivo ozbiljnosti pretnje
enum ThreatSeverity {
  low,
  medium,
  high,
  critical,
}

/// Konfiguracija za security scanner
class SecurityScannerConfig {
  final Duration scanInterval;
  final List<ThreatType> threatsToScan;
  final bool deepScan;
  final Map<String, dynamic>? customRules;

  const SecurityScannerConfig({
    this.scanInterval = const Duration(minutes: 5),
    this.threatsToScan = const [
      ThreatType.maliciousTraffic,
      ThreatType.unauthorizedAccess,
      ThreatType.dataLeakage,
      ThreatType.denialOfService,
      ThreatType.anomaly,
    ],
    this.deepScan = false,
    this.customRules,
  });

  Map<String, dynamic> toJson() => {
        'scanInterval': scanInterval.inMilliseconds,
        'threatsToScan': threatsToScan.map((t) => t.toString()).toList(),
        'deepScan': deepScan,
        'customRules': customRules,
      };

  factory SecurityScannerConfig.fromJson(Map<String, dynamic> json) {
    return SecurityScannerConfig(
      scanInterval: Duration(milliseconds: json['scanInterval'] as int),
      threatsToScan: (json['threatsToScan'] as List)
          .map((t) => ThreatType.values.firstWhere(
                (e) => e.toString() == t,
                orElse: () => ThreatType.other,
              ))
          .toList(),
      deepScan: json['deepScan'] as bool,
      customRules: json['customRules'] as Map<String, dynamic>?,
    );
  }
}

/// Informacije o detektovanoj pretnji
class ThreatInfo {
  final ThreatType type;
  final ThreatSeverity severity;
  final String description;
  final Map<String, dynamic> details;
  final DateTime detectedAt;
  final String? sourceIp;
  final int? sourcePort;
  final String? destinationIp;
  final int? destinationPort;

  const ThreatInfo({
    required this.type,
    required this.severity,
    required this.description,
    required this.details,
    required this.detectedAt,
    this.sourceIp,
    this.sourcePort,
    this.destinationIp,
    this.destinationPort,
  });

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'severity': severity.toString(),
        'description': description,
        'details': details,
        'detectedAt': detectedAt.toIso8601String(),
        'sourceIp': sourceIp,
        'sourcePort': sourcePort,
        'destinationIp': destinationIp,
        'destinationPort': destinationPort,
      };
}

/// Apstraktna klasa za skeniranje pretnji
abstract class ThreatScanner {
  Future<List<ThreatInfo>> scanForThreatType(ThreatType type);
}

/// Implementacija skeniranja pretnji
class ThreatScannerImpl implements ThreatScanner {
  @override
  Future<List<ThreatInfo>> scanForThreatType(ThreatType type) async {
    // TODO: Implementirati stvarno skeniranje za svaki tip pretnje
    // Ovo je mock implementacija
    final threats = <ThreatInfo>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    if (random % 10 == 0) {
      threats.add(ThreatInfo(
        type: type,
        severity: ThreatSeverity.values[random % ThreatSeverity.values.length],
        description: 'Detektovana potencijalna pretnja tipa ${type.toString()}',
        details: {
          'confidence': (random % 100) / 100.0,
          'indicators': ['indicator1', 'indicator2'],
        },
        detectedAt: DateTime.now(),
        sourceIp: '192.168.1.${random % 255}',
        sourcePort: 1000 + (random % 9000),
        destinationIp: '10.0.0.${random % 255}',
        destinationPort: 1000 + (random % 9000),
      ));
    }

    return threats;
  }
}

/// Skenira mrežu i sistem za bezbednosne pretnje
class SecurityScanner {
  final SendPort sendPort;
  final SecurityScannerConfig config;
  final ThreatScanner threatScanner;
  Timer? scanTimer;
  bool isRunning = false;
  bool _throwError = false;

  SecurityScanner(
    this.sendPort,
    Map<String, dynamic> configMap, {
    ThreatScanner? threatScanner,
  })  : config = SecurityScannerConfig.fromJson(configMap),
        threatScanner = threatScanner ?? ThreatScannerImpl();

  /// Postavlja flag za simulaciju greške (samo za testiranje)
  set throwError(bool value) => _throwError = value;

  /// Pokreće skeniranje
  void start() {
    if (isRunning) return;
    isRunning = true;

    // Pokreni inicijalno skeniranje
    scanAndReport();

    // Podesi periodično skeniranje
    scanTimer = Timer.periodic(config.scanInterval, (_) {
      scanAndReport();
    });
  }

  /// Zaustavlja skeniranje
  void stop() {
    isRunning = false;
    scanTimer?.cancel();
    scanTimer = null;
  }

  /// Izvršava skeniranje i šalje izveštaj
  Future<void> scanAndReport() async {
    try {
      if (_throwError) {
        throw Exception('Test error');
      }

      final threats = await scanForThreats();
      if (threats.isNotEmpty) {
        sendPort.send({
          'type': 'threats',
          'data': threats.map((t) => t.toJson()).toList(),
        });
      }
    } catch (e) {
      sendPort.send({
        'type': 'error',
        'message': 'Greška prilikom skeniranja: $e',
      });
    }
  }

  /// Skenira sistem za pretnje
  Future<List<ThreatInfo>> scanForThreats() async {
    final threats = <ThreatInfo>[];

    for (final threatType in config.threatsToScan) {
      try {
        final detectedThreats =
            await threatScanner.scanForThreatType(threatType);
        threats.addAll(detectedThreats);
      } catch (e) {
        print('Greška prilikom skeniranja za $threatType: $e');
      }
    }

    return threats;
  }
}

/// Mock implementacija skeniranja pretnji za testiranje
class MockThreatScanner implements ThreatScanner {
  final List<ThreatInfo> mockThreats;

  MockThreatScanner(this.mockThreats);

  @override
  Future<List<ThreatInfo>> scanForThreatType(ThreatType type) async {
    return mockThreats.where((t) => t.type == type).toList();
  }
}

/// Pokreće security scanner u isolate-u
void startSecurityScanner(Map<String, dynamic> message) {
  final sendPort = message['sendPort'] as SendPort;
  final config = message['config'] as Map<String, dynamic>;

  final scanner = SecurityScanner(sendPort, config);
  scanner.start();

  // Slušaj komande
  final receivePort = ReceivePort();
  sendPort.send({'type': 'ready', 'port': receivePort.sendPort});

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      switch (message['command']) {
        case 'stop':
          scanner.stop();
          receivePort.close();
          break;
        case 'scan_now':
          scanner.scanAndReport();
          break;
      }
    }
  });
}
