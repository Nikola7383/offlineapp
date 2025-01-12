import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';
import '../interfaces/base_service.dart';
import '../exceptions/resource_exception.dart';

@injectable
class AsyncResourcePool implements IBaseService {
  final Map<String, AsyncResource> _resources = {};
  final _mutex = Lock();

  @override
  Future<void> initialize() async {
    // Inicijalizacija nije potrebna
  }

  @override
  Future<void> dispose() async {
    await _releaseAllResources();
  }

  Future<void> _releaseAllResources() async {
    await _mutex.synchronized(() async {
      for (var resource in _resources.values) {
        await resource.release();
      }
      _resources.clear();
    });
  }

  Future<T> withResource<T>(
      String resourceId, Future<T> Function(dynamic resource) operation) async {
    final resource = await _acquireResource(resourceId);
    try {
      return await operation(resource);
    } finally {
      await _releaseResource(resourceId);
    }
  }

  Future<dynamic> _acquireResource(String resourceId) async {
    return await _mutex.synchronized(() async {
      if (!_resources.containsKey(resourceId)) {
        _resources[resourceId] = AsyncResource();
      }
      return _resources[resourceId]!.acquire();
    });
  }

  Future<void> _releaseResource(String resourceId) async {
    await _mutex.synchronized(() async {
      final resource = _resources[resourceId];
      if (resource != null) {
        await resource.release();
      }
    });
  }
}

class AsyncResource {
  final int maxConcurrent;
  int _currentUsers = 0;
  final _mutex = Lock();

  AsyncResource({this.maxConcurrent = 5});

  Future<void> acquire() async {
    await _mutex.synchronized(() async {
      if (_currentUsers >= maxConcurrent) {
        throw ResourceExhaustedException('Resource limit reached');
      }
      _currentUsers++;
    });
  }

  Future<void> release() async {
    await _mutex.synchronized(() async {
      if (_currentUsers > 0) {
        _currentUsers--;
      }
    });
  }
}
