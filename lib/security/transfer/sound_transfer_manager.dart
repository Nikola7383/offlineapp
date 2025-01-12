import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../core/interfaces/sound_transfer_interface.dart';
import '../../core/interfaces/logger_service_interface.dart';
import '../../models/seed.dart';
import '../../models/transfer_options.dart';

@singleton
class SoundTransferManager implements ISoundTransferManager {
  final ILoggerService _logger;
  final _progressController = StreamController<TransferProgress>.broadcast();
  bool _isInitialized = false;
  bool _isTransferInProgress = false;

  SoundTransferManager(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('SoundTransferManager already initialized');
      return;
    }

    _logger.info('Initializing SoundTransferManager');
    _isInitialized = true;
    _logger.info('SoundTransferManager initialized');
  }

  @override
  Future<TransferResult> transferSeed(
    Seed seed, {
    required TransferOptions options,
  }) async {
    if (!_isInitialized) {
      return TransferResult.failure(reason: 'Manager not initialized');
    }

    if (_isTransferInProgress) {
      return TransferResult.failure(reason: 'Transfer already in progress');
    }

    try {
      _isTransferInProgress = true;
      _logger.info('Starting sound transfer for seed: ${seed.id}');

      // Simuliramo progres transfera
      for (int i = 0; i <= 100; i += 10) {
        if (!_isTransferInProgress) {
          return TransferResult.failure(reason: 'Transfer cancelled');
        }

        await Future.delayed(Duration(milliseconds: 100));
        _progressController.add(
          TransferProgress(
            percentage: i.toDouble(),
            status: 'Transferring...',
            attempt: options.attempt,
          ),
        );
      }

      _logger.info('Sound transfer completed successfully');
      return TransferResult.success();
    } catch (e) {
      _logger.error('Error during sound transfer: ${e.toString()}');
      return TransferResult.failure(reason: 'Transfer failed: ${e.toString()}');
    } finally {
      _isTransferInProgress = false;
    }
  }

  @override
  Future<void> stopTransfer() async {
    if (_isTransferInProgress) {
      _isTransferInProgress = false;
      _logger.info('Sound transfer stopped');
    }
  }

  @override
  Future<bool> isTransferInProgress() async {
    return _isTransferInProgress;
  }

  @override
  Stream<TransferProgress> get transferProgress => _progressController.stream;

  @override
  Future<void> dispose() async {
    await _progressController.close();
    _isInitialized = false;
    _logger.info('SoundTransferManager disposed');
  }
}
