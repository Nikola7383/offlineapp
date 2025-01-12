/// Tip fajla u sistemu
enum FileType { document, image, video, audio, archive, other }

/// Predstavlja informacije o fajlu u sistemu
class FileInfo {
  final String id;
  final String name;
  final String path;
  final FileType type;
  final int size;
  final DateTime createdAt;
  final DateTime? lastModified;
  final bool isEncrypted;
  final Map<String, dynamic>? metadata;

  const FileInfo({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.createdAt,
    this.lastModified,
    this.isEncrypted = false,
    this.metadata,
  });

  /// Kreira kopiju sa izmenjenim poljima
  FileInfo copyWith({
    String? id,
    String? name,
    String? path,
    FileType? type,
    int? size,
    DateTime? createdAt,
    DateTime? lastModified,
    bool? isEncrypted,
    Map<String, dynamic>? metadata,
  }) {
    return FileInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      metadata: metadata ?? this.metadata,
    );
  }
}
