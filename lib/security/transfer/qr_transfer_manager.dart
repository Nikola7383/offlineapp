import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../core/interfaces/qr_transfer_interface.dart';
import '../../core/interfaces/logger_service_interface.dart';
import '../../models/seed.dart';
import '../../models/qr_options.dart';
import '../../core/interfaces/sound_transfer_interface.dart';

@singleton
class QrTransferManager implements IQrTransferManager {
  final ILoggerService _logger;
  final _progressController = StreamController<TransferProgress>.broadcast();
  bool _isInitialized = false;
  bool _isTransferInProgress = false;

  QrTransferManager(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('QrTransferManager already initialized');
      return;
    }

    _logger.info('Initializing QrTransferManager');
    _isInitialized = true;
    _logger.info('QrTransferManager initialized');
  }

  @override
  Future<TransferResult> transferSeed(
    Seed seed, {
    required QrOptions options,
  }) async {
    if (!_isInitialized) {
      return TransferResult.failure(reason: 'Manager not initialized');
    }

    if (_isTransferInProgress) {
      return TransferResult.failure(reason: 'Transfer already in progress');
    }

    try {
      _isTransferInProgress = true;
      _logger.info('Starting QR transfer for seed: ${seed.id}');

      final qrCode = await generateQrCode(seed);
      if (!await validateQrCode(qrCode)) {
        return TransferResult.failure(reason: 'QR code validation failed');
      }

      // Simuliramo progres transfera
      for (int i = 0; i <= 100; i += 10) {
        if (!_isTransferInProgress) {
          return TransferResult.failure(reason: 'Transfer cancelled');
        }

        await Future.delayed(Duration(milliseconds: 100));
        _progressController.add(
          TransferProgress(
            percentage: i.toDouble(),
            status: 'Transferring via QR...',
            attempt: 1,
          ),
        );
      }

      _logger.info('QR transfer completed successfully');
      return TransferResult.success();
    } catch (e) {
      _logger.error('Error during QR transfer: ${e.toString()}');
      return TransferResult.failure(reason: 'Transfer failed: ${e.toString()}');
    } finally {
      _isTransferInProgress = false;
    }
  }

  @override
  Future<void> stopTransfer() async {
    if (_isTransferInProgress) {
      _isTransferInProgress = false;
      _logger.info('QR transfer stopped');
    }
  }

  @override
  Future<bool> isTransferInProgress() async {
    return _isTransferInProgress;
  }

  @override
  Stream<TransferProgress> get transferProgress => _progressController.stream;

  @override
  Future<String> generateQrCode(Seed seed) async {
    // Simuliramo generisanje QR koda
    await Future.delayed(Duration(milliseconds: 100));
    return 'QR_${seed.id}_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<bool> validateQrCode(String qrData) async {
    // Simuliramo validaciju QR koda
    await Future.delayed(Duration(milliseconds: 100));
    return qrData.startsWith('QR_');
  }

  @override
  Future<void> dispose() async {
    await _progressController.close();
    _isInitialized = false;
    _logger.info('QrTransferManager disposed');
  }
}
