abstract class InjectableService {
  @protected
  final LoggerService logger;

  InjectableService(this.logger);

  @mustCallSuper
  Future<void> initialize() async {
    logger.info('Initializing ${runtimeType.toString()}');
  }

  @mustCallSuper
  Future<void> dispose() async {
    logger.info('Disposing ${runtimeType.toString()}');
  }
}
