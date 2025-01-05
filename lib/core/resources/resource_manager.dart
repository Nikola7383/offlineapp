@injectable
class ResourceManager extends InjectableService {
  final Map<String, ManagedResource> _resources = {};
  final _resourceMetrics = StreamController<ResourceMetric>.broadcast();

  Stream<ResourceMetric> get metrics => _resourceMetrics.stream;

  ResourceManager(LoggerService logger) : super(logger);

  Future<T> withResource<T>(
    String resourceId,
    Future<T> Function(dynamic resource) operation,
  ) async {
    final managedResource = _resources[resourceId];
    if (managedResource == null) {
      throw ResourceException('Resource not found: $resourceId');
    }

    await managedResource.acquire();
    try {
      final result = await operation(managedResource.resource);
      _emitMetric(resourceId, ResourceAction.success);
      return result;
    } catch (e) {
      _emitMetric(resourceId, ResourceAction.failure);
      rethrow;
    } finally {
      await managedResource.release();
    }
  }

  void registerResource(
    String resourceId,
    dynamic resource, {
    int maxConcurrentUses = 5,
    Duration? timeout,
  }) {
    if (_resources.containsKey(resourceId)) {
      throw ResourceException('Resource already registered: $resourceId');
    }

    _resources[resourceId] = ManagedResource(
      resource: resource,
      maxConcurrentUses: maxConcurrentUses,
      timeout: timeout,
    );
  }

  void _emitMetric(String resourceId, ResourceAction action) {
    _resourceMetrics.add(ResourceMetric(
      resourceId: resourceId,
      action: action,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<void> dispose() async {
    for (final resource in _resources.values) {
      await resource.dispose();
    }
    await _resourceMetrics.close();
    await super.dispose();
  }
}

class ManagedResource {
  final dynamic resource;
  final int maxConcurrentUses;
  final Duration? timeout;

  int _currentUses = 0;
  final _semaphore = Semaphore(1);

  ManagedResource({
    required this.resource,
    this.maxConcurrentUses = 5,
    this.timeout,
  });

  Future<void> acquire() async {
    await _semaphore.acquire();
    try {
      if (_currentUses >= maxConcurrentUses) {
        throw ResourceExhaustedException();
      }
      _currentUses++;
    } finally {
      _semaphore.release();
    }

    if (timeout != null) {
      await Future.delayed(timeout!);
    }
  }

  Future<void> release() async {
    await _semaphore.acquire();
    try {
      _currentUses--;
    } finally {
      _semaphore.release();
    }
  }

  Future<void> dispose() async {
    if (resource is Disposable) {
      await (resource as Disposable).dispose();
    }
  }
}
