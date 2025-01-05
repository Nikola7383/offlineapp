void main() {
  late TestServiceLocator locator;

  setUp(() async {
    locator = TestServiceLocator();
    await locator.initialize();
  });

  tearDown(() async {
    await locator.dispose();
  });

  test('complete message flow', () async {
    // 1. Create message
    final message = Message(
      id: 'test1',
      content: 'test content',
      senderId: 'test_sender',
      timestamp: DateTime.now(),
    );

    // 2. Save and queue
    final storage = locator.get<IStorageService>();
    final sync = locator.get<ISyncService>();

    final saveResult = await storage.saveMessage(message);
    expect(saveResult.isSuccess, true);

    final queueResult = await sync.queueMessage(message);
    expect(queueResult.isSuccess, true);

    // 3. Verify queued
    final queued = await sync.getPendingMessages();
    expect(queued.data!.length, 1);

    // 4. Sync
    final syncResult = await sync.sync();
    expect(syncResult.isSuccess, true);

    // 5. Verify synced
    final remaining = await sync.getPendingMessages();
    expect(remaining.data!.isEmpty, true);
  });
} 