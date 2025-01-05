import 'dart:isolate';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../security/security_types.dart';

class OfflineAIManager {
  static const int MAX_MEMORY_USAGE = 100 * 1024 * 1024; // 100MB
  static const Duration MODEL_UPDATE_INTERVAL = Duration(hours: 1);

  late final Interpreter _securityModel;
  late final Interpreter _anomalyModel;
  late final Interpreter _decisionModel;

  final Map<String, List<double>> _nodePatterns = {};
  final List<AIDecision> _decisionHistory = [];
  bool _isAdminMode = false;

  Future<void> initialize() async {
    // Učitaj pred-trenirane modele iz assets
    _securityModel =
        await Interpreter.fromAsset('assets/models/security.tflite');
    _anomalyModel = await Interpreter.fromAsset('assets/models/anomaly.tflite');
    _decisionModel =
        await Interpreter.fromAsset('assets/models/decision.tflite');

    // Pokreni AI u posebnom isolate-u
    await _startAIWorker();
  }

  Future<void> _startAIWorker() async {
    await Isolate.spawn(
        _aiWorker,
        _AIWorkerParams(
          sendPort: port,
          isAdmin: _isAdminMode,
        ));
  }

  Future<AIDecision> analyzeAndDecide(NetworkState state) async {
    // Konvertuj stanje mreže u tensor
    final inputTensor = _prepareInputTensor(state);

    // Izvrši analizu kroz sve modele
    final securityScore = await _runSecurityAnalysis(inputTensor);
    final anomalyScore = await _runAnomalyDetection(inputTensor);
    final decision = await _makeDecision(securityScore, anomalyScore);

    // Ažuriraj istoriju odluka
    _updateDecisionHistory(decision);

    return decision;
  }

  Future<double> _runSecurityAnalysis(List<double> input) async {
    final outputBuffer = List<double>.filled(1, 0);

    await _securityModel.run(
      input,
      outputBuffer,
    );

    return outputBuffer[0];
  }

  Future<AIDecision> _makeDecision(
    double securityScore,
    double anomalyScore,
  ) async {
    final input = [securityScore, anomalyScore];
    final output = List<double>.filled(5, 0);

    await _decisionModel.run(input, output);

    return _interpretDecision(output);
  }

  void _updateDecisionHistory(AIDecision decision) {
    _decisionHistory.add(decision);

    // Održavaj istoriju u razumnim granicama
    if (_decisionHistory.length > 1000) {
      _decisionHistory.removeAt(0);
    }

    // Uči iz prethodnih odluka
    _updateLocalModel();
  }

  Future<void> _updateLocalModel() async {
    // Transfer learning na lokalnom uređaju
    final trainingData = _prepareTrainingData();
    await _retrainModel(trainingData);
  }

  void dispose() {
    _securityModel.close();
    _anomalyModel.close();
    _decisionModel.close();
  }
}

class AIDecision {
  final SecurityAction action;
  final double confidence;
  final Map<String, double> reasoning;
  final DateTime timestamp;

  AIDecision({
    required this.action,
    required this.confidence,
    required this.reasoning,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum SecurityAction {
  maintainCurrent,
  increaseProtection,
  switchProtocol,
  initiatePhoenix,
  transferAdmin
}
