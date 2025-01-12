import 'base_service.dart';
import '../../models/seed.dart';
import '../../models/transfer_options.dart';

abstract class ISoundTransferManager implements IService {
  Future<TransferResult> transferSeed(
    Seed seed, {
    required TransferOptions options,
  });

  Future<void> stopTransfer();
  Future<bool> isTransferInProgress();
  Stream<TransferProgress> get transferProgress;
}

class TransferResult {
  final bool isSuccessful;
  final String? reason;
  final DateTime timestamp;

  TransferResult._({
    required this.isSuccessful,
    this.reason,
  }) : timestamp = DateTime.now();

  factory TransferResult.success() => _TransferResultSuccess();
  factory TransferResult.failure({required String reason}) =>
      _TransferResultFailure(reason: reason);

  static Future<TransferResult> asSuccess() async => TransferResult.success();
  static Future<TransferResult> asFailure({required String reason}) async =>
      TransferResult.failure(reason: reason);
}

class _TransferResultSuccess extends TransferResult {
  _TransferResultSuccess() : super._(isSuccessful: true);
}

class _TransferResultFailure extends TransferResult {
  _TransferResultFailure({required String reason})
      : super._(isSuccessful: false, reason: reason);
}

class TransferProgress {
  final double percentage;
  final String status;
  final int attempt;
  final DateTime timestamp;

  TransferProgress({
    required this.percentage,
    required this.status,
    required this.attempt,
  }) : timestamp = DateTime.now();
}
