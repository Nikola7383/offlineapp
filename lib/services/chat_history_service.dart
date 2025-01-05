import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ChatMessage {
  final String content;
  final DateTime timestamp;
  final bool isUser; // true ako je poruka od korisnika, false ako je od AI

  ChatMessage({
    required this.content,
    required this.timestamp,
    required this.isUser,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isUser': isUser,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        isUser: json['isUser'],
      );
}

class ChatHistoryService {
  final String _filePath = 'chat_history.json';
  final String _backupPath = 'chat_history_backup.json';
  final Key _encryptionKey = Key.fromSecureRandom(32);
  final IV _iv = IV.fromSecureRandom(16);
  List<ChatMessage> _messages = [];

  // Učitaj istoriju
  Future<void> loadHistory() async {
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        final encryptedContent = await file.readAsString();
        final decryptedContent = _decryptData(encryptedContent);
        final List<dynamic> jsonList = json.decode(decryptedContent);
        _messages = jsonList.map((json) => ChatMessage.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading encrypted chat history: $e');
    }
  }

  // Sačuvaj novu poruku
  Future<void> saveMessage(String content, bool isUser) async {
    final message = ChatMessage(
      content: content,
      timestamp: DateTime.now(),
      isUser: isUser,
    );

    _messages.add(message);
    await _saveToFile();
  }

  // Vrati sve poruke
  List<ChatMessage> getMessages() => _messages;

  // Sačuvaj u fajl
  Future<void> _saveToFile() async {
    try {
      final file = File(_filePath);
      final jsonList = _messages.map((msg) => msg.toJson()).toList();
      final encryptedData = _encryptData(json.encode(jsonList));
      await file.writeAsString(encryptedData);
    } catch (e) {
      print('Error saving encrypted chat history: $e');
    }
  }

  // Obriši istoriju
  Future<void> clearHistory() async {
    _messages.clear();
    await _saveToFile();
  }

  // Pretraga poruka
  List<ChatMessage> searchMessages(String query) {
    return _messages
        .where((msg) => msg.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Filter po datumu
  List<ChatMessage> filterByDate(DateTime start, DateTime end) {
    return _messages
        .where((msg) =>
            msg.timestamp.isAfter(start) && msg.timestamp.isBefore(end))
        .toList();
  }

  // Prikaži današnje poruke
  List<ChatMessage> getTodayMessages() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    return filterByDate(today, tomorrow);
  }

  // Prikaži sadržaj fajla
  Future<String> getFileContent() async {
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return 'Fajl ne postoji';
    } catch (e) {
      return 'Greška pri čitanju: $e';
    }
  }

  // 1. ENKRIPCIJA
  String _encryptData(String data) {
    final encrypter = Encrypter(AES(_encryptionKey));
    return encrypter.encrypt(data, iv: _iv).base64;
  }

  String _decryptData(String encryptedData) {
    final encrypter = Encrypter(AES(_encryptionKey));
    return encrypter.decrypt64(encryptedData, iv: _iv);
  }

  // 2. BACKUP
  Future<void> createBackup() async {
    try {
      final sourceFile = File(_filePath);
      final backupFile = File(_backupPath);

      if (await sourceFile.exists()) {
        await sourceFile.copy(_backupPath);
        print('Backup created successfully');
      }
    } catch (e) {
      print('Error creating backup: $e');
    }
  }

  Future<void> restoreFromBackup() async {
    try {
      final backupFile = File(_backupPath);
      final mainFile = File(_filePath);

      if (await backupFile.exists()) {
        await backupFile.copy(_filePath);
        await loadHistory(); // Učitaj restaurirane podatke
        print('Restore completed successfully');
      }
    } catch (e) {
      print('Error restoring from backup: $e');
    }
  }

  // 3. EXPORT
  Future<File> exportToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
        build: (context) => [
              pw.Header(level: 0, child: pw.Text('Chat History Export')),
              ...(_messages.map((msg) => pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                      crossAxisAlignment: msg.isUser
                          ? pw.CrossAxisAlignment.end
                          : pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(msg.isUser ? 'User' : 'AI',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(msg.content),
                        pw.Text(msg.timestamp.toString(),
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey)),
                      ]))))
            ]));

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/chat_history.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> exportToTXT() async {
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/chat_history.txt');

    final buffer = StringBuffer();
    for (var msg in _messages) {
      buffer.writeln('${msg.isUser ? "User" : "AI"} - ${msg.timestamp}');
      buffer.writeln(msg.content);
      buffer.writeln('-------------------');
    }

    await file.writeAsString(buffer.toString());
    return file;
  }
}

void main() async {
  print("\n=== Test ChatHistoryService ===\n");
  final chatService = ChatHistoryService();
  
  try {
    // 1. Učitaj postojeće poruke
    print("1️⃣ POSTOJEĆE PORUKE:");
    await chatService.loadHistory();
    var messages = chatService.getMessages();
    print("📂 Broj poruka: ${messages.length}");
    messages.forEach((msg) => 
      print("   ${msg.isUser ? '👤' : '🤖'} ${msg.content}"));
    
    // 2. Dodaj novu poruku
    print("\n2️⃣ DODAJEM NOVU PORUKU:");
    final newMessage = "Nova test poruka - ${DateTime.now()}";
    await chatService.saveMessage(newMessage, true);
    print("✅ Poruka dodata");
    
    // 3. Proveri sadržaj fajla
    print("\n3️⃣ PROVERA FAJLA:");
    final file = File('chat_history.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      print("📄 Broj poruka u fajlu: ${jsonList.length}");
      print("\nSadržaj fajla:");
      print(content);
    }
    
  } catch (e) {
    print("\n❌ ERROR: $e");
    print("Error detalji: ${e.toString()}");
  }
}
