class SoundEncoder {
  static const int SAMPLE_RATE = 44100;
  static const int CHUNK_SIZE = 1024;

  Future<List<int>> encodeMessage(String message) async {
    final frequencies = generateOptimalFrequencies();
    return await encodeWithFrequencies(message, frequencies);
  }

  List<double> generateOptimalFrequencies() {
    // Implementacija OFDM (Orthogonal Frequency Division Multiplexing)
    return List.generate(64, (i) => 18000 + (i * 100));
  }
}
