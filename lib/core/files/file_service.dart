import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../logging/logger_service.dart';
import '../security/encryption_service.dart';

class FileService {
  final LoggerService logger;
  final EncryptionService encryption;

  FileService({
    required this.logger,
    required this.encryption,
  });

  Future<FileAttachment?> saveFile(File file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final savedFile = await file.copy('${dir.path}/$fileName');

      return FileAttachment(
        id: DateTime.now().toIso8601String(),
        name: fileName,
        path: savedFile.path,
        size: await file.length(),
        type: _getFileType(fileName),
      );
    } catch (e) {
      logger.error('Failed to save file', e);
      return null;
    }
  }

  Future<bool> deleteFile(FileAttachment attachment) async {
    try {
      final file = File(attachment.path);
      await file.delete();
      return true;
    } catch (e) {
      logger.error('Failed to delete file', e);
      return false;
    }
  }

  FileType _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return FileType.image;
      case 'pdf':
        return FileType.pdf;
      case 'doc':
      case 'docx':
        return FileType.document;
      default:
        return FileType.other;
    }
  }
}

class FileAttachment {
  final String id;
  final String name;
  final String path;
  final int size;
  final FileType type;

  FileAttachment({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
  });
}

enum FileType {
  image,
  pdf,
  document,
  other,
}
