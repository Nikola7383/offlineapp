import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../interfaces/base_service.dart';
import '../interfaces/logger_service.dart';
import '../interfaces/database_service.dart';
import '../interfaces/cache_manager.dart';
import '../interfaces/mesh_network.dart';
import '../interfaces/encryption_service.dart';
import '../interfaces/session_service.dart';
import '../interfaces/key_rotation_manager.dart';

@InjectableInit(
  initializerName: 'initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async {
  final getIt = GetIt.instance;

  // Registrujemo servise
  _registerServices(getIt);

  // Inicijalizacija servisa
  await _initializeServices(getIt);

  // Validacija zavisnosti
  await _validateDependencies(getIt);
}

void _registerServices(GetIt getIt) {
  // TODO: Implementirati registraciju konkretnih servisa
}

Future<void> _initializeServices(GetIt getIt) async {
  final services = <IBaseService>[];

  // Dodajemo servise u listu samo ako su registrovani
  void addIfRegistered<T extends IBaseService>() {
    if (getIt.isRegistered<T>()) {
      services.add(getIt<T>());
    }
  }

  addIfRegistered<ILoggerService>();
  addIfRegistered<IDatabaseService>();
  addIfRegistered<ICacheManager>();
  addIfRegistered<IMeshNetwork>();
  addIfRegistered<IEncryptionService>();
  addIfRegistered<ISessionService>();
  addIfRegistered<IKeyRotationManager>();

  // Inicijalizujemo sve registrovane servise
  for (final service in services) {
    await service.initialize();
  }
}

Future<void> _validateDependencies(GetIt getIt) async {
  void validateService<T extends IBaseService>() {
    if (!getIt.isRegistered<T>()) {
      throw DependencyException(
        'Required service ${T.toString()} is not registered',
      );
    }
  }

  validateService<ILoggerService>();
  validateService<IDatabaseService>();
  validateService<ICacheManager>();
  validateService<IMeshNetwork>();
  validateService<IEncryptionService>();
  validateService<ISessionService>();
  validateService<IKeyRotationManager>();
}

class DependencyException implements Exception {
  final String message;
  DependencyException(this.message);

  @override
  String toString() => 'DependencyException: $message';
}
