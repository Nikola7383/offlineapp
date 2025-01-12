/// Interfejs za tipove koji podržavaju JSON serijalizaciju
abstract class JsonSerializable {
  /// Konvertuje objekat u Map<String, dynamic>
  Map<String, dynamic> toJson();

  /// Factory konstruktor koji kreira objekat iz Map<String, dynamic>
  factory JsonSerializable.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Subclasses must implement fromJson');
  }
}
