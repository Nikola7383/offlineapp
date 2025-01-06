import 'dart:io';

// Jedna klasa, jedna funkcija
class ChatLogger {
  static final file = File(
      'C:\\Users\\${Platform.environment['USERNAME']}\\Documents\\our_chat.txt');

  static void log(String message, bool isAI) {
    file.writeAsStringSync(
        '${DateTime.now()} - ${isAI ? "AI" : "USER"}: $message\n',
        mode: FileMode.append);
  }
}
