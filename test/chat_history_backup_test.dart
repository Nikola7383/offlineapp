import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Inicijalizacija
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('Simple Database Test', () async {
    // Otvori test bazu
    final db = await databaseFactoryFfi.openDatabase('test.db');

    try {
      // 1. Kreiraj tabelu
      await db.execute('''
        CREATE TABLE messages (
          id INTEGER PRIMARY KEY,
          content TEXT,
          isUser INTEGER
        )
      ''');

      // 2. Dodaj test poruku
      await db.insert('messages', {'content': 'Test poruka', 'isUser': 1});

      // 3. Proveri da li je sačuvano
      final messages = await db.query('messages');
      print('Sačuvane poruke:');
      print(messages);

      // 4. Zatvori bazu
      await db.close();
    } catch (e) {
      print('Error: $e');
      await db.close();
    }
  });
}
