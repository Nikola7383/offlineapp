part of '../secure_event_app.dart';

enum UserRole { guest, regular, seed, admin }

class User {
  final String id;
  final String name;
  final AdvancedRole role;
  final bool isActive;
  final DateTime lastSeen;

  const User({
    required this.id,
    required this.name,
    required this.role,
    this.isActive = true,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();
}
