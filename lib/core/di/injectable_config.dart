import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'injectable_config.config.dart';
import 'service_module.dart';
import '../interfaces/logger_service_interface.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}

Future<void> configureDependencies() async {
  // Registracija svih servisa
  init(getIt);

  // Inicijalizacija SharedPreferences pre ostalih servisa
  await getIt.isReady<SharedPreferences>();

  // Inicijalizacija logger servisa
  final logger = getIt<ILoggerService>();
  await logger.initialize();

  logger.info('Dependency injection je uspešno konfigurisan');
}

Future<void> disposeDependencies() async {
  // Dispose logger servisa
  final logger = getIt<ILoggerService>();
  try {
    await logger.dispose();
    logger.info('Logger servis je uspešno disposed');
  } catch (e) {
    print('Greška prilikom dispose logger servisa: $e');
  }

  getIt.reset();
}
