import 'base_service.dart';

abstract class ICacheManager implements IBaseService {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> exists(String key);
  Future<void> setMany(Map<String, dynamic> entries, {Duration? ttl});
  Future<Map<String, dynamic>> getMany(List<String> keys);
}
