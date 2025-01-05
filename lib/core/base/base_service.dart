import 'dart:async';
import '../services/logger_service.dart';
import 'package:meta/meta.dart';

abstract class BaseService {
  final LoggerService logger;
  final _readyCompleter = Completer<void>();

  BaseService({required this.logger});

  Future<void> get ready => _readyCompleter.future;

  @protected
  void markReady() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  @protected
  void markError(Object error) {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError(error);
    }
  }

  Future<T> safeExecute<T>(
    Future<T> Function() action, {
    String? errorMessage,
    T? defaultValue,
    bool throwError = false,
  }) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      logger.error(errorMessage ?? 'Service error', e, stackTrace);
      if (throwError) rethrow;
      return defaultValue as T;
    }
  }

  Future<void> initialize() async {
    try {
      await onInitialize();
      markReady();
    } catch (e) {
      markError(e);
      rethrow;
    }
  }

  @protected
  Future<void> onInitialize() async {
    // Override u konkretnim implementacijama
  }

  void dispose() {
    onDispose();
  }

  @protected
  void onDispose() {
    // Override u konkretnim implementacijama
  }
}
