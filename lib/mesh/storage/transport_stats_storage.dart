import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart';
import '../transport/transport_stats_collector.dart';

/// Upravlja bezbednim čuvanjem statistike transporta
class TransportStatsStorage {
  static const String STATS_DIRECTORY = 'transport_stats';
  static const String STATS_FILE_PREFIX = 'stats_';
  static const String STATS_FILE_EXTENSION = '.enc';

  // Ključ za enkripciju (treba da se čuva bezbedno)
  late final Key _encryptionKey;
  late final Encrypter _encrypter;
  late final IV _iv;

  // Direktorijum za čuvanje statistike
  late final Directory _statsDir;

  // Keš za statistiku u memoriji
  final Map<String, List<Map<String, dynamic>>> _statsCache = {};

  // Maksimalan broj dana za čuvanje statistike
  static const int MAX_STATS_AGE_DAYS = 30;

  /// Inicijalizuje storage
  Future<void> initialize() async {
    await _initializeEncryption();
    await _initializeStorage();
    await _loadStatsFromDisk();

    // Periodično čisti staru statistiku
    Timer.periodic(const Duration(days: 1), (_) => _cleanOldStats());
  }

  /// Čuva snapshot statistike za određeni transport
  Future<void> saveStats(String transportId, Map<String, dynamic> stats) async {
    // Dodaj timestamp ako ne postoji
    stats['timestamp'] ??= DateTime.now().toIso8601String();

    // Dodaj u keš
    _statsCache[transportId] ??= [];
    _statsCache[transportId]!.add(stats);

    // Sačuvaj na disk
    await _saveToDisk(transportId);
  }

  /// Vraća statistiku za određeni transport i period
  List<Map<String, dynamic>> getStats(
    String transportId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final stats = _statsCache[transportId] ?? [];
    if (startDate == null && endDate == null) return stats;

    return stats.where((stat) {
      final timestamp = DateTime.parse(stat['timestamp'] as String);
      if (startDate != null && timestamp.isBefore(startDate)) return false;
      if (endDate != null && timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  /// Briše svu statistiku za određeni transport
  Future<void> clearStats(String transportId) async {
    _statsCache.remove(transportId);
    final file = await _getStatsFile(transportId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Inicijalizuje enkripciju
  Future<void> _initializeEncryption() async {
    // TODO: Implementirati bezbedno čuvanje ključa
    // Za sada generišemo novi ključ pri svakom pokretanju
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    _encryptionKey = Key(Uint8List.fromList(keyBytes));
    _iv = IV.fromSecureRandom(16);
    _encrypter = Encrypter(AES(_encryptionKey));
  }

  /// Inicijalizuje storage direktorijum
  Future<void> _initializeStorage() async {
    final appDir = await getApplicationDocumentsDirectory();
    _statsDir = Directory('${appDir.path}/$STATS_DIRECTORY');
    if (!await _statsDir.exists()) {
      await _statsDir.create(recursive: true);
    }
  }

  /// Učitava statistiku sa diska
  Future<void> _loadStatsFromDisk() async {
    final files = await _statsDir
        .list()
        .where((f) => f.path.endsWith(STATS_FILE_EXTENSION))
        .toList();

    for (final file in files) {
      try {
        final transportId = _getTransportIdFromPath(file.path);
        final encrypted = await File(file.path).readAsString();
        final decrypted = _encrypter.decrypt64(encrypted, iv: _iv);
        final stats =
            (jsonDecode(decrypted) as List).cast<Map<String, dynamic>>();
        _statsCache[transportId] = stats;
      } catch (e) {
        print('Greška pri učitavanju statistike: $e');
      }
    }
  }

  /// Čuva statistiku na disk
  Future<void> _saveToDisk(String transportId) async {
    try {
      final stats = _statsCache[transportId];
      if (stats == null) return;

      final file = await _getStatsFile(transportId);
      final json = jsonEncode(stats);
      final encrypted = _encrypter.encrypt(json, iv: _iv).base64;
      await file.writeAsString(encrypted);
    } catch (e) {
      print('Greška pri čuvanju statistike: $e');
    }
  }

  /// Vraća fajl za čuvanje statistike
  Future<File> _getStatsFile(String transportId) async {
    return File(
        '${_statsDir.path}/$STATS_FILE_PREFIX$transportId$STATS_FILE_EXTENSION');
  }

  /// Izvlači ID transporta iz putanje fajla
  String _getTransportIdFromPath(String path) {
    final fileName = path.split('/').last;
    return fileName
        .substring(
          STATS_FILE_PREFIX.length,
          fileName.length - STATS_FILE_EXTENSION.length,
        )
        .toLowerCase();
  }

  /// Čisti staru statistiku
  Future<void> _cleanOldStats() async {
    final threshold =
        DateTime.now().subtract(Duration(days: MAX_STATS_AGE_DAYS));

    // Čisti keš
    for (final transportId in _statsCache.keys) {
      _statsCache[transportId] = _statsCache[transportId]!
          .where((stat) =>
              DateTime.parse(stat['timestamp'] as String).isAfter(threshold))
          .toList();
    }

    // Sačuvaj očišćenu statistiku
    for (final transportId in _statsCache.keys) {
      await _saveToDisk(transportId);
    }
  }
}
