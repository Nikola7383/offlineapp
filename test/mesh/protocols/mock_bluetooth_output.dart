class MockBluetoothOutput extends Mock implements BluetoothDeviceOutput {
  @override
  Future<void> get allSent => Future.value();
}
