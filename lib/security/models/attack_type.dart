enum AttackType { bruteForce, injection, mitm, dos, replay, multiple }

extension AttackTypeExtension on AttackType {
  String get name {
    switch (this) {
      case AttackType.bruteForce:
        return 'Brute Force';
      case AttackType.injection:
        return 'SQL Injection';
      case AttackType.mitm:
        return 'Man in the Middle';
      case AttackType.dos:
        return 'Denial of Service';
      case AttackType.replay:
        return 'Replay Attack';
      case AttackType.multiple:
        return 'Multiple Attack Types';
    }
  }

  String get description {
    switch (this) {
      case AttackType.bruteForce:
        return 'Pokušaj pogađanja lozinke kroz ponavljajuće pokušaje';
      case AttackType.injection:
        return 'Ubacivanje malicioznog SQL koda';
      case AttackType.mitm:
        return 'Presretanje komunikacije između dve strane';
      case AttackType.dos:
        return 'Preopterećenje servera velikim brojem zahteva';
      case AttackType.replay:
        return 'Ponavljanje legitimnog mrežnog prenosa';
      case AttackType.multiple:
        return 'Kombinacija više različitih tipova napada';
    }
  }

  double get baseRisk {
    switch (this) {
      case AttackType.bruteForce:
        return 0.6;
      case AttackType.injection:
        return 0.8;
      case AttackType.mitm:
        return 0.7;
      case AttackType.dos:
        return 0.5;
      case AttackType.replay:
        return 0.4;
      case AttackType.multiple:
        return 0.9;
    }
  }

  String get icon {
    switch (this) {
      case AttackType.bruteForce:
        return '🔨';
      case AttackType.injection:
        return '💉';
      case AttackType.mitm:
        return '🕵️';
      case AttackType.dos:
        return '🚫';
      case AttackType.replay:
        return '🔄';
      case AttackType.multiple:
        return '⚠️';
    }
  }

  bool get requiresImmediate {
    switch (this) {
      case AttackType.bruteForce:
      case AttackType.replay:
        return false;
      case AttackType.injection:
      case AttackType.mitm:
      case AttackType.dos:
      case AttackType.multiple:
        return true;
    }
  }

  List<String> get commonSources {
    switch (this) {
      case AttackType.bruteForce:
        return ['login', 'admin-panel', 'api-auth'];
      case AttackType.injection:
        return ['search', 'form-input', 'query-params'];
      case AttackType.mitm:
        return ['network', 'wifi', 'proxy'];
      case AttackType.dos:
        return ['public-api', 'login-endpoint', 'main-server'];
      case AttackType.replay:
        return ['session', 'token', 'auth-request'];
      case AttackType.multiple:
        return ['distributed', 'botnet', 'coordinated'];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': toString(),
      'name': name,
      'description': description,
      'baseRisk': baseRisk,
      'requiresImmediate': requiresImmediate,
    };
  }

  static AttackType fromString(String type) {
    return AttackType.values.firstWhere(
      (e) => e.toString() == 'AttackType.$type',
      orElse: () => AttackType.multiple,
    );
  }
}
