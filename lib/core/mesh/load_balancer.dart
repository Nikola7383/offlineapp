import 'dart:async';
import '../services/logger_service.dart';
import '../models/message.dart';
import 'mesh_optimizer.dart';

class MeshLoadBalancer {
  final MeshOptimizer _optimizer;
  final LoggerService _logger;
  final Map<String, int> _messageCount = {};
  final Duration _windowDuration = const Duration(minutes: 1);
  Timer? _windowTimer;

  MeshLoadBalancer({
    required MeshOptimizer optimizer,
    required LoggerService logger,
  })  : _optimizer = optimizer,
        _logger = logger {
    _startWindowTimer();
  }

  void _startWindowTimer() {
    _windowTimer = Timer.periodic(_windowDuration, (_) {
      _resetWindow();
    });
  }

  void _resetWindow() {
    _messageCount.clear();
  }

  List<String> getTargetPeers(Message message) {
    final optimalPeers = _optimizer.getOptimalPeers();

    // Izaberi peers sa najmanje poruka u trenutnom prozoru
    return optimalPeers
        .where((peer) =>
                (_messageCount[peer] ?? 0) <
                100 // max 100 poruka po peer-u po prozoru
            )
        .toList();
  }

  void trackMessage(String peerId) {
    _messageCount[peerId] = (_messageCount[peerId] ?? 0) + 1;
  }

  void dispose() {
    _windowTimer?.cancel();
    _messageCount.clear();
  }
}
