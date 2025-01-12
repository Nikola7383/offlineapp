import 'package:injectable/injectable.dart';
import '../../core/interfaces/base_service.dart';
import '../types/security_types.dart';

abstract class ISecurityDecisionManager implements IService {
  Future<bool> canAutoDecide(SecurityAction action, SecurityContext context);
  Future<bool> makeAutoDecision(SecurityAction action, SecurityContext context);
  Future<void> rememberDecision(
      SecurityAction action, SecurityContext context, bool decision);
  Future<bool> getRecommendedAction(
      SecurityAction action, SecurityContext context);
  SecurityLevel calculateSecurityLevel(
      SecurityAction action, SecurityContext context);
}

abstract class IUserPreferenceManager implements IService {
  Future<void> savePreference(String key, dynamic value);
  Future<T?> getPreference<T>(String key);
  Future<void> clearPreferences();
  Future<bool> hasPreference(String key);
}
