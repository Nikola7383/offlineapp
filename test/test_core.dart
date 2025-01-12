import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:secure_event_app/core/interfaces/database_interface.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/core/interfaces/mesh_interface.dart';
import 'package:secure_event_app/core/interfaces/storage_service.dart';
import 'package:secure_event_app/core/interfaces/sync_service.dart';
import 'package:secure_event_app/core/models/message.dart';

// Generišemo sve mockove na jednom mestu
@GenerateMocks([
  ILoggerService,
  DatabaseService,
  MeshNetwork,
  IStorageService,
  ISyncService,
], customMocks: [
  MockSpec<Message>(as: #MockMessage)
])
void main() {}
