class NoiseReducer {
  final double threshold;
  final int windowSize;

  List<double> applyNoiseReduction(List<double> signal) {
    // Implementacija Wiener filtera
    final filtered = wienerFilter(signal);
    return removeBackground(filtered);
  }

  List<double> removeBackground(List<double> signal) {
    return signal
        .map((sample) => sample.abs() < threshold ? 0 : sample)
        .toList();
  }
}
