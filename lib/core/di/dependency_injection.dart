import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../interfaces/logger_service_interface.dart';
import '../services/logger_service.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async {
  // Registrujemo singleton instance
  getIt.registerSingleton<ILoggerService>(LoggerService());

  // Registrujemo SharedPreferences kao singleton
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Inicijalizujemo sve servise
  await getIt<ILoggerService>().initialize();
}

Future<void> disposeDependencies() async {
  // Oslobađamo resurse svih servisa
  await getIt<ILoggerService>().dispose();

  // Resetujemo GetIt
  await getIt.reset();
}
