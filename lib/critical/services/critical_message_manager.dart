import 'package:injectable/injectable.dart';
import '../models/critical_message.dart';

@injectable
class CriticalMessageManager {
  Future<void> initialize() async {}
  Future<void> dispose() async {}

  Future<void> sendCriticalMessage(CriticalMessage message) async {
    // TODO: Implementirati
    throw UnimplementedError();
  }

  Future<List<CriticalMessage>> getPendingMessages() async {
    // TODO: Implementirati
    throw UnimplementedError();
  }

  Stream<CriticalMessage> watchMessages() async* {
    // TODO: Implementirati
    throw UnimplementedError();
  }
}
