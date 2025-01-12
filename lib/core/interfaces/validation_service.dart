import 'base_service.dart';

/// Interfejs za validaciju
abstract class IValidationService implements IService {
  /// Validira vrednost prema pravilu
  ValidationResult validate<T>(T value, ValidationRule<T> rule);

  /// Validira vrednost prema više pravila
  ValidationResult validateAll<T>(T value, List<ValidationRule<T>> rules);

  /// Registruje novo pravilo
  void registerRule<T>(ValidationRule<T> rule);

  /// Uklanja pravilo
  void removeRule<T>(String ruleId);

  /// Vraća sva registrovana pravila
  List<ValidationRule> getRules();
}

/// Interfejs za validaciono pravilo
abstract class ValidationRule<T> {
  /// ID pravila
  String get id;

  /// Opis pravila
  String get description;

  /// Validira vrednost
  ValidationResult validate(T value);
}

/// Rezultat validacije
class ValidationResult {
  /// Da li je validacija uspešna
  final bool isValid;

  /// Lista grešaka
  final List<ValidationError> errors;

  /// Kreira novi rezultat validacije
  ValidationResult({
    required this.isValid,
    this.errors = const [],
  });
}

/// Greška validacije
class ValidationError {
  /// ID pravila koje je generisalo grešku
  final String ruleId;

  /// Poruka o grešci
  final String message;

  /// Kreira novu grešku validacije
  ValidationError({
    required this.ruleId,
    required this.message,
  });
}
