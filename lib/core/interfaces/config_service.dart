import 'base_service.dart';

/// Interfejs za upravljanje konfiguracijom
abstract class IConfigService implements ISecureService {
  /// Učitava konfiguraciju
  Future<void> load();

  /// Čuva konfiguraciju
  Future<void> save();

  /// Vraća vrednost za dati ključ
  T? get<T>(String key);

  /// Postavlja vrednost za dati ključ
  void set<T>(String key, T value);

  /// Briše vrednost za dati ključ
  void remove(String key);

  /// Vraća sve ključeve
  Set<String> getKeys();

  /// Vraća sve vrednosti kao mapu
  Map<String, dynamic> toMap();

  /// Resetuje konfiguraciju na podrazumevane vrednosti
  Future<void> reset();

  /// Stream za praćenje promena
  Stream<ConfigChange> get changes;
}

/// Interfejs za upravljanje profilima
abstract class IProfileManager implements ISecureService {
  /// Trenutno aktivni profil
  String get activeProfile;

  /// Lista dostupnih profila
  List<String> get availableProfiles;

  /// Aktivira profil
  Future<void> activate(String profile);

  /// Kreira novi profil
  Future<void> create(String profile, Map<String, dynamic> initialConfig);

  /// Briše profil
  Future<void> delete(String profile);

  /// Kopira profil
  Future<void> copy(String source, String destination);

  /// Vraća konfiguraciju za profil
  Future<Map<String, dynamic>> getProfileConfig(String profile);
}

/// Promena konfiguracije
class ConfigChange {
  /// Ključ koji je promenjen
  final String key;

  /// Stara vrednost
  final dynamic oldValue;

  /// Nova vrednost
  final dynamic newValue;

  /// Tip promene
  final ChangeType type;

  /// Vreme promene
  final DateTime timestamp;

  /// Metadata promene
  final Map<String, dynamic> metadata;

  /// Kreira novu promenu konfiguracije
  ConfigChange({
    required this.key,
    this.oldValue,
    this.newValue,
    required this.type,
    required this.timestamp,
    this.metadata = const {},
  });
}

/// Profil konfiguracije
class ConfigProfile {
  /// Ime profila
  final String name;

  /// Opis
  final String description;

  /// Da li je aktivan
  final bool isActive;

  /// Vreme kreiranja
  final DateTime createdAt;

  /// Vreme poslednje izmene
  final DateTime lastModified;

  /// Metadata profila
  final Map<String, dynamic> metadata;

  /// Kreira novi profil konfiguracije
  ConfigProfile({
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.lastModified,
    this.metadata = const {},
  });
}

/// Tip promene konfiguracije
enum ChangeType {
  /// Dodata nova vrednost
  added,

  /// Izmenjena postojeća vrednost
  modified,

  /// Obrisana vrednost
  removed,

  /// Resetovana na podrazumevanu vrednost
  reset
}
