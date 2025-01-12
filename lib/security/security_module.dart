import 'package:injectable/injectable.dart';

import '../core/interfaces/sound_transfer_interface.dart';
import '../core/interfaces/qr_transfer_interface.dart';
import '../core/interfaces/transfer_monitor_interface.dart';
import '../core/interfaces/data_integrity_interface.dart';
import '../core/interfaces/storage_protection_interface.dart';
import '../core/interfaces/database_validator_interface.dart';
import '../core/interfaces/system_state_interface.dart';
import '../core/interfaces/emergency_mode_interface.dart';
import '../core/interfaces/logger_service_interface.dart';

import 'transfer/sound_transfer_manager.dart';
import 'transfer/qr_transfer_manager.dart';
import 'monitoring/transfer_monitor.dart';
import 'integrity/data_integrity_guard.dart';
import 'storage/storage_protector.dart';
import 'database/database_validator.dart';
import 'state/system_state_manager.dart';
import 'emergency/emergency_mode_manager.dart';

@module
abstract class SecurityModule {
  @singleton
  ISoundTransferManager soundTransferManager(
    ILoggerService loggerService,
  ) =>
      SoundTransferManager(loggerService);

  @singleton
  IQrTransferManager qrTransferManager(
    ILoggerService loggerService,
  ) =>
      QrTransferManager(loggerService);

  @singleton
  ITransferMonitor transferMonitor(
    ILoggerService loggerService,
  ) =>
      TransferMonitor(loggerService);

  @singleton
  IDataIntegrityGuard dataIntegrityGuard(
    ILoggerService loggerService,
  ) =>
      DataIntegrityGuard(loggerService);

  @singleton
  IStorageProtector storageProtector(
    ILoggerService loggerService,
  ) =>
      StorageProtector(loggerService);

  @singleton
  IDatabaseValidator databaseValidator(
    ILoggerService loggerService,
  ) =>
      DatabaseValidator(loggerService);

  @singleton
  ISystemStateManager systemStateManager(
    ILoggerService loggerService,
  ) =>
      SystemStateManager(loggerService);

  @singleton
  IEmergencyModeManager emergencyModeManager(
    ILoggerService loggerService,
  ) =>
      EmergencyModeManager(loggerService);
}
