import 'dart:io';

// Najjednostavnija moguća implementacija
void logChat(String message, bool isAI) {
  try {
    final file = File(
        'C:\\Users\\${Platform.environment['USERNAME']}\\Documents\\our_chat.txt');
    file.writeAsStringSync(
        '${DateTime.now()} - ${isAI ? "AI" : "USER"}: $message\n',
        mode: FileMode.append);
  } catch (e) {
    print('Error logging chat: $e');
  }
}
