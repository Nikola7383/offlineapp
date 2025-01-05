import 'package:shared_preferences.dart';
import '../logging/logger_service.dart';

class GuestAuthService {
  final LoggerService _logger;
  final SharedPreferences _prefs;
  static const String _phoneKey = 'user_phone';
  static const String _firstLoginKey = 'first_login_completed';

  GuestAuthService({
    required LoggerService logger,
    required SharedPreferences prefs,
  })  : _logger = logger,
        _prefs = prefs;

  Future<bool> isFirstLogin() async {
    return !(_prefs.getBool(_firstLoginKey) ?? false);
  }

  Future<bool> hasStoredPhone() async {
    return _prefs.getString(_phoneKey) != null;
  }

  Future<bool> registerPhone(String phone) async {
    try {
      await _prefs.setString(_phoneKey, phone);
      await _prefs.setBool(_firstLoginKey, true);
      _logger.info('Phone number registered: $phone');
      return true;
    } catch (e) {
      _logger.error('Failed to register phone', e);
      return false;
    }
  }

  String? getStoredPhone() {
    return _prefs.getString(_phoneKey);
  }

  // Auto-login za postojeće korisnike
  Future<bool> autoLogin() async {
    try {
      final phone = getStoredPhone();
      if (phone != null) {
        _logger.info('Auto-login successful for phone: $phone');
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Auto-login failed', e);
      return false;
    }
  }
}
