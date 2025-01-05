class Room {
  final String id;
  final int number;
  final String lastMessage;
  final DateTime lastActivity;

  const Room({
    required this.id,
    required this.number,
    required this.lastMessage,
    required this.lastActivity,
  });
}
