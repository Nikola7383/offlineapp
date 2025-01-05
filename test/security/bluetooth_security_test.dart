import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_blue/flutter_blue.dart';

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

class MockBluetoothService extends Mock implements BluetoothService {}

void main() {
  group('Bluetooth Security Tests', () {
    late BluetoothSecurityManager securityManager;
    late MockBluetoothDevice mockDevice;

    setUp(() async {
      securityManager = BluetoothSecurityManager();
      mockDevice = MockBluetoothDevice();

      // Setup mock behavior
      when(mockDevice.id).thenReturn(DeviceIdentifier('test_device'));
      when(mockDevice.state)
          .thenAnswer((_) => Stream.value(BluetoothDeviceState.connected));
    });

    test('Secure Connection Test', () async {
      final result = await securityManager.secureConnect(mockDevice);
      expect(result, isTrue);
    });

    test('Secure Data Transfer Test', () async {
      final testData = [1, 2, 3, 4, 5];

      // Test slanja
      await securityManager.sendSecureData(mockDevice, testData);

      // Test prijema
      final receivedData = await securityManager.receiveSecureData(mockDevice);
      expect(receivedData, equals(testData));
    });

    test('Security Validation Test', () async {
      // Test nevalidnog uređaja
      when(mockDevice.discoverServices())
          .thenAnswer((_) async => [MockBluetoothService()]);

      expect(() => securityManager.secureConnect(mockDevice),
          throwsA(isA<BluetoothSecurityException>()));
    });

    test('Encryption Test', () async {
      final encryption = BluetoothEncryption();
      final testData = [1, 2, 3, 4, 5];

      // Test enkripcije
      final encrypted = await encryption.encryptData(testData);
      expect(encrypted, isNot(equals(testData)));

      // Test dekripcije
      final decrypted = await encryption.decryptData(encrypted);
      expect(decrypted, equals(testData));
    });
  });
}
