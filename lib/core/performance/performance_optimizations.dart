import 'package:flutter/material.dart';
import '../models/message.dart';

// Widget optimizacije
class OptimizedMessageList extends StatelessWidget {
  final List<Message> messages;

  const OptimizedMessageList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Koristi cacheExtent za bolje scrolling performanse
      cacheExtent: 100.0,

      // Koristi RepaintBoundary za smanjenje repaint oblasti
      addRepaintBoundaries: true,

      // Koristi AutomaticKeepAlive za održavanje stanja
      addAutomaticKeepAlives: true,

      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];

        // Koristi const konstruktore gde je moguće
        return MessageTile(
          key: ValueKey(message.id),
          message: message,
        );
      },
    );
  }
}

class MessageTile extends StatelessWidget {
  final Message message;

  const MessageTile({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Koristi RepaintBoundary za izolaciju repainta
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 8.0,
        ),
        child: Row(
          children: [
            // Koristi const widgets gde je moguće
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 8),
            Expanded(
              // Koristi selective rebuilding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message.content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension metode za optimizacije
extension ListOptimizations<T> on List<T> {
  List<T> optimizedWhere(bool Function(T) test) {
    // Optimizovana implementacija where
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      if (test(this[i])) {
        result.add(this[i]);
      }
    }
    return result;
  }

  void optimizedSort(int Function(T, T) compare) {
    // Optimizovana implementacija quick sort
    if (length <= 1) return;
    _quickSort(this, 0, length - 1, compare);
  }

  static void _quickSort<T>(
    List<T> list,
    int low,
    int high,
    int Function(T, T) compare,
  ) {
    if (low < high) {
      final pivot = _partition(list, low, high, compare);
      _quickSort(list, low, pivot - 1, compare);
      _quickSort(list, pivot + 1, high, compare);
    }
  }

  static int _partition<T>(
    List<T> list,
    int low,
    int high,
    int Function(T, T) compare,
  ) {
    final pivot = list[high];
    var i = low - 1;

    for (var j = low; j < high; j++) {
      if (compare(list[j], pivot) <= 0) {
        i++;
        final temp = list[i];
        list[i] = list[j];
        list[j] = temp;
      }
    }

    final temp = list[i + 1];
    list[i + 1] = list[high];
    list[high] = temp;

    return i + 1;
  }
}
