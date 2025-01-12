import 'package:secure_event_app/core/interfaces/base_service.dart';
import '../../models/biometric_types.dart';

abstract class IBiometricManager implements IService {
  /// Proverava da li je biometrijska autentifikacija dostupna na uređaju
  Future<BiometricAvailability> checkAvailability();

  /// Proverava koje vrste biometrijske autentifikacije su podržane
  Future<List<BiometricType>> getSupportedBiometrics();

  /// Registruje biometrijske podatke za korisnika
  Future<BiometricEnrollResult> enrollBiometrics({
    required String userId,
    required BiometricType type,
    BiometricEnrollOptions? options,
  });

  /// Verifikuje biometrijske podatke korisnika
  Future<BiometricVerificationResult> verifyBiometrics({
    required String userId,
    required BiometricType type,
    BiometricVerificationOptions? options,
  });

  /// Uklanja biometrijske podatke korisnika
  Future<void> removeBiometrics({
    required String userId,
    BiometricType? type,
  });

  /// Generiše izveštaj o biometrijskoj autentifikaciji
  Future<BiometricReport> generateReport({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Konfiguriše parametre biometrijske autentifikacije
  Future<void> configure(BiometricConfig config);

  /// Stream za praćenje biometrijskih događaja
  Stream<BiometricEvent> get biometricEvents;

  /// Stream za praćenje statusa biometrijske autentifikacije
  Stream<BiometricStatus> get biometricStatus;
}
