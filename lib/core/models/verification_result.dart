/// Model koji predstavlja rezultat verifikacije
class VerificationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  const VerificationResult({
    required this.isValid,
    this.errorMessage,
    this.data,
  });

  /// Kreira uspešan rezultat sa podacima
  factory VerificationResult.success(Map<String, dynamic> data) {
    return VerificationResult(
      isValid: true,
      data: data,
    );
  }

  /// Kreira neuspešan rezultat sa porukom o grešci
  factory VerificationResult.failure(String message) {
    return VerificationResult(
      isValid: false,
      errorMessage: message,
    );
  }

  @override
  String toString() {
    if (isValid) {
      return 'VerificationResult(valid: true, data: $data)';
    } else {
      return 'VerificationResult(valid: false, error: $errorMessage)';
    }
  }
}
