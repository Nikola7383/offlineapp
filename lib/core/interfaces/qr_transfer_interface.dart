import 'base_service.dart';
import '../../models/seed.dart';
import '../../models/qr_options.dart';
import 'sound_transfer_interface.dart';

abstract class IQrTransferManager implements IService {
  Future<TransferResult> transferSeed(
    Seed seed, {
    required QrOptions options,
  });

  Future<void> stopTransfer();
  Future<bool> isTransferInProgress();
  Stream<TransferProgress> get transferProgress;
  Future<String> generateQrCode(Seed seed);
  Future<bool> validateQrCode(String qrData);
}
