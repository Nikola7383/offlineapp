class KeyRotationManager {
  static final Duration DEFAULT_KEY_ROTATION = Duration(hours: 4);
  static final Duration MIN_REVALIDATION_TIME = Duration(minutes: 15);
  static final Duration MAX_REVALIDATION_TIME = Duration(hours: 2);

  Future<void> setupCustomValidationTiming(
      String adminId, Duration revalidationTime) async {
    // Admin može podesiti vreme između MIN i MAX
    if (revalidationTime < MIN_REVALIDATION_TIME ||
        revalidationTime > MAX_REVALIDATION_TIME) {
      throw Exception('Invalid revalidation time');
    }

    await _updateValidationTiming(adminId, revalidationTime);
  }
}
