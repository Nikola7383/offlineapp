import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/security/transfer/qr_transfer_manager.dart';
import '../../lib/models/seed.dart';
import '../../lib/models/qr_options.dart';
import '../../lib/core/interfaces/sound_transfer_interface.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late QrTransferManager manager;

  setUp(() {
    mockLogger = MockILoggerService();
    manager = QrTransferManager(mockLogger);
  });

  test('initialize() should set isInitialized to true', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await manager.initialize();

    // Assert
    expect(manager.isInitialized, true);
    verify(mockLogger.info('Initializing QrTransferManager')).called(1);
    verify(mockLogger.info('QrTransferManager initialized')).called(1);
  });

  test('initialize() should not initialize twice', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await manager.initialize();
    await manager.initialize();

    // Assert
    verify(mockLogger.warning('QrTransferManager already initialized'))
        .called(1);
  });

  test('transferSeed() should fail if not initialized', () async {
    // Arrange
    final seed = Seed(
      id: '1',
      timestamp: DateTime.now(),
      data: {},
      hash: 'test_hash',
    );
    final options = QrOptions(
      refreshInterval: Duration(milliseconds: 500),
    );

    // Act
    final result = await manager.transferSeed(seed, options: options);

    // Assert
    expect(result.isSuccessful, false);
    expect(result.reason, 'Manager not initialized');
  });

  test('transferSeed() should not allow concurrent transfers', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    final seed = Seed(
      id: '1',
      timestamp: DateTime.now(),
      data: {},
      hash: 'test_hash',
    );
    final options = QrOptions(
      refreshInterval: Duration(milliseconds: 500),
    );
    await manager.initialize();

    // Act
    final firstTransfer = manager.transferSeed(seed, options: options);
    final secondTransfer = await manager.transferSeed(seed, options: options);

    // Assert
    expect(secondTransfer.isSuccessful, false);
    expect(secondTransfer.reason, 'Transfer already in progress');
    await firstTransfer; // čekamo da se prvi transfer završi
  });

  test('generateQrCode() should create valid QR code', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    final seed = Seed(
      id: '1',
      timestamp: DateTime.now(),
      data: {},
      hash: 'test_hash',
    );
    await manager.initialize();

    // Act
    final qrCode = await manager.generateQrCode(seed);

    // Assert
    expect(qrCode, startsWith('QR_'));
    expect(qrCode.contains(seed.id), true);
  });

  test('validateQrCode() should validate QR code format', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();

    // Act
    final validResult = await manager.validateQrCode('QR_test_123');
    final invalidResult = await manager.validateQrCode('invalid_format');

    // Assert
    expect(validResult, true);
    expect(invalidResult, false);
  });

  test('dispose() should cleanup resources', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();

    // Act
    await manager.dispose();

    // Assert
    expect(manager.isInitialized, false);
    verify(mockLogger.info('QrTransferManager disposed')).called(1);
  });

  test('transferProgress should emit progress events', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    final seed = Seed(
      id: '1',
      timestamp: DateTime.now(),
      data: {},
      hash: 'test_hash',
    );
    final options = QrOptions(
      refreshInterval: Duration(milliseconds: 500),
    );
    await manager.initialize();

    // Act & Assert
    expectLater(
      manager.transferProgress,
      emitsThrough(
        predicate<TransferProgress>((progress) =>
            progress.percentage == 100.0 &&
            progress.status == 'Transferring via QR...' &&
            progress.attempt == 1),
      ),
    );

    // Start transfer to trigger progress events
    await manager.transferSeed(seed, options: options);
  });
}
