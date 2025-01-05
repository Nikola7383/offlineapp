import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/interfaces/message_handler.dart';
import 'package:secure_event_app/core/models/message.dart';

class PerformanceMetrics {
  final Map<String, List<MetricEntry>> _metrics = {};
  final String _reportPath = 'test_results/performance_report.json';

  void recordMetric(String name, double value, String unit) {
    _metrics.putIfAbsent(name, () => []).add(
          MetricEntry(
            timestamp: DateTime.now(),
            value: value,
            unit: unit,
          ),
        );
  }

  Future<int> getCurrentMemoryUsage() async {
    // This is a simplified version, in real world we'd use platform-specific APIs
    return Process.run('ps', ['x', '-o', 'rss']).then((result) {
      final lines = result.stdout.toString().split('\n');
      return int.parse(lines[1].trim()) * 1024; // Convert KB to bytes
    });
  }

  Future<void> waitForProcessing(
    MessageHandler handler,
    int expectedCount, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final completer = Completer<void>();
    var processedCount = 0;

    final subscription = handler.messageStream
        .where((m) => m.status == MessageStatus.sent)
        .listen((message) {
      processedCount++;
      if (processedCount >= expectedCount) {
        completer.complete();
      }
    });

    try {
      await completer.future.timeout(timeout);
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> saveReport() async {
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'metrics': _metrics.map((key, value) => MapEntry(
            key,
            value.map((e) => e.toJson()).toList(),
          )),
    };

    final directory = Directory('test_results');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File(_reportPath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(report),
    );
  }
}

class MetricEntry {
  final DateTime timestamp;
  final double value;
  final String unit;

  MetricEntry({
    required this.timestamp,
    required this.value,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'value': value,
        'unit': unit,
      };
}
