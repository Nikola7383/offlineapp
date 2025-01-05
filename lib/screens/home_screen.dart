import 'package:flutter/material.dart';
import '../core/database/database_service.dart';
import '../core/mesh/mesh_network.dart';
import '../core/security/encryption_service.dart';
import '../core/services/logger_service.dart';

class HomeScreen extends StatefulWidget {
  final DatabaseService db;
  final MeshNetwork mesh;
  final EncryptionService encryption;
  final LoggerService logger;

  const HomeScreen({
    super.key,
    required this.db,
    required this.mesh,
    required this.encryption,
    required this.logger,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.mesh.start(); // Pokrećemo mesh mrežu
  }

  @override
  void dispose() {
    widget.mesh.stop(); // Zaustavljamo mesh mrežu
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glasnik'),
      ),
      body: const Center(
        child: Text('Dobrodošli u Glasnik'),
      ),
    );
  }
}
