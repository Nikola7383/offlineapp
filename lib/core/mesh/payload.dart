enum PayloadType { BYTES, FILE, STREAM }

class Payload {
  final PayloadType type;
  final List<int> bytes;
  final String? filePath;

  Payload({
    required this.type,
    required this.bytes,
    this.filePath,
  });
}

enum PayloadStatus { IN_PROGRESS, SUCCESS, FAILURE, CANCELED }

class PayloadTransferUpdate {
  final PayloadStatus status;
  final int bytesTransferred;

  PayloadTransferUpdate({
    required this.status,
    required this.bytesTransferred,
  });
}
