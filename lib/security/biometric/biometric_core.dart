import 'package:local_auth/local_auth.dart';
import 'dart:async';

class BiometricCore {
  static final BiometricCore _instance = BiometricCore._internal();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Map<String, DateTime> _lastValidations = {};
  final Duration _validationTimeout = Duration(minutes: 15);

  factory BiometricCore() {
    return _instance;
  }

  BiometricCore._internal();

  Future<bool> validateBiometric(SecurityLevel level) async {
    try {
      if (!await _localAuth.canCheckBiometrics) {
        return false;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return false;
      }

      String reason;
      bool strongAuth;

      switch (level) {
        case SecurityLevel.maximum:
          reason = 'Potrebna je biometrijska potvrda za kritičnu operaciju';
          strongAuth = true;
          break;
        case SecurityLevel.high:
          reason = 'Potrebna je biometrijska potvrda za admin operaciju';
          strongAuth = true;
          break;
        default:
          reason = 'Potrebna je biometrijska potvrda';
          strongAuth = false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: strongAuth,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        _lastValidations[level.toString()] = DateTime.now();
      }

      return authenticated;
    } catch (e) {
      return false;
    }
  }

  bool isValidationValid(SecurityLevel level) {
    final lastValidation = _lastValidations[level.toString()];
    if (lastValidation == null) return false;

    return DateTime.now().difference(lastValidation) < _validationTimeout;
  }

  Future<bool> requiresRevalidation(SecurityLevel level) async {
    if (!isValidationValid(level)) {
      return await validateBiometric(level);
    }
    return true;
  }
}
