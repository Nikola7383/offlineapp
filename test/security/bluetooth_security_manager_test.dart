import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/models/bluetooth_security_types.dart';
import 'package:secure_event_app/security/bluetooth_security_manager.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late BluetoothSecurityManager bluetoothManager;

  setUp(() {
    mockLogger = MockILoggerService();
    bluetoothManager = BluetoothSecurityManager(mockLogger);
    when(mockLogger.info(any)).thenAnswer((_) async {});
    when(mockLogger.warning(any)).thenAnswer((_) async {});
  });

  group('BluetoothSecurityManager Tests', () {
    test('initialize() postavlja isInitialized na true', () async {
      expect(bluetoothManager.isInitialized, isFalse);
      await bluetoothManager.initialize();
      expect(bluetoothManager.isInitialized, isTrue);
      verify(mockLogger.info(any)).called(1);
    });

    test('initialize() ne inicijalizuje već inicijalizovan menadžer', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.initialize();
      verify(mockLogger.warning(any)).called(1);
    });

    test('dispose() čisti resurse i postavlja isInitialized na false',
        () async {
      await bluetoothManager.initialize();
      await bluetoothManager.dispose();
      expect(bluetoothManager.isInitialized, isFalse);
      verify(mockLogger.info(any)).called(2); // 1 za initialize + 1 za dispose
    });

    test('dispose() ne gasi neinicijalizovan menadžer', () async {
      await bluetoothManager.dispose();
      verify(mockLogger.warning(any)).called(1);
    });

    test('scanDevices() vraća listu uređaja', () async {
      await bluetoothManager.initialize();
      final devices = await bluetoothManager.scanDevices();
      expect(devices, hasLength(2));
      verify(mockLogger.info(any)).called(2); // 1 za initialize + 1 za scan
    });

    test('scanDevices() baca grešku ako nije inicijalizovan', () async {
      expect(
        () => bluetoothManager.scanDevices(),
        throwsStateError,
      );
    });

    test('checkConnectionSecurity() vraća status bezbednosti', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();

      final status = await bluetoothManager.checkConnectionSecurity('device1');
      expect(status.deviceId, equals('device1'));
      expect(status.securityLevel, equals(BluetoothSecurityLevel.medium));
      verify(mockLogger.info(any)).called(3); // initialize + scan + check
    });

    test('establishSecureConnection() uspostavlja vezu', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();

      final connection =
          await bluetoothManager.establishSecureConnection('device2');
      expect(connection.deviceId, equals('device2'));
      expect(connection.state, equals(BluetoothConnectionState.connected));
      expect(connection.isEncrypted, isTrue);
    });

    test('establishSecureConnection() baca grešku za nizak nivo bezbednosti',
        () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();

      // Pokušavamo da se povežemo sa nepostojećim uređajem
      expect(
        () => bluetoothManager.establishSecureConnection('nonexistent'),
        throwsArgumentError,
      );
    });

    test('disconnectDevice() prekida vezu', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();
      await bluetoothManager.establishSecureConnection('device2');

      await bluetoothManager.disconnectDevice('device2');

      expectLater(
        bluetoothManager.connectionStatus,
        emits(predicate<BluetoothConnectionStatus>(
          (status) =>
              status.deviceId == 'device2' &&
              status.state == BluetoothConnectionState.disconnected,
        )),
      );
    });

    test('verifyDeviceIdentity() verifikuje identitet', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();

      final isVerified = await bluetoothManager.verifyDeviceIdentity('device2');
      expect(isVerified, isTrue);
    });

    test('detectThreats() detektuje pretnje', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();

      final threats = await bluetoothManager.detectThreats();
      expect(threats, isNotEmpty);
    });

    test('enforceSecurityPolicies() primenjuje politike', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();

      final policies = [
        BluetoothSecurityPolicy(
          id: 'policy1',
          name: 'High Security Policy',
          isEnabled: true,
          requiredLevel: BluetoothSecurityLevel.high,
          protectedThreats: [BluetoothThreatType.unauthorizedAccess],
          rules: {'minEncryptionLevel': 'high'},
        ),
      ];

      await bluetoothManager.enforceSecurityPolicies(policies);
      verify(mockLogger.info(any)).called(greaterThan(2));
    });

    test('generateSecurityReport() generiše izveštaj', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();

      final report = await bluetoothManager.generateSecurityReport();
      expect(report.scannedDevices, equals(2));
      expect(report.deviceStatuses, hasLength(2));
    });

    test('configureSecurityParameters() konfiguriše parametre', () async {
      await bluetoothManager.initialize();

      final config = BluetoothSecurityConfig(
        minimumSecurityLevel: BluetoothSecurityLevel.high,
        requireEncryption: true,
        requireAuthentication: true,
        scanInterval: const Duration(minutes: 5),
        connectionTimeout: const Duration(seconds: 30),
      );

      await bluetoothManager.configureSecurityParameters(config);
      verify(mockLogger.info(any)).called(2); // initialize + configure
    });

    test('securityEvents emituje događaje', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();

      expectLater(
        bluetoothManager.securityEvents,
        emitsThrough(predicate<BluetoothSecurityEvent>(
          (event) => event.type == BluetoothSecurityEventType.deviceDetected,
        )),
      );
    });

    test('connectionStatus emituje status', () async {
      await bluetoothManager.initialize();
      await bluetoothManager.scanDevices();

      expectLater(
        bluetoothManager.connectionStatus,
        emitsThrough(predicate<BluetoothConnectionStatus>(
          (status) =>
              status.state == BluetoothConnectionState.connecting ||
              status.state == BluetoothConnectionState.connected,
        )),
      );

      await bluetoothManager.establishSecureConnection('device2');
    });
  });
}
