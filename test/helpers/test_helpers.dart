import 'package:mockito/annotations.dart';
import 'package:secure_event_app/core/interfaces/logger_service.dart';
import 'package:secure_event_app/core/interfaces/mesh_service.dart';
import 'package:secure_event_app/core/interfaces/storage_service.dart';
import 'package:secure_event_app/core/interfaces/database_service.dart';
import 'package:secure_event_app/core/models/message.dart';

@GenerateMocks([
  ILoggerService,
  IMeshService,
  IStorageService,
  IDatabaseService,
], customMocks: [
  MockSpec<Message>(as: #MockMessage),
])
void main() {}
