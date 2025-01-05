import 'dart:io';
import 'package:args/args.dart';
import '../test/performance/analysis/performance_analyzer.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'historical',
      abbr: 'h',
      help: 'Include historical trend analysis',
      defaultsTo: true,
    )
    ..addFlag(
      'json',
      abbr: 'j',
      help: 'Output in JSON format',
      defaultsTo: false,
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      help: 'Show detailed output',
      defaultsTo: false,
    )
    ..addOption(
      'metric',
      abbr: 'm',
      help: 'Analyze specific metric only',
    )
    ..addOption(
      'threshold',
      abbr: 't',
      help: 'Performance degradation threshold (percentage)',
      defaultsTo: '10',
    );

  try {
    final results = parser.parse(args);
    await analyzePerformance(
      includeHistorical: results['historical'],
      outputJson: results['json'],
      verbose: results['verbose'],
      specificMetric: results['metric'],
      degradationThreshold: double.parse(results['threshold']),
    );
  } catch (e) {
    print('Error: $e');
    print('\nUsage:');
    print(parser.usage);
    exit(1);
  }
}

Future<void> analyzePerformance({
  bool includeHistorical = true,
  bool outputJson = false,
  bool verbose = false,
  String? specificMetric,
  double degradationThreshold = 10.0,
}) async {
  print('\n📊 Starting Performance Analysis...\n');
  final stopwatch = Stopwatch()..start();

  try {
    final analyzer = PerformanceAnalyzer();
    final report = await analyzer.analyzeLatestReport();

    if (specificMetric != null) {
      final metric = report.metrics[specificMetric];
      if (metric == null) {
        throw ArgumentError('Metric $specificMetric not found in report');
      }
      print('Analysis for $specificMetric:');
      print(metric);
    } else {
      print(report);
    }

    if (includeHistorical) {
      print('\nHistorical Trend Analysis:');
      final historical = await analyzer.analyzeHistoricalTrend();

      for (final historicalReport in historical) {
        if (verbose) {
          print('\nReport from ${historicalReport.timestamp}:');
          print(historicalReport);
        }
      }
    }

    if (verbose) {
      print('\nAnalysis completed in ${stopwatch.elapsed.inSeconds} seconds');
    }
  } catch (e, stackTrace) {
    print('\n❌ Error during analysis:');
    print(e);
    if (verbose) {
      print('\nStack trace:');
      print(stackTrace);
    }
    exit(1);
  }
}
