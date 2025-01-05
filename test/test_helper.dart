import 'test_imports.dart';

@GenerateMocks([
  LoggerService,
  MeshNetwork,
  DatabaseService,
  LoggerServiceImpl,
  MeshNetworkImpl,
  DatabaseServiceImpl,
])
void main() {}

// Kreiramo mock instance
MockLoggerService getMockLogger() {
  final mock = MockLoggerService();
  when(mock.info(any)).thenAnswer((_) => Future.value());
  when(mock.error(any, any)).thenAnswer((_) => Future.value());
  when(mock.warning(any)).thenAnswer((_) => Future.value());
  return mock;
}

MockMeshNetwork getMockMeshNetwork() {
  final mock = MockMeshNetwork();
  when(mock.initialize()).thenAnswer((_) => Future.value());
  when(mock.sendBatch(any)).thenAnswer((_) => Future.value());
  return mock;
}

MockDatabaseService getMockDatabaseService() {
  final mock = MockDatabaseService();
  when(mock.initialize()).thenAnswer((_) => Future.value());
  when(mock.getMessages(limit: anyNamed('limit'), offset: anyNamed('offset')))
      .thenAnswer((_) => Future.value([]));
  when(mock.saveMessage(any)).thenAnswer((_) => Future.value());
  when(mock.deleteMessage(any)).thenAnswer((_) => Future.value());
  return mock;
}

export 'test_helper.mocks.dart';
