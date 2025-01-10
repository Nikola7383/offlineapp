import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_event_app/mesh/process/process_starter.dart';
import 'package:secure_event_app/mesh/providers/process_manager_provider.dart'
    hide ProcessStarter;

final processStarterProvider = Provider<ProcessStarter>((ref) {
  final manager = ref.watch(processManagerProvider);
  return ProcessStarter(manager);
});
