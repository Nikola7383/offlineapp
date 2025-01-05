import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:io';
import 'package:secure_event_app/core/media/image_processor.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockFile extends Mock implements File {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late ImageProcessor processor;
  late MockLoggerService mockLogger;

  setUp(() {
    mockLogger = MockLoggerService();
    processor = ImageProcessor(logger: mockLogger);
  });

  group('ImageProcessor Tests', () {
    test('compresses single image successfully', () async {
      final mockFile = MockFile();
      when(mockFile.path).thenReturn('/test/image.jpg');
      when(mockFile.length()).thenAnswer((_) async => 1024 * 1024); // 1MB

      final result = await processor.compressImage(mockFile);

      verify(mockLogger.info(any)).called(1);
      // Note: Actual compression can't be tested in unit tests
      // We're verifying the workflow instead
    });

    test('handles compression failure gracefully', () async {
      final mockFile = MockFile();
      when(mockFile.path).thenReturn('/test/invalid.jpg');
      when(mockFile.length()).thenThrow(Exception('File error'));

      final result = await processor.compressImage(mockFile);

      expect(result, isNull);
      verify(mockLogger.error(any, any)).called(1);
    });

    test('processes batch of images', () async {
      final mockFiles = List.generate(3, (i) {
        final file = MockFile();
        when(file.path).thenReturn('/test/image_$i.jpg');
        when(file.length()).thenAnswer((_) async => 1024 * 1024);
        return file;
      });

      final results = await processor.processBatchImages(mockFiles);

      // Verifikacija da je svaka slika procesirana
      verify(mockLogger.info(any)).called(mockFiles.length);
    });
  });
}
