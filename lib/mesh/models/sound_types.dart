import 'dart:async';

abstract class SoundInterface {
  /// Traži dozvolu za mikrofon
  Future<bool> requestPermission();

  /// Počinje slušanje audio inputa
  Future<void> startListening();

  /// Zaustavlja slušanje
  Future<void> stopListening();

  /// Pušta frekvencije kroz zvučnik
  Future<void> playFrequencies(List<double> frequencies, double baseFrequency);

  /// Stream audio podataka
  Stream<SoundData> get audioStream;
}

/// Implementacija za stvarni uređaj
class Sound implements SoundInterface {
  @override
  Future<bool> requestPermission() async => throw UnimplementedError();

  @override
  Future<void> startListening() async => throw UnimplementedError();

  @override
  Future<void> stopListening() async => throw UnimplementedError();

  @override
  Future<void> playFrequencies(
          List<double> frequencies, double baseFrequency) async =>
      throw UnimplementedError();

  @override
  Stream<SoundData> get audioStream => throw UnimplementedError();
}

/// Model za audio podatke
class SoundData {
  final List<double> frequencies;
  final double amplitude;
  final DateTime timestamp;

  SoundData({
    required this.frequencies,
    required this.amplitude,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
