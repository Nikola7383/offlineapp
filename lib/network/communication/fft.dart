import 'dart:math';
import 'dart:typed_data';

/// Implementacija Fast Fourier Transform algoritma
class FFT {
  /// Izračunava FFT za dati niz samples
  static List<Complex> transform(List<double> samples) {
    final n = samples.length;

    // Proveri da li je dužina stepen dvojke
    if (!_isPowerOfTwo(n)) {
      throw ArgumentError('Dužina niza mora biti stepen dvojke');
    }

    // Konvertuj samples u kompleksne brojeve
    final x = List<Complex>.generate(
      n,
      (i) => Complex(samples[i], 0),
    );

    // Izračunaj FFT
    return _fft(x);
  }

  /// Pronalazi dominantnu frekvenciju u FFT rezultatu
  static int findDominantFrequency(List<Complex> fft, int sampleRate) {
    final n = fft.length;
    var maxMagnitude = 0.0;
    var maxIndex = 0;

    // Pronađi indeks sa najvećom magnitudom
    for (var i = 0; i < n ~/ 2; i++) {
      final magnitude = fft[i].magnitude;
      if (magnitude > maxMagnitude) {
        maxMagnitude = magnitude;
        maxIndex = i;
      }
    }

    // Konvertuj indeks u frekvenciju
    return (maxIndex * sampleRate) ~/ n;
  }

  /// Rekurzivna implementacija FFT algoritma
  static List<Complex> _fft(List<Complex> x) {
    final n = x.length;

    // Bazni slučaj
    if (n == 1) return x;

    // Podeli niz na parne i neparne indekse
    final even = List<Complex>.generate(
      n ~/ 2,
      (i) => x[2 * i],
    );
    final odd = List<Complex>.generate(
      n ~/ 2,
      (i) => x[2 * i + 1],
    );

    // Rekurzivno izračunaj FFT za parne i neparne
    final evenFFT = _fft(even);
    final oddFFT = _fft(odd);

    // Kombinuj rezultate
    final result = List<Complex>.filled(n, Complex(0, 0));

    for (var k = 0; k < n ~/ 2; k++) {
      final t = Complex.fromPolar(
        1,
        -2 * pi * k / n,
      );
      final tOdd = t * oddFFT[k];

      result[k] = evenFFT[k] + tOdd;
      result[k + n ~/ 2] = evenFFT[k] - tOdd;
    }

    return result;
  }

  /// Proverava da li je broj stepen dvojke
  static bool _isPowerOfTwo(int n) {
    if (n <= 0) return false;
    return (n & (n - 1)) == 0;
  }
}

/// Reprezentacija kompleksnog broja
class Complex {
  final double real;
  final double imag;

  const Complex(this.real, this.imag);

  /// Kreira kompleksan broj iz polarnih koordinata
  factory Complex.fromPolar(double r, double theta) {
    return Complex(
      r * cos(theta),
      r * sin(theta),
    );
  }

  /// Sabiranje kompleksnih brojeva
  Complex operator +(Complex other) {
    return Complex(
      real + other.real,
      imag + other.imag,
    );
  }

  /// Oduzimanje kompleksnih brojeva
  Complex operator -(Complex other) {
    return Complex(
      real - other.real,
      imag - other.imag,
    );
  }

  /// Množenje kompleksnih brojeva
  Complex operator *(Complex other) {
    return Complex(
      real * other.real - imag * other.imag,
      real * other.imag + imag * other.real,
    );
  }

  /// Izračunava magnitudu kompleksnog broja
  double get magnitude {
    return sqrt(real * real + imag * imag);
  }

  /// Izračunava fazu kompleksnog broja
  double get phase {
    return atan2(imag, real);
  }

  @override
  String toString() {
    final sign = imag >= 0 ? '+' : '';
    return '$real$sign${imag}i';
  }
}
