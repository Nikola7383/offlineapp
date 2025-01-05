import 'package:shared_preferences/shared_preferences.dart';
import '../logging/logger_service.dart';

class SettingsService {
  final LoggerService logger;
  late SharedPreferences _prefs;

  SettingsService({required this.logger});

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      logger.error('Failed to initialize settings', e);
    }
  }

  Future<void> setSetting(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      }
    } catch (e) {
      logger.error('Failed to set setting: $key', e);
    }
  }

  T? getSetting<T>(String key) {
    try {
      return _prefs.get(key) as T?;
    } catch (e) {
      logger.error('Failed to get setting: $key', e);
      return null;
    }
  }

  Future<void> removeSetting(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      logger.error('Failed to remove setting: $key', e);
    }
  }

  // Predefinisana podešavanja
  Future<void> setDefaultSettings() async {
    await setSetting('notifications_enabled', true);
    await setSetting('dark_mode', false);
    await setSetting('message_retention_days', 30);
    await setSetting('auto_sync_enabled', true);
    await setSetting('sync_interval_minutes', 15);
  }
}
