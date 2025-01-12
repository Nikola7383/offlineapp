class TransferOptions {
  final int attempt;
  final Duration timeout;
  final bool validateTransfer;
  final bool secureTransfer;

  const TransferOptions({
    required this.attempt,
    required this.timeout,
    this.validateTransfer = true,
    this.secureTransfer = true,
  });
}
