/// Tipovi za logovanje

/// Nivo ozbiljnosti log poruke
enum LogLevel {
  info, // Informativne poruke
  warning, // Upozorenja koja ne zahtevaju hitnu akciju
  error, // Greške koje zahtevaju pažnju
  critical // Kritične greške koje zahtevaju hitnu intervenciju
}

/// Predstavlja jednu log poruku sa svim relevantnim informacijama
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? metadata;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.metadata,
  });
}
