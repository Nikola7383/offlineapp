import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_app/services/api_service.dart';

class MockDio extends Mock implements Dio {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ApiService apiService;
  late MockDio mockDio;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockDio = MockDio();
    mockPrefs = MockSharedPreferences();
    apiService = ApiService();
    // Inject mocks
  });

  group('ApiService Tests', () {
    test('login should store token on successful response', () async {
      // Arrange
      final mockResponse = Response(
        data: {'token': 'test_token'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      when(mockDio.post('/auth/login', data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);
      when(mockPrefs.setString('auth_token', 'test_token'))
          .thenAnswer((_) async => true);

      // Act
      final result = await apiService.login('test', 'password');

      // Assert
      expect(result, 'test_token');
      verify(mockPrefs.setString('auth_token', 'test_token')).called(1);
    });

    test('getMessages should return list of messages', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'messages': [
            {
              'id': '1',
              'content': 'Test message',
              'sender': 'Test sender',
              'timestamp': '2024-03-19T12:00:00Z',
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      when(mockDio.get('/messages',
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final messages = await apiService.getMessages();

      // Assert
      expect(messages.length, 1);
      expect(messages.first.content, 'Test message');
    });
  });
}
