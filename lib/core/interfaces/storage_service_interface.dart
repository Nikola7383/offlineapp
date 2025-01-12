import 'base_service.dart';
import '../models/file_info.dart';

/// Interfejs za upravljanje skladištem
abstract class IStorageService implements IService {
  /// Čita fajl iz skladišta
  Future<List<int>> readFile(String path);

  /// Upisuje fajl u skladište
  Future<void> writeFile(String path, List<int> data);

  /// Briše fajl iz skladišta
  Future<void> deleteFile(String path);

  /// Proverava da li fajl postoji
  Future<bool> exists(String path);

  /// Vraća informacije o fajlu
  Future<FileInfo> getFileInfo(String path);

  /// Kopira fajl na novu lokaciju
  Future<void> copyFile(String sourcePath, String destinationPath);

  /// Premešta fajl na novu lokaciju
  Future<void> moveFile(String sourcePath, String destinationPath);

  /// Kreira direktorijum
  Future<void> createDirectory(String path);

  /// Briše direktorijum
  Future<void> deleteDirectory(String path);

  /// Lista sadržaj direktorijuma
  Future<List<FileInfo>> listDirectory(String path);

  /// Vraća ukupnu veličinu skladišta
  Future<int> getTotalSize();

  /// Vraća preostali prostor u skladištu
  Future<int> getFreeSpace();
}
