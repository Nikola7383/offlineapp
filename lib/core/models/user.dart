enum UserRole { guest, regular, seed, admin }

class User {
  final String id;
  final String username;
  final String passwordHash;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'role': role.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      passwordHash: map['passwordHash'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == map['role'],
        orElse: () => UserRole.guest,
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
