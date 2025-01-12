import 'package:injectable/injectable.dart';
import '../interfaces/logger_service_interface.dart';
import '../services/logger_service.dart';

/// Modul za registraciju core servisa
@module
abstract class ServiceModule {
  /// Registracija LoggerService kao singleton
  @singleton
  ILoggerService get loggerService => LoggerService();
}
