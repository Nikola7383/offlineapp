import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseService {
  Future<void> initialize();
  Future<void> dispose();
}

abstract class BaseAsyncService extends BaseService {
  Future<void> reconnect();
  Future<void> pause();
  Future<void> resume();
}

abstract class BaseSecureService extends BaseService {
  Future<void> lock();
  Future<void> unlock();
  bool get isLocked;
}

abstract class BaseStateService extends BaseService {
  Stream<ServiceState> get stateStream;
  ServiceState get currentState;
}

enum ServiceState { initial, initializing, ready, error, disposed }
