import 'package:injectable/injectable.dart';
import '../services/logger_service.dart';

@injectable
abstract class InjectableService {
  final LoggerService logger;

  InjectableService(this.logger);

  @PostConstruct()
  Future<void> initialize() async {
    // Override in concrete implementations
  }

  @disposeMethod
  Future<void> dispose() async {
    // Override in concrete implementations
  }
}
