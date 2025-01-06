import 'dart:io';
import 'dart:async';

class AIConversationHistory {
  static const String FOLDER_NAME = 'AI_History';
  static const String HISTORY_FILENAME = 'ai_conversation_history.txt';

  static AIConversationHistory? _instance;
  late final Directory _directory;
  late final File _file;

  AIConversationHistory._();

  static Future<AIConversationHistory> getInstance() async {
    if (_instance == null) {
      _instance = AIConversationHistory._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    try {
      // 1. Kreiramo direktorijum u Documents
      final userHome = Platform.environment['USERPROFILE'] ?? '';
      final documentsPath = '$userHome\\Documents';
      _directory = Directory('$documentsPath\\$FOLDER_NAME');

      print('Creating directory at: ${_directory.path}');
      await _directory.create(recursive: true);

      // 2. Kreiramo fajl
      _file = File('${_directory.path}\\$HISTORY_FILENAME');

      print('Creating file at: ${_file.path}');
      if (!await _file.exists()) {
        await _file.create();
        // Dodajemo inicijalni header
        await _file.writeAsString('''
=== AI CONVERSATION HISTORY ===
Created: ${DateTime.now().toIso8601String()}
===============================

''');
      }

      print('File exists: ${await _file.exists()}');
      print('File path: ${_file.path}');
    } catch (e, stack) {
      print('Error during initialization:');
      print(e);
      print(stack);
      rethrow;
    }
  }

  Future<void> saveConversation(String message, bool isAI,
      {String? context, String? messageType, String? replyTo}) async {
    try {
      final timestamp = DateTime.now();
      final entry = '''
=== MESSAGE ===
Time: ${timestamp.toIso8601String()}
Local Time: ${timestamp.toLocal()}
Type: ${isAI ? 'AI' : 'USER'}
${context != null ? 'Context: $context\n' : ''}
${messageType != null ? 'Message Type: $messageType\n' : ''}
${replyTo != null ? 'In Reply To: $replyTo\n' : ''}
Content:
$message
----------------------------------------

''';

      await _file.writeAsString(entry, mode: FileMode.append);
      print('Saved message to: ${_file.path}');
    } catch (e) {
      print('Error saving message: $e');
      rethrow;
    }
  }

  Future<String> readHistory() async {
    try {
      if (await _file.exists()) {
        return await _file.readAsString();
      }
      return 'No history found.';
    } catch (e) {
      return 'Error reading history: $e';
    }
  }

  Future<void> openHistoryFile() async {
    try {
      if (await _file.exists()) {
        print('Opening file: ${_file.path}');
        if (Platform.isWindows) {
          await Process.run('notepad.exe', [_file.path]);
        }
      } else {
        print('File does not exist at: ${_file.path}');
      }
    } catch (e) {
      print('Error opening file: $e');
      rethrow;
    }
  }

  String getFilePath() {
    return _file.path;
  }

  Future<void> saveRealConversation(
      String userMessage, String aiResponse) async {
    try {
      // Čuvamo korisnikovu poruku
      await saveConversation(userMessage, false,
          context: "Real AI Conversation",
          messageType: "user_message",
          replyTo: "ongoing_conversation");

      // Čuvamo AI odgovor
      await saveConversation(aiResponse, true,
          context: "Real AI Conversation",
          messageType: "ai_response",
          replyTo: userMessage.substring(0, Math.min(30, userMessage.length)) +
              "...");

      print('Saved real conversation exchange at: ${_file.path}');
    } catch (e) {
      print('Error saving real conversation: $e');
    }
  }
}
