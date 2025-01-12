import 'package:injectable/injectable.dart';
import '../interfaces/logger_service.dart';

abstract class Disposable {
  Future<void> dispose();
}

abstract class InjectableService implements Disposable {
  final ILoggerService _logger;

  InjectableService(this._logger);

  @PostConstruct()
  Future<void> initialize() async {
    _logger.info('Initializing ${runtimeType.toString()}');
  }

  @override
  @disposeMethod
  Future<void> dispose() async {
    _logger.info('Disposing ${runtimeType.toString()}');
  }
}
