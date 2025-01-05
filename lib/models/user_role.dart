enum UserRole {
  guest, // Samo tekst
  regular, // Samo tekst
  seed, // Tekst + slike + fajlovi (ograničenja)
  admin // Pun pristup
}

class UserPermissions {
  static const maxMessageLength = 2000; // 2KB za tekst

  static const Map<UserRole, MessageRestrictions> restrictions = {
    UserRole.guest: MessageRestrictions(
      canSendText: true,
      maxTextLength: 1000, // 1KB limit za guest
      canSendFiles: false,
      canSendImages: false,
      maxFileSize: 0,
    ),
    UserRole.regular: MessageRestrictions(
      canSendText: true,
      maxTextLength: 2000, // 2KB limit za regular
      canSendFiles: false,
      canSendImages: false,
      maxFileSize: 0,
    ),
    UserRole.seed: MessageRestrictions(
      canSendText: true,
      maxTextLength: 5000, // 5KB za seed
      canSendFiles: true,
      canSendImages: true,
      maxFileSize: 5 * 1024 * 1024, // 5MB ukupno
    ),
    UserRole.admin: MessageRestrictions(
      canSendText: true,
      maxTextLength: 10000, // 10KB za admin
      canSendFiles: true,
      canSendImages: true,
      maxFileSize: 10 * 1024 * 1024, // 10MB ukupno
    ),
  };
}

class MessageRestrictions {
  final bool canSendText;
  final int maxTextLength;
  final bool canSendFiles;
  final bool canSendImages;
  final int maxFileSize;

  const MessageRestrictions({
    required this.canSendText,
    required this.maxTextLength,
    required this.canSendFiles,
    required this.canSendImages,
    required this.maxFileSize,
  });
}
