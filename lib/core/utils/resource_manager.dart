import 'dart:async';
import '../services/logger_service.dart';

class ResourceManager {
  final LoggerService _logger;
  final Map<String, List<Disposable>> _resources = {};

  ResourceManager(this._logger);

  void register(String group, Disposable resource) {
    _resources.putIfAbsent(group, () => []).add(resource);
  }

  Future<void> disposeGroup(String group) async {
    if (!_resources.containsKey(group)) return;

    for (final resource in _resources[group]!) {
      try {
        await resource.dispose();
      } catch (e, stack) {
        _logger.error('Error disposing resource in group $group', e, stack);
      }
    }
    _resources.remove(group);
  }

  Future<void> disposeAll() async {
    final groups = _resources.keys.toList();
    for (final group in groups) {
      await disposeGroup(group);
    }
  }
}

abstract class Disposable {
  Future<void> dispose();
}
