@injectable
class AsyncResourcePool extends InjectableService {
  final Map<String, AsyncResource> _resources = {};
  final _mutex = Lock();

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
        _resources[resourceId] = await _createResource(resourceId);
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
  final _semaphore = Semaphore(1);

  AsyncResource({this.maxConcurrent = 5});

  Future<void> acquire() async {
    await _semaphore.acquire();
    try {
      if (_currentUsers >= maxConcurrent) {
        throw ResourceExhaustedException();
      }
      _currentUsers++;
    } finally {
      _semaphore.release();
    }
  }

  Future<void> release() async {
    await _semaphore.acquire();
    try {
      _currentUsers--;
    } finally {
      _semaphore.release();
    }
  }
}
