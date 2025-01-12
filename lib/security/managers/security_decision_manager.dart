import 'package:injectable/injectable.dart';
import '../../core/interfaces/logger_service_interface.dart';
import '../interfaces/security_manager_interface.dart';
import '../types/security_types.dart';
import 'user_preference_manager.dart';

@singleton
class SecurityDecisionManager implements ISecurityDecisionManager {
  final UserPreferenceManager _preferenceManager;
  final ILoggerService _logger;
  bool _isInitialized = false;

  SecurityDecisionManager(this._preferenceManager, this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _preferenceManager.initialize();
      _logger.info('SecurityDecisionManager initialized');
      _isInitialized = true;
    }
  }

  @override
  Future<void> dispose() async {
    if (_isInitialized) {
      await _preferenceManager.dispose();
      _logger.info('SecurityDecisionManager disposed');
      _isInitialized = false;
    }
  }

  @override
  Future<bool> canAutoDecide(
      SecurityAction action, SecurityContext context) async {
    if (!_isInitialized) return false;

    final key = _getDecisionKey(action, context);
    final savedDecision = await _preferenceManager.getPreference<bool>(key);
    _logger.info('Checking auto decision capability for: $key');
    return savedDecision != null;
  }

  @override
  Future<bool> makeAutoDecision(
      SecurityAction action, SecurityContext context) async {
    if (!_isInitialized) return false;

    final key = _getDecisionKey(action, context);
    final savedDecision = await _preferenceManager.getPreference<bool>(key);
    _logger.info('Making auto decision for: $key = ${savedDecision ?? false}');
    return savedDecision ?? false;
  }

  @override
  Future<void> rememberDecision(
      SecurityAction action, SecurityContext context, bool decision) async {
    if (!_isInitialized) return;

    final key = _getDecisionKey(action, context);
    await _preferenceManager.savePreference(key, decision);
    _logger.info('Security decision remembered: $key = $decision');
  }

  @override
  Future<bool> getRecommendedAction(
      SecurityAction action, SecurityContext context) async {
    final securityLevel = calculateSecurityLevel(action, context);
    final recommendation = _calculateRecommendation(action, securityLevel);
    _logger.info('Recommended action for ${action.type}: $recommendation');
    return recommendation;
  }

  @override
  SecurityLevel calculateSecurityLevel(
      SecurityAction action, SecurityContext context) {
    final baseLevel = _getBaseSecurityLevel(action);
    final contextLevel = _calculateContextLevel(context);
    final finalLevel = _combineSecurityLevels(baseLevel, contextLevel);
    _logger.info('Calculated security level for ${action.type}: $finalLevel');
    return finalLevel;
  }

  String _getDecisionKey(SecurityAction action, SecurityContext context) {
    return '${action.type}_${action.level}_${context.userId}';
  }

  SecurityLevel _getBaseSecurityLevel(SecurityAction action) {
    return action.level;
  }

  SecurityLevel _calculateContextLevel(SecurityContext context) {
    // Implementirati logiku za određivanje nivoa sigurnosti na osnovu konteksta
    // Za sada vraćamo medium kao default
    return SecurityLevel.medium;
  }

  SecurityLevel _combineSecurityLevels(
      SecurityLevel base, SecurityLevel context) {
    if (base == SecurityLevel.critical || context == SecurityLevel.critical) {
      return SecurityLevel.critical;
    }
    if (base == SecurityLevel.high || context == SecurityLevel.high) {
      return SecurityLevel.high;
    }
    if (base == SecurityLevel.medium || context == SecurityLevel.medium) {
      return SecurityLevel.medium;
    }
    return SecurityLevel.low;
  }

  bool _calculateRecommendation(SecurityAction action, SecurityLevel level) {
    if (level == SecurityLevel.critical) {
      return false; // Uvek preporučujemo odbijanje za kritične akcije
    }

    switch (action.type) {
      case SecurityActionType.p2pConnection:
        return level != SecurityLevel.high;
      case SecurityActionType.dataSharing:
        return level == SecurityLevel.low;
      case SecurityActionType.recovery:
        return true; // Uvek preporučujemo oporavak sistema
      case SecurityActionType.systemChange:
        return level == SecurityLevel.low;
    }
  }

  // Helper metode za UI
  String getSimplifiedTitle(SecurityAction action) {
    switch (action.type) {
      case SecurityActionType.p2pConnection:
        return 'Zahtev za P2P konekciju';
      case SecurityActionType.dataSharing:
        return 'Zahtev za deljenje podataka';
      case SecurityActionType.recovery:
        return 'Zahtev za oporavak sistema';
      case SecurityActionType.systemChange:
        return 'Zahtev za promenu sistema';
    }
  }

  String getSimplifiedDescription(SecurityAction action) {
    switch (action.type) {
      case SecurityActionType.p2pConnection:
        return 'Aplikacija želi da uspostavi P2P konekciju sa drugim uređajem.';
      case SecurityActionType.dataSharing:
        return 'Aplikacija želi da deli podatke sa drugim uređajem.';
      case SecurityActionType.recovery:
        return 'Aplikacija želi da izvrši oporavak sistema.';
      case SecurityActionType.systemChange:
        return 'Aplikacija želi da izvrši promenu sistemskih podešavanja.';
    }
  }
}
