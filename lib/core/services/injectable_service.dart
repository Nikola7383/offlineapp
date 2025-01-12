import 'package:injectable/injectable.dart';
import '../interfaces/logger_service_interface.dart';

/// Osnovna klasa za sve servise koji koriste dependency injection
abstract class InjectableService {
  final ILoggerService logger;

  InjectableService(this.logger);
}
