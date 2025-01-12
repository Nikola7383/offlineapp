import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/logger_service.dart';
import 'package:secure_event_app/core/services/logger_service.dart';
import 'package:secure_event_app/core/storage/secure_storage.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late LoggerService loggerService;
  late MockSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockSecureStorage();
    loggerService = LoggerService(mockStorage);
  });

  group('LoggerService', () {
    test('should initialize without errors', () async {
      await loggerService.initialize();
      // Nema potrebe za verifikacijom jer initialize ne radi ništa
    });

    test('should log debug message', () async {
      when(mockStorage.read('app_logs')).thenAnswer((_) async => '[]');

      loggerService.debug('Test debug message');

      verify(mockStorage.write('app_logs', any)).called(1);
    });

    test('should log info message', () async {
      when(mockStorage.read('app_logs')).thenAnswer((_) async => '[]');

      loggerService.info('Test info message');

      verify(mockStorage.write('app_logs', any)).called(1);
    });

    test('should log warning message', () async {
      when(mockStorage.read('app_logs')).thenAnswer((_) async => '[]');

      loggerService.warning('Test warning message');

      verify(mockStorage.write('app_logs', any)).called(1);
    });

    test('should log error message with stack trace', () async {
      when(mockStorage.read('app_logs')).thenAnswer((_) async => '[]');

      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      loggerService.error('Test error message', error, stackTrace);

      verify(mockStorage.write('app_logs', any)).called(1);
    });

    test('should log critical message', () async {
      when(mockStorage.read('app_logs')).thenAnswer((_) async => '[]');

      loggerService.critical('Test critical message');

      verify(mockStorage.write('app_logs', any)).called(1);
    });

    test('should get empty logs when storage is empty', () async {
      when(mockStorage.read('app_logs')).thenAnswer((_) async => '[]');

      final logs = await loggerService.getLogs();

      expect(logs, isEmpty);
    });

    test('should get logs from storage', () async {
      final testLogs = [
        {
          'timestamp': '2024-01-01T00:00:00.000Z',
          'level': 'INFO',
          'message': 'Test message',
          'error': '',
          'stackTrace': ''
        }
      ];

      when(mockStorage.read('app_logs'))
          .thenAnswer((_) async => jsonEncode(testLogs));

      final logs = await loggerService.getLogs();

      expect(logs, equals(testLogs));
    });

    test('should limit logs to 1000 entries', () async {
      when(mockStorage.read('app_logs')).thenAnswer((_) async => '[]');

      // Generišemo 1001 log
      final logs = List.generate(
          1001,
          (i) => {
                'timestamp': DateTime.now().toIso8601String(),
                'level': 'INFO',
                'message': 'Test message $i',
                'error': '',
                'stackTrace': ''
              });

      when(mockStorage.read('app_logs'))
          .thenAnswer((_) async => jsonEncode(logs));

      loggerService.info('New test message');

      verify(mockStorage.write('app_logs', any)).called(1);

      // Verifikujemo da je pozvan write sa listom koja ima tačno 1000 elemenata
      final captured = verify(mockStorage.write('app_logs', captureAny))
          .captured
          .single as String;
      final savedLogs = jsonDecode(captured) as List;
      expect(savedLogs.length, equals(1000));
    });
  });
}
