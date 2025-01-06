import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:secure_event_app/core/chat/ai_conversation_history.dart';

void main() {
  late AIConversationHistory history;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Kreiramo stvarni direktorijum pre testa
    final userHome = Platform.environment['USERPROFILE']!;
    final dir = Directory('$userHome\\Documents\\AI_History');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    history = await AIConversationHistory.getInstance();
  });

  test('Real environment test', () async {
    print('\n=== Test Environment ===');
    print('User home: ${Platform.environment['USERPROFILE']}');
    print('Current directory: ${Directory.current.path}');
    
    // Test writing
    await history.saveConversation(
      "Test poruka u pravom okruženju",
      false,
      context: "Real Environment Test",
      messageType: "test"
    );
    
    // Get real file path
    final filePath = history.getFilePath();
    print('\nFile location: $filePath');
    
    // Verify file
    final file = File(filePath);
    if (await file.exists()) {
      print('\n=== File Content ===');
      print(await file.readAsString());
      print('\nOpening file...');
      await history.openHistoryFile();
    } else {
      print('File not found at: $filePath');
    }
  });
}
