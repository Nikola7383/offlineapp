import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../managers/recovery_manager.dart';
import '../types/recovery_types.dart';
import '../widgets/recovery_dialog.dart';

class EnhancedRecoveryUI {
  static EnhancedRecoveryUI? _instance;
  final RecoveryManager _recoveryManager;
  late final RecoveryContext _context;
  bool _isInitialized = false;

  factory EnhancedRecoveryUI({
    required BuildContext buildContext,
    required String processId,
    required DateTime startTime,
    required RecoveryType type,
    List<String> logs = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    _instance ??= EnhancedRecoveryUI._internal(
      RecoveryContext(
        buildContext: buildContext,
        processId: processId,
        startTime: startTime,
        type: type,
        logs: logs,
        metadata: metadata,
      ),
    );
    return _instance!;
  }

  EnhancedRecoveryUI._internal(RecoveryContext context)
      : _recoveryManager = GetIt.instance<RecoveryManager>() {
    _context = context;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _recoveryManager.initialize();
    _isInitialized = true;
  }

  Future<void> dispose() async {
    if (!_isInitialized) return;
    await _recoveryManager.dispose();
    _isInitialized = false;
  }

  Future<void> _showRecoveryDialog(BuildContext context) async {
    if (!_isInitialized) return;

    final steps = await _recoveryManager.getRecoverySteps(_context);
    final canAutoRecover = await _recoveryManager.canAutoRecover(_context);
    final estimatedTime = await _recoveryManager.estimateRecoveryTime(_context);

    await showDialog(
      context: context,
      builder: (dialogContext) => RecoveryDialog(
        steps: steps,
        autoRecoveryAvailable: canAutoRecover,
        estimatedTime: estimatedTime,
        onAutoRecoveryRequested: () => _performAutoRecovery(),
      ),
    );
  }

  Future<void> _performAutoRecovery() async {
    if (!_isInitialized) return;

    final canRecover = await _recoveryManager.canAutoRecover(_context);
    if (!canRecover) {
      return;
    }

    await _startRecovery();
  }

  Future<void> _startRecovery() async {
    if (!_isInitialized) return;

    final steps = await _recoveryManager.getRecoverySteps(_context);

    for (var step in steps) {
      final success =
          await _recoveryManager.executeRecoveryStep(_context, step);
      if (!success) {
        return;
      }
    }
  }
}
