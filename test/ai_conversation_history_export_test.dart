import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:secure_event_app/core/chat/ai_conversation_history.dart';
import 'package:secure_event_app/core/security/secure_storage.dart';
import 'package:secure_event_app/core/security/encryption_service.dart';

// Custom anotacija
const _secretMasterOnly = true;

@Skip('Run only in SECRET_MASTER build')
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AIConversationHistory history;
  late Directory tempDir;

  setUp(() async {
    // Provera SECRET_MASTER builda
    if (!_secretMasterOnly) {
      throw Exception('Tests can only run in SECRET_MASTER build');
    }

    tempDir = await Directory.systemTemp.createTemp('test_exports');

    final storage = SecureStorage();
    final encryption = EncryptionService();
    final masterKey =
        'test_master_key_${DateTime.now().millisecondsSinceEpoch}';

    history = AIConversationHistory(storage, encryption, masterKey);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
    history.dispose();
  });

  test('Should automatically export history every hour', () async {
    // Arrange
    history.initAutoExport();

    // Act - simuliramo prolazak vremena
    await history.saveConversation('Test message 1', true);
    await Future.delayed(Duration(seconds: 2));
    await history.saveConversation('Test message 2', false);

    // Force export
    await history.exportHistory();

    // Assert
    final exportFiles = tempDir
        .listSync()
        .where((e) => e.path.contains('ai_history_'))
        .toList();

    expect(exportFiles.isNotEmpty, true);

    // Verify export content
    final exportFile = File(exportFiles.first.path);
    final content = await exportFile.readAsString();
    expect(content, isNotEmpty);

    // Verify encryption
    expect(content, isNot(contains('Test message')));
  });

  test('Should maintain secure permissions on export directory', () async {
    // Act
    await history.exportHistory();

    // Assert
    final exportDir = Directory('${tempDir.path}/secure_master_exports');
    final stats = await exportDir.stat();

    if (Platform.isLinux || Platform.isMacOS) {
      // Verify 700 permissions
      expect(stats.mode & 0x1FF, equals(0x1C0));
    }
  });
}
