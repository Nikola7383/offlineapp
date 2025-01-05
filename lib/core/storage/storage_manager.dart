import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StorageManager {
  final DatabaseService _db;
  final LoggerService _logger;
  final int _maxStorageSize = 100 * 1024 * 1024; // 100MB
  final int _backupRetention = 3; // Čuvamo 3 backupa

  StorageManager({
    required DatabaseService db,
    required LoggerService logger,
  })  : _db = db,
        _logger = logger;

  Future<void> manageStorage() async {
    try {
      final currentSize = await _calculateStorageSize();
      if (currentSize > _maxStorageSize) {
        await _cleanupOldMessages();
      }

      // Periodični backup
      if (await _shouldCreateBackup()) {
        await createBackup();
      }

      // Cleanup starih backupa
      await _cleanupOldBackups();
    } catch (e) {
      _logger.error('Greška pri upravljanju storage-om: $e');
    }
  }

  Future<void> _cleanupOldMessages() async {
    try {
      // Prvo arhiviraj stare poruke
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final oldMessages = await _db.getMessagesBefore(cutoffDate);

      if (oldMessages.isNotEmpty) {
        await _archiveMessages(oldMessages);
        await _db.deleteMessagesBefore(cutoffDate);
      }
    } catch (e) {
      _logger.error('Greška pri čišćenju starih poruka: $e');
    }
  }

  Future<void> createBackup() async {
    try {
      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().toIso8601String();
      final backupFile = File('${backupDir.path}/backup_$timestamp.db');

      // Backup baze
      final dbFile = await _db.getDatabaseFile();
      await dbFile.copy(backupFile.path);

      // Backup konfiguracije
      final configBackup = await _createConfigBackup();
      await File('${backupDir.path}/config_$timestamp.json')
          .writeAsString(jsonEncode(configBackup));

      _logger.info('Backup kreiran: $timestamp');
    } catch (e) {
      _logger.error('Greška pri kreiranju backup-a: $e');
    }
  }

  Future<void> restoreFromBackup(String timestamp) async {
    try {
      final backupDir = await _getBackupDirectory();
      final backupFile = File('${backupDir.path}/backup_$timestamp.db');
      final configFile = File('${backupDir.path}/config_$timestamp.json');

      if (!await backupFile.exists()) {
        throw Exception('Backup fajl ne postoji');
      }

      // Restore baze
      final dbFile = await _db.getDatabaseFile();
      await _db.close();
      await backupFile.copy(dbFile.path);

      // Restore konfiguracije
      if (await configFile.exists()) {
        final configData = jsonDecode(await configFile.readAsString());
        await _restoreConfig(configData);
      }

      _logger.info('Backup vraćen: $timestamp');
    } catch (e) {
      _logger.error('Greška pri vraćanju backup-a: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createConfigBackup() async {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'version': await _db.getDatabaseVersion(),
      'settings': await _getAppSettings(),
    };
  }
}
