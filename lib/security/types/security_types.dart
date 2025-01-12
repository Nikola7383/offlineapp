import 'package:flutter/material.dart';

enum SecurityLevel { low, medium, high, critical }

enum SecurityActionType { p2pConnection, dataSharing, recovery, systemChange }

class SecurityAction {
  final SecurityActionType type;
  final String description;
  final SecurityLevel level;
  final Map<String, dynamic> metadata;

  const SecurityAction({
    required this.type,
    required this.description,
    required this.level,
    this.metadata = const {},
  });
}

class SecurityContext {
  final BuildContext buildContext;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> contextData;

  const SecurityContext({
    required this.buildContext,
    required this.userId,
    required this.timestamp,
    this.contextData = const {},
  });
}
