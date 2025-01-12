import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../managers/security_decision_manager.dart';
import '../managers/user_preference_manager.dart';
import '../types/security_types.dart';
import '../widgets/security_decision_dialog.dart';
import '../../core/interfaces/base_service.dart';

/// Servis za upravljanje sigurnosnim UI komponentama
///
/// Obezbeđuje:
/// - Prikazivanje sigurnosnih dijaloga
/// - Automatsko odlučivanje na osnovu preferenci
/// - Upravljanje stanjem sigurnosnih komponenti
@singleton
class EnhancedSecurityUI implements IService {
  final SecurityDecisionManager _decisionManager;
  final UserPreferenceManager _preferenceManager;
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  EnhancedSecurityUI(
    this._decisionManager,
    this._preferenceManager,
  );

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _decisionManager.initialize();
    await _preferenceManager.initialize();
    _isInitialized = true;
  }

  Future<void> dispose() async {
    if (!_isInitialized) return;

    await _decisionManager.dispose();
    await _preferenceManager.dispose();
    _isInitialized = false;
  }

  /// Obrađuje sigurnosnu akciju
  ///
  /// Prikazuje dijalog za odlučivanje ako je potrebno ili
  /// automatski odlučuje na osnovu sačuvanih preferenci.
  ///
  /// [context] - BuildContext za prikazivanje dijaloga
  /// [action] - Sigurnosna akcija koja se obrađuje
  /// Returns: true ako je akcija odobrena, false ako nije
  Future<bool> handleSecurityAction(
    BuildContext context,
    SecurityAction action,
  ) async {
    if (!_isInitialized) {
      throw StateError('EnhancedSecurityUI nije inicijalizovan');
    }

    final securityContext = SecurityContext(
      buildContext: context,
      userId: 'current-user', // TODO: Implementirati getCurrentUser
      timestamp: DateTime.now(),
      contextData: {},
    );

    final canAutoDecide =
        await _decisionManager.canAutoDecide(action, securityContext);
    if (canAutoDecide) {
      return await _decisionManager.makeAutoDecision(action, securityContext);
    }

    final title = _decisionManager.getSimplifiedTitle(action);
    final description = _decisionManager.getSimplifiedDescription(action);
    final securityLevel =
        _decisionManager.calculateSecurityLevel(action, securityContext);
    final recommendedAction =
        await _decisionManager.getRecommendedAction(action, securityContext);

    final decision = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SecurityDecisionDialog(
        title: title,
        description: description,
        securityLevel: securityLevel,
        recommendedAction: recommendedAction,
        onDecisionMade: (decision, rememberChoice) async {
          if (rememberChoice) {
            await _decisionManager.rememberDecision(
                action, securityContext, decision);
          }
          return decision;
        },
      ),
    );

    return decision ?? false;
  }
}
