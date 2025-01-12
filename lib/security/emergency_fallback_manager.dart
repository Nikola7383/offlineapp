import 'package:injectable/injectable.dart';
import '../core/interfaces/base_service.dart';
import '../core/interfaces/logger_service_interface.dart';
import '../core/interfaces/sound_transfer_interface.dart';
import '../core/interfaces/qr_transfer_interface.dart';
import '../core/interfaces/transfer_monitor_interface.dart';
import '../core/interfaces/data_integrity_interface.dart';
import '../core/interfaces/storage_protection_interface.dart';
import '../core/interfaces/database_validator_interface.dart';
import '../core/interfaces/system_state_interface.dart';
import '../core/interfaces/emergency_mode_interface.dart';
import '../models/seed.dart';
import '../models/transfer_options.dart';
import '../models/qr_options.dart';
import '../models/emergency_options.dart';
import '../models/fallback_event.dart';

@singleton
class EmergencyFallbackManager implements IService {
  final ISoundTransferManager _soundTransfer;
  final IQrTransferManager _qrTransfer;
  final ITransferMonitor _transferMonitor;
  final IDataIntegrityGuard _integrityGuard;
  final IStorageProtector _storageProtector;
  final IDatabaseValidator _databaseValidator;
  final ISystemStateManager _stateManager;
  final IEmergencyModeManager _emergencyMode;
  final ILoggerService _logger;

  static const Duration QR_REFRESH_INTERVAL = Duration(seconds: 30);
  static const int MAX_SOUND_ATTEMPTS = 3;

  bool _isInitialized = false;

  @factoryMethod
  EmergencyFallbackManager(
    this._soundTransfer,
    this._qrTransfer,
    this._transferMonitor,
    this._integrityGuard,
    this._storageProtector,
    this._databaseValidator,
    this._stateManager,
    this._emergencyMode,
    this._logger,
  );

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('EmergencyFallbackManager already initialized');
      return;
    }

    _logger.info('Initializing EmergencyFallbackManager');
    await _initializeFallback();
    _isInitialized = true;
    _logger.info('EmergencyFallbackManager initialized');
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) {
      _logger.warning('EmergencyFallbackManager not initialized');
      return;
    }

    _logger.info('Disposing EmergencyFallbackManager');
    await Future.wait([
      _soundTransfer.dispose(),
      _qrTransfer.dispose(),
      _transferMonitor.dispose(),
      _integrityGuard.dispose(),
      _storageProtector.dispose(),
      _databaseValidator.dispose(),
      _stateManager.dispose(),
      _emergencyMode.dispose(),
    ]);
    _isInitialized = false;
    _logger.info('EmergencyFallbackManager disposed');
  }

  Future<void> _initializeFallback() async {
    await Future.wait([
      _soundTransfer.initialize(),
      _qrTransfer.initialize(),
      _transferMonitor.initialize(),
      _integrityGuard.initialize(),
      _storageProtector.initialize(),
      _databaseValidator.initialize(),
      _stateManager.initialize(),
      _emergencyMode.initialize(),
    ]);
  }

  Future<TransferResult> handleSeedTransfer(Seed seed) async {
    try {
      final soundResult = await _attemptSoundTransfer(seed);
      if (soundResult.isSuccessful) {
        return await TransferResult.asSuccess();
      }

      if (await _transferMonitor.shouldSwitchToQr()) {
        return await _switchToQrTransfer(seed);
      }

      return await TransferResult.asFailure(
          reason: 'All transfer methods failed');
    } catch (e) {
      _logger.error('Transfer error: ${e.toString()}');
      return await TransferResult.asFailure(
          reason: 'Error during transfer: ${e.toString()}');
    }
  }

  Future<TransferResult> _attemptSoundTransfer(Seed seed) async {
    for (int attempt = 1; attempt <= MAX_SOUND_ATTEMPTS; attempt++) {
      try {
        final result = await _soundTransfer.transferSeed(
          seed,
          options: TransferOptions(
            attempt: attempt,
            timeout: Duration(minutes: 1),
          ),
        );

        if (result.isSuccessful) {
          return await TransferResult.asSuccess();
        }

        await _transferMonitor.recordAttempt(attempt);
      } catch (e) {
        await _transferMonitor.recordFailure(attempt, e);
      }
    }

    return await TransferResult.asFailure(
        reason: 'Maximum sound transfer attempts reached');
  }

  Future<TransferResult> _switchToQrTransfer(Seed seed) async {
    final result = await _qrTransfer.transferSeed(
      seed,
      options: QrOptions(
        refreshInterval: QR_REFRESH_INTERVAL,
        secureGeneration: true,
        validateTransfer: true,
      ),
    );
    return await TransferResult.asSuccess();
  }

  Future<void> verifyDataIntegrity() async {
    final isValid = await _databaseValidator.validateDatabase();
    if (!isValid) {
      await _handleDataCorruption();
    }
  }

  Future<void> _handleDataCorruption() async {
    await _integrityGuard.protectData();
    await _storageProtector.secureCriticalData();
    await _emergencyMode.activate(
      options: EmergencyOptions(
        preserveEssentialFunctions: true,
        enhancedSecurity: true,
        limitedOperations: true,
      ),
    );
  }

  Future<void> activateEmergencyMode() async {
    await _emergencyMode.activate(
      options: EmergencyOptions(
        preserveEssentialFunctions: true,
        enhancedSecurity: true,
        limitedOperations: true,
      ),
    );
  }

  Stream<FallbackEvent> monitorFallbackSystem() {
    return _transferMonitor.transferEvents
        .where(_isSignificantEvent)
        .map((event) {
      final eventTime = DateTime.now();
      return FallbackEvent(
        id: '${event.type}_${eventTime.millisecondsSinceEpoch}',
        timestamp: eventTime,
        type: _mapEventType(event.type),
        description: 'Transfer event: ${event.type}',
        metadata: event.data,
      );
    });
  }

  bool _isSignificantEvent(TransferEvent event) {
    return event.type == TransferEventType.attemptFailed ||
        event.type == TransferEventType.switchingMethod ||
        event.type == TransferEventType.error;
  }

  FallbackType _mapEventType(TransferEventType type) {
    switch (type) {
      case TransferEventType.attemptFailed:
        return FallbackType.transferFailure;
      case TransferEventType.error:
        return FallbackType.systemError;
      case TransferEventType.switchingMethod:
        return FallbackType.networkIssue;
      default:
        return FallbackType.systemError;
    }
  }
}
