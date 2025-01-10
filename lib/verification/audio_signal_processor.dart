import 'dart:typed_data';
import 'dart:math' as math;

/// Procesor za analizu i obradu audio signala
class AudioSignalProcessor {
  // Konstante za FFT analizu
  static const int FFT_SIZE = 2048;
  static const double MIN_FREQUENCY = 18000; // 18kHz
  static const double MAX_FREQUENCY = 20000; // 20kHz
  static const int SAMPLE_RATE = 44100;

  // Konstante za modulaciju
  static const int BITS_PER_SYMBOL = 2;
  static const int SYMBOLS_PER_SECOND = 100;
  static const double SYMBOL_DURATION = 1.0 / SYMBOLS_PER_SECOND;

  // Konstante za detekciju
  static const double DETECTION_THRESHOLD = 0.7;
  static const int MIN_VALID_SYMBOLS = 3;

  // Frekvencije za FSK modulaciju
  static const List<double> SYMBOL_FREQUENCIES = [
    18000.0, // 00
    18500.0, // 01
    19000.0, // 10
    19500.0, // 11
  ];

  /// Enkodira podatke u audio signal
  Uint8List encodeData(List<int> data) {
    final samples = <double>[];
    final symbolDurationSamples = (SAMPLE_RATE * SYMBOL_DURATION).round();

    // Dodaj preambulu za sinhronizaciju
    samples.addAll(_generatePreamble());

    // Enkoduj svaki bajt
    for (final byte in data) {
      // Podeli bajt na simbole od po 2 bita
      for (var i = 6; i >= 0; i -= 2) {
        final symbol = (byte >> i) & 0x03;
        final frequency = SYMBOL_FREQUENCIES[symbol];

        // Generiši samples za simbol
        samples.addAll(_generateTone(
          frequency,
          symbolDurationSamples,
        ));
      }
    }

    // Konvertuj u PCM format
    return _convertToPCM16(samples);
  }

  /// Dekodira audio signal u podatke
  List<int>? decodeData(Float64List samples) {
    // Pronađi preambulu
    final startIndex = _findPreamble(samples);
    if (startIndex == -1) return null;

    final decodedSymbols = <int>[];
    var currentIndex = startIndex;

    // Dekoduj simbole
    while (currentIndex < samples.length) {
      final symbol = _detectSymbol(
        samples,
        currentIndex,
        (SAMPLE_RATE * SYMBOL_DURATION).round(),
      );

      if (symbol == -1) break;
      decodedSymbols.add(symbol);
      currentIndex += (SAMPLE_RATE * SYMBOL_DURATION).round();
    }

    // Konvertuj simbole u bajtove
    return _symbolsToBytes(decodedSymbols);
  }

  /// Analizira jačinu signala i kvalitet
  double analyzeSignalQuality(Float64List samples) {
    if (samples.isEmpty) return 0.0;

    // Izračunaj srednju vrednost i standardnu devijaciju
    double sum = 0.0;
    double sumSquares = 0.0;

    for (final sample in samples) {
      sum += sample;
      sumSquares += sample * sample;
    }

    final mean = sum / samples.length;
    final variance = (sumSquares / samples.length) - (mean * mean);
    final stdDev = math.sqrt(variance);

    // Izračunaj SNR (Signal-to-Noise Ratio)
    final signalPower = sumSquares / samples.length;
    final noisePower = stdDev * stdDev;
    final snr = signalPower / (noisePower + 1e-10);

    // Normalizuj na 0-1
    return math.min(1.0, snr / 100.0);
  }

  /// Generiše preambulu za sinhronizaciju
  List<double> _generatePreamble() {
    final samples = <double>[];
    final preambleDuration = (SAMPLE_RATE * 0.01).round(); // 10ms

    // Generiši sweep signal
    for (var i = 0; i < preambleDuration; i++) {
      final t = i / SAMPLE_RATE;
      final frequency = MIN_FREQUENCY +
          (MAX_FREQUENCY - MIN_FREQUENCY) * (i / preambleDuration);
      samples.add(math.sin(2 * math.pi * frequency * t));
    }

    return samples;
  }

  /// Generiše ton određene frekvencije
  List<double> _generateTone(double frequency, int numSamples) {
    final samples = <double>[];

    for (var i = 0; i < numSamples; i++) {
      final t = i / SAMPLE_RATE;
      // Primeni Hanning window za smanjenje spektralnog curenja
      final window = 0.5 * (1 - math.cos(2 * math.pi * i / numSamples));
      samples.add(math.sin(2 * math.pi * frequency * t) * window);
    }

    return samples;
  }

  /// Konvertuje samples u PCM16 format
  Uint8List _convertToPCM16(List<double> samples) {
    final pcm = Uint8List(samples.length * 2);
    final buffer = ByteData.view(pcm.buffer);

    for (var i = 0; i < samples.length; i++) {
      // Konvertuj u 16-bit PCM
      final value = (samples[i] * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(i * 2, value, Endian.little);
    }

    return pcm;
  }

  /// Pronalazi početak preambule u signalu
  int _findPreamble(Float64List samples) {
    final windowSize = (SAMPLE_RATE * 0.01).round();
    var bestCorrelation = 0.0;
    var bestIndex = -1;

    final preamble = _generatePreamble();

    // Klizni prozor korelacije
    for (var i = 0; i < samples.length - windowSize; i++) {
      var correlation = 0.0;
      for (var j = 0; j < windowSize; j++) {
        correlation += samples[i + j] * preamble[j];
      }
      correlation /= windowSize;

      if (correlation > bestCorrelation) {
        bestCorrelation = correlation;
        bestIndex = i;
      }
    }

    return bestCorrelation > DETECTION_THRESHOLD ? bestIndex : -1;
  }

  /// Detektuje simbol u segmentu signala
  int _detectSymbol(Float64List samples, int startIndex, int length) {
    if (startIndex + length > samples.length) return -1;

    var bestMatch = -1;
    var bestPower = 0.0;

    // Izračunaj snagu na svakoj frekvenciji simbola
    for (var i = 0; i < SYMBOL_FREQUENCIES.length; i++) {
      var power = 0.0;
      final frequency = SYMBOL_FREQUENCIES[i];

      for (var j = 0; j < length; j++) {
        final t = j / SAMPLE_RATE;
        final reference = math.sin(2 * math.pi * frequency * t);
        power += samples[startIndex + j] * reference;
      }
      power = power * power / length;

      if (power > bestPower) {
        bestPower = power;
        bestMatch = i;
      }
    }

    return bestPower > DETECTION_THRESHOLD ? bestMatch : -1;
  }

  /// Konvertuje niz simbola u bajtove
  List<int>? _symbolsToBytes(List<int> symbols) {
    if (symbols.length < MIN_VALID_SYMBOLS) return null;

    final bytes = <int>[];
    var currentByte = 0;
    var bitCount = 0;

    for (final symbol in symbols) {
      currentByte = (currentByte << 2) | symbol;
      bitCount += 2;

      if (bitCount == 8) {
        bytes.add(currentByte);
        currentByte = 0;
        bitCount = 0;
      }
    }

    return bytes;
  }
}
