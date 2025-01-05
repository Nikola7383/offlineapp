import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  late Logger _logger;
  File? _logFile;

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/logs/glasnik.log');

    await _logFile!.parent.create(recursive: true);

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: _logFile!),
      ]),
    );
  }

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }
}

class FileOutput extends LogOutput {
  final File file;

  FileOutput({required this.file});

  @override
  void output(OutputEvent event) async {
    final formattedMessage = event.lines.join('\n');
    await file.writeAsString(
      '$formattedMessage\n',
      mode: FileMode.append,
    );
  }
}

class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      // ignore: avoid_print
      print(line);
    }
  }
}

abstract class LogOutput {
  void output(OutputEvent event);
}

class OutputEvent {
  final List<String> lines;
  OutputEvent(this.lines);
}
