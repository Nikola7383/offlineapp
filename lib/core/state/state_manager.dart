import 'package:injectable/injectable.dart';

@injectable
class StateManager extends InjectableService {
  final _states = <String, BehaviorSubject>{};
  final _stateHistory = <String, List<dynamic>>{};
  static const MAX_HISTORY = 50;

  Stream<T> getState<T>(String key) {
    return (_states[key] as BehaviorSubject<T>? ?? _createState<T>(key)).stream;
  }

  void updateState<T>(String key, T value) {
    final subject = _states[key] as BehaviorSubject<T>? ?? _createState<T>(key);

    _addToHistory(key, value);
    subject.add(value);
  }

  BehaviorSubject<T> _createState<T>(String key) {
    final subject = BehaviorSubject<T>();
    _states[key] = subject;
    return subject;
  }

  void _addToHistory(String key, dynamic value) {
    _stateHistory.putIfAbsent(key, () => []).add(value);
    if (_stateHistory[key]!.length > MAX_HISTORY) {
      _stateHistory[key]!.removeAt(0);
    }
  }

  T? getPreviousState<T>(String key) {
    final history = _stateHistory[key];
    if (history == null || history.isEmpty) return null;
    return history.last as T;
  }

  @override
  Future<void> dispose() async {
    for (final subject in _states.values) {
      await subject.close();
    }
    _states.clear();
    _stateHistory.clear();
    await super.dispose();
  }
}
