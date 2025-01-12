import 'package:injectable/injectable.dart';
import '../../core/interfaces/logger_service_interface.dart';
import '../interfaces/security_manager_interface.dart';

@singleton
class UserPreferenceManager implements IUserPreferenceManager {
  final ILoggerService _logger;
  final Map<String, dynamic> _preferences = {};
  bool _initialized = false;

  UserPreferenceManager(this._logger);

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _logger.warning('UserPreferenceManager already initialized');
      return;
    }

    await _loadPreferences();
    _initialized = true;
    _logger.info('UserPreferenceManager initialized');
  }

  @override
  Future<void> dispose() async {
    if (!_initialized) return;

    await _savePreferences();
    _initialized = false;
    _logger.info('UserPreferenceManager disposed');
  }

  @override
  Future<void> savePreference(String key, dynamic value) async {
    if (!_initialized) {
      _logger.warning('Attempting to save preference before initialization');
      return;
    }

    _preferences[key] = value;
    await _savePreferences();
    _logger.info('Saved preference: $key = $value');
  }

  @override
  Future<T?> getPreference<T>(String key) async {
    if (!_initialized) {
      _logger.warning('Attempting to get preference before initialization');
      return null;
    }

    final value = _preferences[key];
    if (value != null && value is! T) {
      _logger.error(
          'Type mismatch for preference $key. Expected $T but got ${value.runtimeType}');
      return null;
    }

    _logger.info('Retrieved preference: $key = $value');
    return value as T?;
  }

  @override
  Future<void> clearPreferences() async {
    if (!_initialized) {
      _logger.warning('Attempting to clear preferences before initialization');
      return;
    }

    _preferences.clear();
    await _savePreferences();
    _logger.info('Cleared all preferences');
  }

  @override
  Future<bool> hasPreference(String key) async {
    if (!_initialized) {
      _logger.warning('Attempting to check preference before initialization');
      return false;
    }

    final exists = _preferences.containsKey(key);
    _logger.info('Checking preference existence: $key = $exists');
    return exists;
  }

  Future<void> _loadPreferences() async {
    // TODO: Implementirati učitavanje preferenci iz storage-a
    _logger.info('Loading preferences from storage');
  }

  Future<void> _savePreferences() async {
    // TODO: Implementirati čuvanje preferenci u storage
    _logger.info('Saving preferences to storage');
  }
}
