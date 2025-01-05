class EmergencyContactManager {
  // Contact validation
  final PhoneValidator _phoneValidator;
  final ContactVerifier _contactVerifier;
  final DeviceValidator _deviceValidator;

  // Contact management
  final ContactStorage _storage;
  final ContactMasker _masker;
  final ContactSynchronizer _synchronizer;

  // Security
  final ContactSecurity _security;
  final PrivacyGuard _privacyGuard;
  final ContactEncryption _encryption;

  EmergencyContactManager()
      : _phoneValidator = PhoneValidator(),
        _contactVerifier = ContactVerifier(),
        _deviceValidator = DeviceValidator(),
        _storage = ContactStorage(),
        _masker = ContactMasker(),
        _synchronizer = ContactSynchronizer(),
        _security = ContactSecurity(),
        _privacyGuard = PrivacyGuard(),
        _encryption = ContactEncryption() {
    _initializeContactManager();
  }

  Future<bool> validateAndAddContact(String phoneNumber) async {
    try {
      // 1. Validate phone number
      if (!await _phoneValidator.validatePhoneNumber(phoneNumber)) {
        throw ValidationException('Invalid phone number');
      }

      // 2. Verify device ownership
      if (!await _deviceValidator.verifyDeviceOwnership(phoneNumber)) {
        throw SecurityException('Device ownership verification failed');
      }

      // 3. Generate masked ID
      final maskedId = await _masker.generateMaskedId(phoneNumber,
          options: MaskingOptions(secure: true, unique: true));

      // 4. Store contact
      await _storage.storeContact(Contact(
          id: maskedId,
          phoneHash: await _encryption.hashPhoneNumber(phoneNumber),
          timestamp: DateTime.now()));

      return true;
    } catch (e) {
      await _handleContactError(e);
      return false;
    }
  }

  Future<bool> syncContacts(List<String> phoneNumbers) async {
    try {
      // 1. Validate all numbers
      final validNumbers = await Future.wait(phoneNumbers
          .map((number) => _phoneValidator.validatePhoneNumber(number)));

      // 2. Filter existing event participants
      final eventParticipants = await _contactVerifier.filterEventParticipants(
          validNumbers.where((result) => result.isValid).toList());

      // 3. Generate masked IDs
      final maskedContacts = await Future.wait(
          eventParticipants.map((number) => _masker.generateMaskedId(number)));

      // 4. Store and sync
      await _synchronizer.syncContacts(maskedContacts);

      return true;
    } catch (e) {
      await _handleSyncError(e);
      return false;
    }
  }
}
