class ErrorDetection {
  static const int REED_SOLOMON_LENGTH = 255;
  static const int DATA_LENGTH = 223;

  List<int> addErrorCorrection(List<int> data) {
    final encoder = ReedSolomonEncoder();
    return encoder.encode(data, REED_SOLOMON_LENGTH - DATA_LENGTH);
  }

  bool verifyAndCorrect(List<int> received) {
    final decoder = ReedSolomonDecoder();
    try {
      return decoder.decode(received);
    } catch (e) {
      return false;
    }
  }
}
