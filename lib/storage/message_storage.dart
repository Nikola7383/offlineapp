class MessageStorage {
  final Database database;

  Future<void> saveMessage(Message message) async {
    await database.transaction((txn) async {
      await txn.insert('messages', message.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Stream<List<Message>> getMessages() {
    return database
        .watch('messages')
        .map((rows) => rows.map((row) => Message.fromMap(row)).toList());
  }
}
