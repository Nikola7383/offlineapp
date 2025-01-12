import 'package:mockito/annotations.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/core/interfaces/access_control_interface.dart';
import 'package:secure_event_app/core/interfaces/audit_interface.dart';
import 'package:secure_event_app/core/interfaces/bluetooth_security_interface.dart';
import 'package:secure_event_app/core/interfaces/encryption_interface.dart';
import 'package:secure_event_app/core/interfaces/biometric_interface.dart';

@GenerateMocks([
  ILoggerService,
  IAccessControlManager,
  IAuditManager,
  IBluetoothSecurityManager,
  IEncryptionManager,
  IBiometricManager,
])
void main() {}
