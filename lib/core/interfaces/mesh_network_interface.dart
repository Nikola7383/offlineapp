import 'dart:async';
import 'base_service.dart';

/// Interfejs za mesh mrežnu komunikaciju
abstract class IMeshNetwork implements IService {
  /// Povezuje se na mesh mrežu
  Future<void> connect();

  /// Prekida vezu sa mesh mrežom
  Future<void> disconnect();

  /// Proverava da li je povezan na mesh mrežu
  bool get isConnected;

  /// Šalje poruku svim čvorovima u mreži
  Future<void> broadcast(String message);

  /// Šalje poruku određenom čvoru u mreži
  Future<void> sendToPeer(String peerId, String message);

  /// Stream za primanje poruka od drugih čvorova
  Stream<String> get messageStream;

  /// Stream za praćenje povezanih čvorova
  Stream<List<String>> get connectedPeers;
}
