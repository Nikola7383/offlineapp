import 'dart:async';
import 'dart:typed_data';
import 'package:test/test.dart';
import '../../../lib/mesh/protocols/sound_manager.dart';
import '../../../lib/mesh/models/node.dart';
import '../../../lib/mesh/models/protocol.dart';
import '../../../lib/mesh/models/sound_types.dart';

class MockSound implements SoundInterface {
  bool _isListening = false;
  bool _hasPermission = true;
  final _audioController = StreamController<SoundData>.broadcast();
  final List<List<double>> _playedFrequencies = [];

  void reset() {
    _isListening = false;
    _hasPermission = true;
    _playedFrequencies.clear();
  }

  @override
  Future<bool> requestPermission() async => _hasPermission;

  @override
  Future<void> startListening() async {
    if (!_hasPermission) throw Exception('No permission');
    _isListening = true;
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
  }

  @override
  Future<void> playFrequencies(
      List<double> frequencies, double baseFrequency) async {
    if (!_isListening) throw Exception('Not listening');
    _playedFrequencies.add(frequencies);
  }

  @override
  Stream<SoundData> get audioStream => _audioController.stream;

  // Helper metode za testiranje
  void simulateAudioData(List<double> frequencies, {double amplitude = 0.5}) {
    if (!_isListening) throw Exception('Not listening');
    _audioController.add(SoundData(
      frequencies: frequencies,
      amplitude: amplitude,
    ));
  }

  void simulateNodeBeacon(String nodeId, {double amplitude = 0.5}) {
    final frequencies = _encodeNodeId(nodeId);
    simulateAudioData(frequencies, amplitude: amplitude);
  }

  List<double> _encodeNodeId(String nodeId) {
    final parts = nodeId.split(':');
    if (parts.length != 6) throw FormatException('Invalid node ID format');

    List<double> frequencies = [];
    for (var part in parts) {
      final byte = int.parse(part, radix: 16);
      for (var i = 0; i < 8; i++) {
        final bit = (byte >> i) & 1;
        frequencies
            .add(18000 + (bit * 100)); // Koristi isti format kao SoundManager
      }
    }
    return frequencies;
  }

  void dispose() {
    _audioController.close();
  }
}

void main() {
  late SoundManager soundManager;
  late MockSound mockSound;

  setUp(() {
    mockSound = MockSound();
    soundManager = SoundManager(mockSound);
  });

  tearDown(() {
    mockSound.dispose();
  });

  group('Device Discovery', () {
    test('Should discover devices when sound is enabled', () async {
      // Arrange
      final expectedNodeId = 'AA:BB:CC:DD:EE:FF';

      // Act
      final scanFuture = soundManager.scanForDevices();
      mockSound.simulateNodeBeacon(expectedNodeId, amplitude: 0.5);
      final discoveredNodes = await scanFuture;

      // Assert
      expect(discoveredNodes, isNotEmpty);
      expect(discoveredNodes.first.id, equals(expectedNodeId));
      expect(discoveredNodes.first.signalStrength, closeTo(0.44, 0.01));
    });

    test('Should handle no permission gracefully', () async {
      // Arrange
      mockSound._hasPermission = false;

      // Act
      final discoveredNodes = await soundManager.scanForDevices();

      // Assert
      expect(discoveredNodes, isEmpty);
    });

    test('Should filter out weak signals', () async {
      // Arrange
      final nodeId = 'AA:BB:CC:DD:EE:FF';

      // Act
      final scanFuture = soundManager.scanForDevices();
      mockSound.simulateNodeBeacon(nodeId,
          amplitude: 0.05); // Ispod MIN_AMPLITUDE
      final discoveredNodes = await scanFuture;

      // Assert
      expect(discoveredNodes, isEmpty);
    });
  });

  group('Data Transmission', () {
    test('Should send data successfully', () async {
      // Arrange
      final testData = List<int>.generate(100, (i) => i % 256);

      // Act
      final success = await soundManager.sendData('test_node', testData);

      // Assert
      expect(success, isTrue);
      expect(mockSound._playedFrequencies, isNotEmpty);
    });

    test('Should handle send errors gracefully', () async {
      // Arrange
      mockSound._hasPermission = false;
      final testData = List<int>.generate(10, (i) => i);

      // Act
      final success = await soundManager.sendData('test_node', testData);

      // Assert
      expect(success, isFalse);
    });
  });

  group('Listening', () {
    test('Should start and stop listening successfully', () async {
      // Act & Assert
      await expectLater(soundManager.startListening(), completes);
      await expectLater(soundManager.stopListening(), completes);
    });

    test('Should receive data while listening', () async {
      // Arrange
      final testData = List<int>.generate(10, (i) => i);
      final frequencies = mockSound._encodeNodeId('AA:BB:CC:DD:EE:FF');

      // Act
      await soundManager.startListening();

      // Assert
      expectLater(
        soundManager.dataStream,
        emits(isA<List<int>>()),
      );

      mockSound.simulateAudioData(frequencies, amplitude: 0.5);
    });

    test('Should handle permission denial', () async {
      // Arrange
      mockSound._hasPermission = false;

      // Act & Assert
      await expectLater(soundManager.startListening(), completes);
      expect(mockSound._isListening, isFalse);
    });
  });
}
