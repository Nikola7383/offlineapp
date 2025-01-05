class ThreadSafeWrapper<T> {
  final T _value;
  final Lock _lock = Lock();

  ThreadSafeWrapper(this._value);

  Future<R> access<R>(Future<R> Function(T value) action) async {
    return await _lock.synchronized(() => action(_value));
  }
}

extension ThreadSafeExtension<T> on T {
  ThreadSafeWrapper<T> get threadSafe => ThreadSafeWrapper<T>(this);
}
