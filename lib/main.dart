import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_event_app/core/core.dart';
import 'package:secure_event_app/core/di/service_locator.dart';
import 'package:secure_event_app/core/providers/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator
  await setupServiceLocator();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(logger: getIt<LoggerService>()),
      child: const SecureEventApp(),
    ),
  );
}

class SecureEventApp extends StatelessWidget {
  const SecureEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Event App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Consumer<AppState>(
        builder: (context, appState, child) {
          if (!appState.isInitialized) {
            return const InitialSetupScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}
