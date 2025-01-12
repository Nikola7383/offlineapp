class QrOptions {
  final Duration refreshInterval;
  final bool secureGeneration;
  final bool validateTransfer;
  final int errorCorrectionLevel;

  const QrOptions({
    required this.refreshInterval,
    this.secureGeneration = true,
    this.validateTransfer = true,
    this.errorCorrectionLevel = 1,
  });
}
