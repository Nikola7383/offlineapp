/// Predstavlja korisnika sistema
class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.metadata,
  });

  /// Kreira kopiju sa izmenjenim poljima
  User copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}
