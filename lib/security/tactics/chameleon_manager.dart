import 'dart:async';
import 'dart:math';
import '../models/security_event.dart';
import '../encryption/encryption_service.dart';
import '../../mesh/models/node.dart';

/// Upravlja dinamičkim promenama koda i algoritama za zaštitu sistema
class ChameleonManager {
  final EncryptionService _encryptionService;
  final _mutationController = StreamController<MutationEvent>.broadcast();

  // Trenutno aktivni algoritmi
  final Map<String, AlgorithmVariant> _activeAlgorithms = {};

  // Istorija mutacija
  final List<MutationEvent> _mutationHistory = [];

  // Konstante
  static const int MAX_HISTORY_SIZE = 100;
  static const Duration MIN_MUTATION_INTERVAL = Duration(minutes: 15);
  static const Duration MAX_MUTATION_INTERVAL = Duration(hours: 2);

  Stream<MutationEvent> get mutationStream => _mutationController.stream;

  ChameleonManager({
    required EncryptionService encryptionService,
  }) : _encryptionService = encryptionService {
    _initializeAlgorithms();
  }

  /// Inicijalizuje početni set algoritama
  void _initializeAlgorithms() {
    _activeAlgorithms['encryption'] = AlgorithmVariant(
      name: 'AES-256-GCM',
      version: 1,
      parameters: {'keySize': 256, 'mode': 'GCM'},
    );

    _activeAlgorithms['hashing'] = AlgorithmVariant(
      name: 'SHA3-512',
      version: 1,
      parameters: {'outputSize': 512},
    );

    _activeAlgorithms['signing'] = AlgorithmVariant(
      name: 'Ed25519',
      version: 1,
      parameters: {'curve': 'ed25519'},
    );
  }

  /// Pokreće mutaciju algoritama na osnovu trenutnog stanja sistema
  Future<void> triggerMutation({
    required List<SecurityEvent> recentEvents,
    required Set<Node> activeNodes,
    required Map<String, double> threatLevels,
  }) async {
    // Proveri da li je prošlo dovoljno vremena od poslednje mutacije
    if (!_shouldMutate(recentEvents, threatLevels)) return;

    final mutationEvent = await _generateMutation(
      recentEvents: recentEvents,
      activeNodes: activeNodes,
      threatLevels: threatLevels,
    );

    // Primeni mutaciju
    await _applyMutation(mutationEvent);

    // Sačuvaj u istoriji
    _mutationHistory.add(mutationEvent);
    if (_mutationHistory.length > MAX_HISTORY_SIZE) {
      _mutationHistory.removeAt(0);
    }

    // Obavesti osluškivače
    _mutationController.add(mutationEvent);
  }

  /// Odlučuje da li treba pokrenuti mutaciju
  bool _shouldMutate(
    List<SecurityEvent> recentEvents,
    Map<String, double> threatLevels,
  ) {
    if (_mutationHistory.isEmpty) return true;

    final lastMutation = _mutationHistory.last;
    final timeSinceLastMutation =
        DateTime.now().difference(lastMutation.timestamp);

    // Proveri minimalni interval
    if (timeSinceLastMutation < MIN_MUTATION_INTERVAL) return false;

    // Izračunaj prosečni nivo pretnje
    final avgThreatLevel = threatLevels.values.isEmpty
        ? 0.0
        : threatLevels.values.reduce((a, b) => a + b) / threatLevels.length;

    // Prilagodi interval na osnovu nivoa pretnje
    final adjustedInterval = _calculateMutationInterval(avgThreatLevel);

    return timeSinceLastMutation >= adjustedInterval;
  }

  /// Računa interval između mutacija na osnovu nivoa pretnje
  Duration _calculateMutationInterval(double threatLevel) {
    // Što je veći nivo pretnje, kraći je interval
    final ratio = 1.0 - threatLevel.clamp(0.0, 1.0);
    final range = MAX_MUTATION_INTERVAL.inMilliseconds -
        MIN_MUTATION_INTERVAL.inMilliseconds;

    final interval =
        MIN_MUTATION_INTERVAL.inMilliseconds + (range * ratio).round();

    return Duration(milliseconds: interval);
  }

  /// Generiše novu mutaciju na osnovu trenutnog stanja
  Future<MutationEvent> _generateMutation({
    required List<SecurityEvent> recentEvents,
    required Set<Node> activeNodes,
    required Map<String, double> threatLevels,
  }) async {
    final mutations = <AlgorithmMutation>[];

    // Odluči koje algoritme treba mutirati
    for (var entry in _activeAlgorithms.entries) {
      if (_shouldMutateAlgorithm(entry.key, threatLevels)) {
        mutations.add(await _generateAlgorithmMutation(
          entry.key,
          entry.value,
          threatLevels[entry.key] ?? 0.0,
        ));
      }
    }

    return MutationEvent(
      timestamp: DateTime.now(),
      mutations: mutations,
      trigger: _determineMutationTrigger(recentEvents),
      affectedNodes: activeNodes.map((n) => n.id).toList(),
    );
  }

  /// Odlučuje da li treba mutirati određeni algoritam
  bool _shouldMutateAlgorithm(
      String algorithmType, Map<String, double> threatLevels) {
    final threatLevel = threatLevels[algorithmType] ?? 0.0;
    final random = Random().nextDouble();

    // Veća verovatnoća mutacije za algoritme pod većom pretnjom
    return random < (0.3 + threatLevel * 0.7);
  }

  /// Generiše mutaciju za specifični algoritam
  Future<AlgorithmMutation> _generateAlgorithmMutation(
    String algorithmType,
    AlgorithmVariant currentVariant,
    double threatLevel,
  ) async {
    // Generiši nove parametre na osnovu tipa algoritma
    final newParameters = await _generateNewParameters(
      algorithmType,
      currentVariant.parameters,
      threatLevel,
    );

    return AlgorithmMutation(
      algorithmType: algorithmType,
      oldVariant: currentVariant,
      newVariant: AlgorithmVariant(
        name: currentVariant.name,
        version: currentVariant.version + 1,
        parameters: newParameters,
      ),
    );
  }

  /// Generiše nove parametre za algoritam
  Future<Map<String, dynamic>> _generateNewParameters(
    String algorithmType,
    Map<String, dynamic> currentParams,
    double threatLevel,
  ) async {
    final newParams = Map<String, dynamic>.from(currentParams);

    switch (algorithmType) {
      case 'encryption':
        // Prilagodi parametre enkripcije
        newParams['keySize'] =
            _adjustKeySize(currentParams['keySize'] as int, threatLevel);
        newParams['iterations'] = _calculateIterations(threatLevel);
        break;

      case 'hashing':
        // Prilagodi parametre heširanja
        newParams['outputSize'] = _adjustOutputSize(
          currentParams['outputSize'] as int,
          threatLevel,
        );
        break;

      case 'signing':
        // Prilagodi parametre potpisivanja
        newParams['strengthFactor'] = _calculateStrengthFactor(threatLevel);
        break;
    }

    return newParams;
  }

  /// Određuje okidač mutacije na osnovu nedavnih događaja
  MutationTrigger _determineMutationTrigger(List<SecurityEvent> recentEvents) {
    if (recentEvents.isEmpty) return MutationTrigger.scheduled;

    // Analiziraj nedavne događaje da odrediš okidač
    final hasThreats = recentEvents.any((e) =>
        e.type == SecurityEventType.potentialThreat ||
        e.type == SecurityEventType.confirmedThreat);

    final hasAttacks = recentEvents.any((e) =>
        e.type == SecurityEventType.networkAttack ||
        e.type == SecurityEventType.dataManipulation);

    if (hasAttacks) return MutationTrigger.attack;
    if (hasThreats) return MutationTrigger.threat;
    return MutationTrigger.scheduled;
  }

  /// Primenjuje mutaciju na sistem
  Future<void> _applyMutation(MutationEvent mutation) async {
    for (var algorithmMutation in mutation.mutations) {
      // Ažuriraj aktivne algoritme
      _activeAlgorithms[algorithmMutation.algorithmType] =
          algorithmMutation.newVariant;

      // Primeni promene na odgovarajuće servise
      await _updateService(algorithmMutation);
    }
  }

  /// Ažurira servis sa novim algoritmom
  Future<void> _updateService(AlgorithmMutation mutation) async {
    switch (mutation.algorithmType) {
      case 'encryption':
        await _encryptionService.updateAlgorithm(
          mutation.newVariant.name,
          mutation.newVariant.parameters,
        );
        break;
      // Dodati ostale servise po potrebi
    }
  }

  /// Pomoćne metode za prilagođavanje parametara

  int _adjustKeySize(int currentSize, double threatLevel) {
    final sizes = [256, 384, 512];
    final index =
        min((threatLevel * (sizes.length - 1)).round(), sizes.length - 1);
    return sizes[index];
  }

  int _calculateIterations(double threatLevel) {
    return (10000 + (threatLevel * 90000)).round();
  }

  int _adjustOutputSize(int currentSize, double threatLevel) {
    final sizes = [256, 384, 512];
    final index =
        min((threatLevel * (sizes.length - 1)).round(), sizes.length - 1);
    return sizes[index];
  }

  double _calculateStrengthFactor(double threatLevel) {
    return 1.0 + threatLevel * 2.0; // 1.0 - 3.0
  }

  /// Čisti resurse
  void dispose() {
    _mutationController.close();
  }
}

/// Predstavlja varijantu algoritma
class AlgorithmVariant {
  final String name;
  final int version;
  final Map<String, dynamic> parameters;

  const AlgorithmVariant({
    required this.name,
    required this.version,
    required this.parameters,
  });
}

/// Predstavlja mutaciju algoritma
class AlgorithmMutation {
  final String algorithmType;
  final AlgorithmVariant oldVariant;
  final AlgorithmVariant newVariant;

  const AlgorithmMutation({
    required this.algorithmType,
    required this.oldVariant,
    required this.newVariant,
  });
}

/// Događaj mutacije sistema
class MutationEvent {
  final DateTime timestamp;
  final List<AlgorithmMutation> mutations;
  final MutationTrigger trigger;
  final List<String> affectedNodes;

  const MutationEvent({
    required this.timestamp,
    required this.mutations,
    required this.trigger,
    required this.affectedNodes,
  });
}

/// Okidači mutacije
enum MutationTrigger {
  scheduled, // Regularna planirana mutacija
  threat, // Mutacija izazvana pretnjom
  attack, // Mutacija izazvana napadom
}
