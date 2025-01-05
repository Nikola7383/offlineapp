import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:your_app/main.dart';

void main() {
  testWidgets('Performance test - message list scrolling', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final stopwatch = Stopwatch()..start();

    // Test 1: Scroll performance
    await tester.fling(
      find.byType(ListView),
      const Offset(0, -500),
      10000,
    );
    await tester.pumpAndSettle();

    // Should complete under 16ms for 60fps
    expect(stopwatch.elapsedMilliseconds < 16, true);
    stopwatch.stop();

    // Test 2: Memory usage
    await tester.binding.takeMemoryImage();
    final memory = await tester.binding.getMemoryInfo();

    // Should be under 100MB
    expect(memory.realMemory < 100 * 1024 * 1024, true);
  });

  test('Database performance test', () async {
    final db = DatabaseService();
    final stopwatch = Stopwatch()..start();

    // Insert 1000 messages
    for (var i = 0; i < 1000; i++) {
      await db.saveMessage(Message(
        id: i.toString(),
        content: 'Test message $i',
        sender: 'Test sender',
        timestamp: DateTime.now(),
      ));
    }

    // Should complete under 1 second
    expect(stopwatch.elapsedMilliseconds < 1000, true);
    stopwatch.stop();
  });
}
