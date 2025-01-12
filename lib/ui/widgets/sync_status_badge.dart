import 'package:flutter/material.dart';
import '../../core/services/service_helper.dart';

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: _getSyncStatusStream(),
      builder: (context, snapshot) {
        if (snapshot.data == SyncStatus.syncing) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Stream<SyncStatus> _getSyncStatusStream() async* {
    while (true) {
      yield Services.sync.status;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
