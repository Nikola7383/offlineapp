import 'package:mockito/annotations.dart';
import 'package:secure_event_app/core/interfaces/logger_service.dart';
import 'package:secure_event_app/core/interfaces/message_service_interface.dart';
import 'package:secure_event_app/core/interfaces/mesh_network_interface.dart';
import 'package:secure_event_app/core/storage/secure_storage.dart';
import 'package:secure_event_app/messaging/encryption/encryption_service.dart';
import 'package:secure_event_app/messaging/verification/message_verification_service.dart';

@GenerateMocks([
  ILoggerService,
  IMessageService,
  IMeshNetwork,
  SecureStorage,
  EncryptionService,
  MessageVerificationService,
])
void main() {}
