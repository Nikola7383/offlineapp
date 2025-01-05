import 'package:dio/dio.dart';
import 'package:shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final Dio _dio = Dio();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio.options.baseUrl = 'https://api.glasnik.com/v1';
    _dio.interceptors.add(AuthInterceptor());
  }

  Future<String> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final token = response.data['token'];
      await SharedPreferences.getInstance()
        ..setString('auth_token', token);

      return token;
    } catch (e) {
      throw Exception('Greška pri prijavi: $e');
    }
  }

  Future<List<Message>> getMessages({int page = 1}) async {
    try {
      final response = await _dio.get('/messages', queryParameters: {
        'page': page,
        'limit': 20,
      });

      return (response.data['messages'] as List)
          .map((json) => Message.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Greška pri učitavanju poruka: $e');
    }
  }

  Future<void> sendMessage(String content, {List<String>? attachments}) async {
    try {
      await _dio.post('/messages', data: {
        'content': content,
        'attachments': attachments,
      });
    } catch (e) {
      throw Exception('Greška pri slanju poruke: $e');
    }
  }
}
