import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/security/transfer/sound_transfer_manager.dart';
import '../../lib/models/seed.dart';
import '../../lib/models/transfer_options.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late SoundTransferManager manager;

  setUp(() {
    mockLogger = MockILoggerService();
    manager = SoundTransferManager(mockLogger);
  });

  test('initialize() should set isInitialized to true', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await manager.initialize();

    // Assert
    expect(manager.isInitialized, true);
    verify(mockLogger.info('Initializing SoundTransferManager')).called(1);
    verify(mockLogger.info('SoundTransferManager initialized')).called(1);
  });

  test('initialize() should not initialize twice', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await manager.initialize();
    await manager.initialize();

    // Assert
    verify(mockLogger.warning('SoundTransferManager already initialized'))
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
    final options = TransferOptions(
      attempt: 1,
      timeout: Duration(seconds: 30),
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
    final options = TransferOptions(
      attempt: 1,
      timeout: Duration(seconds: 30),
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
}
