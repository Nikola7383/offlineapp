import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class MyApp extends StatelessWidget {
  final LoggerService logger;
  final DatabaseService db;
  final MeshNetwork mesh;
  final EncryptionService encryption;

  const MyApp({
    super.key,
    required this.logger,
    required this.db,
    required this.mesh,
    required this.encryption,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glasnik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(
        db: db,
        mesh: mesh,
        encryption: encryption,
        logger: logger,
      ),
    );
  }
}
