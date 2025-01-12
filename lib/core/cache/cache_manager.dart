import 'dart:async';
import '../interfaces/cache_manager_interface.dart';

/// Klasa za upravljanje kešom
class CacheManager implements ICacheManager {
  final Map<String, CacheEntry> _cache = {};

  @override
  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    _cache[key] = CacheEntry(value, ttl);
  }

  @override
  Future<dynamic> get(String key) async {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }

  @override
  Future<bool> exists(String key) async {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<void> updateMultiple(Map<String, CacheEntry> entries) async {
    _cache.addAll(entries);
  }

  @override
  Future<List<String>> getKeys() async {
    return _cache.keys.toList();
  }

  @override
  Future<Map<String, dynamic>> getAll() async {
    final result = <String, dynamic>{};
    for (final entry in _cache.entries) {
      if (!entry.value.isExpired) {
        result[entry.key] = entry.value.value;
      }
    }
    return result;
  }
}

/// Klasa koja predstavlja jedan unos u kešu
class CacheEntry {
  final dynamic value;
  final DateTime? expiresAt;

  CacheEntry(this.value, Duration? ttl)
      : expiresAt = ttl != null ? DateTime.now().add(ttl) : null;

  /// Da li je unos istekao
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Kreira CacheEntry iz JSON mape
  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      json['value'],
      json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt']).difference(DateTime.now())
          : null,
    );
  }

  /// Konvertuje CacheEntry u JSON mapu
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
