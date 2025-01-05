import 'package:flutter/material.dart';

class SyncIndicator extends StatelessWidget {
  final bool isSyncing;

  const SyncIndicator({
    super.key,
    required this.isSyncing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.check_circle, color: Colors.green),
    );
  }
}
