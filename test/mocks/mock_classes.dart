import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';
import 'package:secure_event_app/core/mesh/mesh_network.dart';
import 'package:secure_event_app/core/storage/database_service.dart';

@GenerateMocks([LoggerService, MeshNetwork, DatabaseService])
void main() {}

class MockMeshNetwork extends Mock implements MeshNetwork {}

class MockLogger extends Mock implements LoggerService {}

class MockStorage extends Mock implements DatabaseService {}
