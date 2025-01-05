import 'package:flutter/foundation.dart';
import 'package:archive/archive.dart';

class StorageService {
  final DatabaseService _db;
  final LoggerService _logger;

  StorageService({
    required DatabaseService db,
    required LoggerService logger,
  })  : _db = db,
        _logger = logger;

  // Kompresija teksta za efikasnije skladištenje
  Future<String> compressMessage(String content) async {
    try {
      final bytes = utf8.encode(content);
      final compressed = GZipEncoder().encode(bytes);
      return base64Encode(compressed!);
    } catch (e) {
      _logger.error('Greška pri kompresiji: $e');
      return content; // Fallback na original ako kompresija ne uspe
    }
  }

  // Dekompresija pri čitanju
  Future<String> decompressMessage(String compressed) async {
    try {
      final bytes = base64Decode(compressed);
      final decompressed = GZipDecoder().decodeBytes(bytes);
      return utf8.decode(decompressed);
    } catch (e) {
      _logger.error('Greška pri dekompresiji: $e');
      return compressed; // Fallback na original
    }
  }

  // Čišćenje starih poruka (zadržavamo poslednjih X dana)
  Future<void> cleanupOldMessages({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      // Prvo kompresujemo i arhiviramo stare poruke
      final oldMessages = await _db.getMessagesBefore(cutoffDate);
      if (oldMessages.isNotEmpty) {
        await _archiveOldMessages(oldMessages);
        // Zatim brišemo iz glavne baze
        await _db.deleteMessagesBefore(cutoffDate);
      }
    } catch (e) {
      _logger.error('Greška pri čišćenju: $e');
    }
  }

  // Arhiviranje starih poruka pre brisanja
  Future<void> _archiveOldMessages(List<Message> messages) async {
    try {
      final archive = Archive();

      for (final msg in messages) {
        final compressed = await compressMessage(msg.content);
        archive.addFile(
          ArchiveFile(
            'message_${msg.id}.txt',
            compressed.length,
            compressed,
          ),
        );
      }

      final encoded = ZipEncoder().encode(archive);
      if (encoded == null) return;

      final archivePath = await _getArchivePath();
      await File(archivePath).writeAsBytes(encoded);
    } catch (e) {
      _logger.error('Greška pri arhiviranju: $e');
    }
  }

  // Automatsko čišćenje kada storage pređe određenu veličinu
  Future<void> checkStorageAndCleanup() async {
    try {
      final dbSize = await _db.getDatabaseSize();
      final maxSize = 50 * 1024 * 1024; // 50MB limit

      if (dbSize > maxSize) {
        // Prvo pokušaj sa 30 dana
        await cleanupOldMessages(daysToKeep: 30);

        // Ako i dalje prelazi limit, smanji na 15 dana
        final newSize = await _db.getDatabaseSize();
        if (newSize > maxSize) {
          await cleanupOldMessages(daysToKeep: 15);
        }
      }
    } catch (e) {
      _logger.error('Greška pri proveri storage-a: $e');
    }
  }
}
