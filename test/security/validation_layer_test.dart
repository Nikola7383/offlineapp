void main() {
  group('Security Validation Layer Tests', () {
    late SecurityValidationLayer validationLayer;
    late MockOfflineLayer mockOfflineLayer;
    late MockCriticalLayer mockCriticalLayer;
    late MockHardwareValidator mockHardwareValidator;
    late MockBiometricValidator mockBiometricValidator;

    setUp(() {
      mockOfflineLayer = MockOfflineLayer();
      mockCriticalLayer = MockCriticalLayer();
      mockHardwareValidator = MockHardwareValidator();
      mockBiometricValidator = MockBiometricValidator();

      validationLayer = SecurityValidationLayer(
          offlineLayer: mockOfflineLayer, criticalLayer: mockCriticalLayer);
    });

    test('Operation Validation Test', () async {
      final operation = SecurityOperation(
          type: OperationType.authentication,
          data: {'user_id': 'test_user'},
          priority: Priority.high);

      final result = await validationLayer.validateSecurityOperation(operation);

      expect(result.isValid, isTrue);
      expect(result.validations.length, equals(3));
    });

    test('Continuous Validation Test', () async {
      when(mockHardwareValidator.validate())
          .thenAnswer((_) async => ValidationResult(isValid: true));
      when(mockBiometricValidator.validate())
          .thenAnswer((_) async => ValidationResult(isValid: true));

      await validationLayer._setupContinuousValidation();

      await Future.delayed(Duration(minutes: 1));

      verify(mockHardwareValidator.validate()).called(1);
    });

    test('Validation Failure Handling Test', () async {
      final failure = ValidationResult(
          isValid: false,
          source: 'hardware_validator',
          details: {'reason': 'tampering_detected'});

      await validationLayer._handleValidationFailure(failure);

      verify(mockCriticalLayer.handleCriticalEvent(any)).called(1);
    });

    test('Validation Status Monitoring Test', () async {
      final statusStream = validationLayer.monitorValidationStatus();

      await expectLater(
          statusStream,
          emitsThrough(predicate<ValidationStatus>((status) =>
              status.hardware.isValid &&
              status.biometric.isValid &&
              status.integrity.isValid)));
    });

    test('Pre-operation Validation Test', () async {
      final preValidation = await validationLayer._preOperationValidation();

      expect(preValidation.isValid, isTrue);
      verify(mockHardwareValidator.validate()).called(1);
      verify(mockBiometricValidator.validate()).called(1);
    });

    test('Context Validation Test', () async {
      final operation = SecurityOperation(
          type: OperationType.dataAccess,
          data: {'resource': 'secure_file'},
          priority: Priority.critical);

      final contextValidation =
          await validationLayer._validateContext(operation);

      expect(contextValidation.isValid, isTrue);
    });

    test('System State Verification Test', () async {
      final stateVerification =
          await validationLayer._stateVerifier.getStatus();

      expect(stateVerification.isValid, isTrue);
    });
  });
}
