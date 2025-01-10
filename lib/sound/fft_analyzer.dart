import 'dart:math' show sqrt, pi, sin, cos;
import 'dart:typed_data';

/// Klasa za FFT analizu zvučnog signala
class FFTAnalyzer {
  /// Izvršava FFT analizu na nizu uzoraka
  List<double> performFFT(List<int> samples) {
    final n = _nextPowerOf2(samples.length);
    final real = Float64List(n);
    final imag = Float64List(n);

    // Pripremi podatke
    for (var i = 0; i < samples.length; i++) {
      real[i] = samples[i].toDouble();
    }

    // Izvrši FFT
    _fft(real, imag);

    // Izračunaj magnitude
    final magnitudes = List<double>.filled(n ~/ 2, 0);
    for (var i = 0; i < n ~/ 2; i++) {
      magnitudes[i] = sqrt(real[i] * real[i] + imag[i] * imag[i]);
    }

    return magnitudes;
  }

  /// Pronalazi dominantne frekvencije u FFT rezultatu
  List<double> findDominantFrequencies(
      List<double> magnitudes, double sampleRate) {
    const threshold = 0.1; // 10% od maksimalne magnitude
    final frequencies = <double>[];
    final maxMagnitude = magnitudes.reduce((a, b) => a > b ? a : b);

    for (var i = 0; i < magnitudes.length; i++) {
      if (magnitudes[i] > maxMagnitude * threshold) {
        final frequency = i * sampleRate / (2 * magnitudes.length);
        frequencies.add(frequency);
      }
    }

    return frequencies;
  }

  /// Pronalazi najbližu frekvenciju iz liste očekivanih frekvencija
  double findClosestFrequency(double target, List<double> expectedFrequencies) {
    return expectedFrequencies.reduce((a, b) {
      return (target - a).abs() < (target - b).abs() ? a : b;
    });
  }

  /// Vraća sledeći broj koji je stepen dvojke
  int _nextPowerOf2(int n) {
    var power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  /// Implementacija FFT algoritma
  void _fft(Float64List real, Float64List imag) {
    final n = real.length;

    // Bit-reverse permutation
    var j = 0;
    for (var i = 0; i < n - 1; i++) {
      if (i < j) {
        // Zameni real[i] i real[j]
        var temp = real[i];
        real[i] = real[j];
        real[j] = temp;

        // Zameni imag[i] i imag[j]
        temp = imag[i];
        imag[i] = imag[j];
        imag[j] = temp;
      }

      var k = n ~/ 2;
      while (k <= j) {
        j -= k;
        k ~/= 2;
      }
      j += k;
    }

    // Butterfly algorithm
    for (var l = 2; l <= n; l *= 2) {
      final m = l ~/ 2;
      final theta = -2 * pi / l;

      for (var k = 0; k < n; k += l) {
        for (var j = 0; j < m; j++) {
          final i = k + j;
          final p = k + j + m;
          final cosVal = cos(theta * j);
          final sinVal = sin(theta * j);

          final tempReal = real[p] * cosVal - imag[p] * sinVal;
          final tempImag = real[p] * sinVal + imag[p] * cosVal;

          real[p] = real[i] - tempReal;
          imag[p] = imag[i] - tempImag;
          real[i] += tempReal;
          imag[i] += tempImag;
        }
      }
    }
  }
}
