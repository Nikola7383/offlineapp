import 'package:flutter/material.dart';

class EnhancedSecurityUI {
  static final EnhancedSecurityUI _instance = EnhancedSecurityUI._internal();
  final SecurityDecisionManager _decisionManager = SecurityDecisionManager();
  final UserPreferenceManager _preferenceManager = UserPreferenceManager();
  
  factory EnhancedSecurityUI() {
    return _instance;
  }

  EnhancedSecurityUI._internal() {
    _initializeUI();
  }

  Future<void> _initializeUI() async {
    await _loadUserPreferences();
    await _setupSimplifiedDecisions();
    await _initializeSecurityGuides();
  }

  Future<bool> requestSecurityDecision(
    SecurityAction action,
    SecurityContext context
  ) async {
    // Provera da li možemo automatski odlučiti
    if (await _canAutoDecide(action, context)) {
      return await _makeAutoDecision(action, context);
    }

    // Ako je potrebna korisnička odluka, prikazujemo pojednostavljeni UI
    return await _showSimplifiedDecisionDialog(action, context);
  }

  Future<bool> _showSimplifiedDecisionDialog(
    SecurityAction action,
    SecurityContext context
  ) async {
    final decision = await showDialog<bool>(
      context: context.buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) => SecurityDecisionDialog(
        title: _getSimplifiedTitle(action),
        description: _getSimplifiedDescription(action),
        securityLevel: _calculateSecurityLevel(action, context),
        recommendedAction: await _getRecommendedAction(action, context)
      )
    );

    if (decision != null) {
      // Pamtimo odluku za buduće auto-odlučivanje
      await _rememberDecision(action, context, decision);
    }

    return decision ?? false;
  }

  String _getSimplifiedTitle(SecurityAction action) {
    // Pojednostavljeni naslovi razumljivi korisnicima
    switch (action.type) {
      case SecurityActionType.p2pConnection:
        return 'Povezivanje sa drugim uređajem';
      case SecurityActionType.dataSharing:
        return 'Deljenje podataka';
      case SecurityActionType.recovery:
        return 'Oporavak sistema';
      default:
        return 'Sigurnosna akcija';
    }
  }

  String _getSimplifiedDescription(SecurityAction action) {
    // Jasne i koncizne poruke
    switch (action.type) {
      case SecurityActionType.p2pConnection:
        return 'Drugi uređaj želi da se poveže. Ovo je bezbedno ako poznajete vlasnika uređaja.';
      case SecurityActionType.dataSharing:
        return 'Deljenje podataka sa povezanim uređajem. Podaci su enkriptovani.';
      case SecurityActionType.recovery:
        return 'Potrebno je popraviti sistem. Vaši podaci će biti sačuvani.';
      default:
        return 'Potrebna je vaša potvrda za nastavak.';
    }
  }
}

class EnhancedRecoveryUI {
  static final EnhancedRecoveryUI _instance = EnhancedRecoveryUI._internal();
  final RecoveryManager _recoveryManager = RecoveryManager();
  
  factory EnhancedRecoveryUI() {
    return _instance;
  }

  EnhancedRecoveryUI._internal() {
    _initializeRecoveryUI();
  }

  Future<void> _initializeRecoveryUI() async {
    await _setupAutoRecovery();
    await _initializeRecoveryGuides();
  }

  Future<bool> handleRecoveryProcess(
    RecoveryContext context,
    {bool autoRecover = true}
  ) async {
    if (autoRecover && await _canAutoRecover(context)) {
      return await _performAutoRecovery(context);
    }

    return await _showRecoveryUI(context);
  }

  Future<bool> _showRecoveryUI(RecoveryContext context) async {
    return await showDialog<bool>(
      context: context.buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) => RecoveryDialog(
        steps: _getRecoverySteps(context),
        autoRecoveryAvailable: await _canAutoRecover(context),
        estimatedTime: await _estimateRecoveryTime(context),
        onAutoRecoveryRequested: () => _performAutoRecovery(context)
      )
    ) ?? false;
  }

  List<RecoveryStep> _getRecoverySteps(RecoveryContext context) {
    // Pojednostavljeni koraci za recovery
    return [
      RecoveryStep(
        title: 'Provera sistema',
        description: 'Proveravamo stanje sistema',
        action: () => _checkSystemState(context)
      ),
      RecoveryStep(
        title: 'Čuvanje podataka',
        description: 'Vaši podaci se čuvaju',
        action: () => _backupData(context)
      ),
      RecoveryStep(
        title: 'Popravka',
        description: 'Popravljamo pronađene probleme',
        action: () => _performRecovery(context)
      ),
      RecoveryStep(
        title: 'Verifikacija',
        description: 'Proveravamo da li je sve u redu',
        action: () => _verifyRecovery(context)
      )
    ];
  }
}

class SecurityDecisionDialog extends StatelessWidget {
  final String title;
  final String description;
  final SecurityLevel securityLevel;
  final bool recommendedAction;

  const SecurityDecisionDialog({
    required this.title,
    required this.description,
    required this.securityLevel,
    required this.recommendedAction,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(description),
          SizedBox(height: 16),
          SecurityLevelIndicator(level: securityLevel),
          if (recommendedAction)
            Text('Preporučena akcija: Dozvoli',
              style: TextStyle(color: Colors.green))
        ]
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Odbij')
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Dozvoli')
        )
      ]
    );
  }
}

class RecoveryDialog extends StatelessWidget {
  final List<RecoveryStep> steps;
  final bool autoRecoveryAvailable;
  final Duration estimatedTime;
  final Function() onAutoRecoveryRequested;

  const RecoveryDialog({
    required this.steps,
    required this.autoRecoveryAvailable,
    required this.estimatedTime,
    required this.onAutoRecoveryRequested,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Oporavak sistema'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Procenjeno vreme: ${estimatedTime.inMinutes} minuta'),
          SizedBox(height: 16),
          ...steps.map((step) => RecoveryStepWidget(step: step)),
          if (autoRecoveryAvailable)
            ElevatedButton(
              onPressed: onAutoRecoveryRequested,
              child: Text('Započni automatski oporavak')
            )
        ]
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Otkaži')
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Započni ručni oporavak')
        )
      ]
    );
  }
} 