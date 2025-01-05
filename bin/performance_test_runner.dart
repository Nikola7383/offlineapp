import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import '../test/performance/performance_test.dart' as performance_test;
import '../test/performance/analysis/performance_analyzer.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'analyze',
      abbr: 'a',
      help: 'Analyze results after running tests',
      defaultsTo: true,
    )
    ..addFlag(
      'historical',
      abbr: 'h',
      help: 'Include historical trend analysis',
      defaultsTo: true,
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      help: 'Show detailed output',
      defaultsTo: false,
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output directory for reports',
      defaultsTo: 'test_results',
    );

  try {
    final results = parser.parse(args);
    await runPerformanceTests(
      analyze: results['analyze'],
      includeHistorical: results['historical'],
      verbose: results['verbose'],
      outputDir: results['output'],
    );
  } catch (e) {
    print('Error: $e');
    print('\nUsage:');
    print(parser.usage);
    exit(1);
  }
}

Future<void> runPerformanceTests({
  bool analyze = true,
  bool includeHistorical = true,
  bool verbose = false,
  String outputDir = 'test_results',
}) async {
  print('\n🚀 Starting Performance Tests...\n');
  final stopwatch = Stopwatch()..start();

  try {
    // Ensure output directory exists
    final directory = Directory(outputDir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Run tests
    await performance_test.main();

    if (verbose) {
      print('\nTests completed in ${stopwatch.elapsed.inSeconds} seconds');
    }

    if (analyze) {
      print('\n📊 Analyzing Results...\n');

      final analyzer = PerformanceAnalyzer();
      await analyzer.generateReport(includeHistorical: includeHistorical);

      // Print report
      final reportPath = path.join(outputDir, 'analysis_report.txt');
      final report = await File(reportPath).readAsString();
      print(report);
    }

    print('\n✅ Performance Testing Complete!');

    if (verbose) {
      print('Time taken: ${stopwatch.elapsed.inSeconds} seconds');
      print('Results saved in: $outputDir');
    }
  } catch (e, stackTrace) {
    print('\n❌ Error during performance testing:');
    print(e);
    if (verbose) {
      print('\nStack trace:');
      print(stackTrace);
    }
    exit(1);
  }
}
