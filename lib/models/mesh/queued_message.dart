class QueuedMessage implements Comparable<QueuedMessage> {
  final SecureMessage message;
  final int priority;
  final DateTime queuedAt;

  QueuedMessage({
    required this.message,
    required this.priority,
  }) : queuedAt = DateTime.now();

  @override
  int compareTo(QueuedMessage other) {
    // Viši prioritet ide prvi
    return other.priority.compareTo(priority);
  }
}
