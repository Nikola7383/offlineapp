import 'dart:async';
import 'dart:isolate';

import '../models/process_info.dart';

/// Izvršava i upravlja procesima koristeći Dart isolates
class ProcessExecutor {
  // Mapa aktivnih isolate-a po ID-u procesa
  final Map<String, Isolate> _activeIsolates = {};

  // Mapa receive portova po ID-u procesa
  final Map<String, ReceivePort> _receivePorts = {};

  // Mapa stream kontrolera po ID-u procesa
  final Map<String, StreamController<Map<String, dynamic>>> _processStreams =
      {};

  // Mapa pause capability-ja po ID-u procesa
  final Map<String, Capability> _pauseCapabilities = {};

  /// Pokreće novi proces u isolate-u
  Future<void> startProcess(
    String processId,
    Function processFunction,
    Map<String, dynamic>? config,
  ) async {
    try {
      // Kreiraj receive port za komunikaciju sa isolate-om
      final receivePort = ReceivePort();
      _receivePorts[processId] = receivePort;

      // Kreiraj stream kontroler za proces
      final streamController =
          StreamController<Map<String, dynamic>>.broadcast();
      _processStreams[processId] = streamController;

      // Pokreni isolate
      final isolate = await Isolate.spawn(
        _isolateFunction,
        IsolateMessage(
          sendPort: receivePort.sendPort,
          function: processFunction,
          config: config,
        ),
      );

      _activeIsolates[processId] = isolate;

      // Slušaj poruke od isolate-a
      receivePort.listen(
        (dynamic message) {
          if (message is Map<String, dynamic>) {
            streamController.add(message);
          }
        },
        onError: (error) {
          streamController.addError(error);
        },
        onDone: () {
          _cleanupProcess(processId);
        },
      );
    } catch (e) {
      throw Exception('Greška prilikom pokretanja procesa: $e');
    }
  }

  /// Zaustavlja proces
  Future<void> stopProcess(String processId) async {
    try {
      final isolate = _activeIsolates[processId];
      if (isolate == null) return;

      isolate.kill();
      _cleanupProcess(processId);
    } catch (e) {
      throw Exception('Greška prilikom zaustavljanja procesa: $e');
    }
  }

  /// Pauzira proces
  Future<void> pauseProcess(String processId) async {
    try {
      final isolate = _activeIsolates[processId];
      if (isolate == null) return;

      // Pauziraj isolate i sačuvaj capability
      final pauseCapability = Capability();
      isolate.pause(pauseCapability);
      _pauseCapabilities[processId] = pauseCapability;
    } catch (e) {
      throw Exception('Greška prilikom pauziranja procesa: $e');
    }
  }

  /// Nastavlja proces
  Future<void> resumeProcess(String processId) async {
    try {
      final isolate = _activeIsolates[processId];
      final pauseCapability = _pauseCapabilities[processId];
      if (isolate == null || pauseCapability == null) return;

      isolate.resume(pauseCapability);
      _pauseCapabilities.remove(processId);
    } catch (e) {
      throw Exception('Greška prilikom nastavljanja procesa: $e');
    }
  }

  /// Stream za praćenje stanja procesa
  Stream<Map<String, dynamic>>? getProcessStream(String processId) {
    return _processStreams[processId]?.stream;
  }

  /// Čisti resurse procesa
  void _cleanupProcess(String processId) {
    _activeIsolates.remove(processId)?.kill();
    _receivePorts.remove(processId)?.close();
    _processStreams.remove(processId)?.close();
    _pauseCapabilities.remove(processId);
  }

  /// Čisti sve resurse
  void dispose() {
    for (final processId in _activeIsolates.keys.toList()) {
      _cleanupProcess(processId);
    }
  }
}

/// Poruka koja se šalje isolate-u
class IsolateMessage {
  final SendPort sendPort;
  final Function function;
  final Map<String, dynamic>? config;

  IsolateMessage({
    required this.sendPort,
    required this.function,
    this.config,
  });
}

/// Funkcija koja se izvršava u isolate-u
void _isolateFunction(IsolateMessage message) {
  try {
    // Pokreni funkciju procesa
    final result = message.function(message.config);

    // Ako je Future, čekaj rezultat
    if (result is Future) {
      result.then(
        (value) => message.sendPort.send({'result': value}),
        onError: (error) => message.sendPort.send({'error': error.toString()}),
      );
    } else {
      // Ako nije Future, pošalji rezultat odmah
      message.sendPort.send({'result': result});
    }
  } catch (e) {
    message.sendPort.send({'error': e.toString()});
  }
}
