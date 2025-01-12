import 'package:injectable/injectable.dart';
import '../models/critical_status.dart';

@injectable
class CriticalStateManager {
  Future<void> initialize() async {}
  Future<void> dispose() async {}

  Future<CriticalStatus> getCurrentState() async {
    // TODO: Implementirati
    throw UnimplementedError();
  }

  Future<void> updateState(CriticalStatus newState) async {
    // TODO: Implementirati
    throw UnimplementedError();
  }

  Stream<CriticalStatus> watchState() async* {
    // TODO: Implementirati
    throw UnimplementedError();
  }
}
