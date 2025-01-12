import 'package:injectable/injectable.dart';
import 'error_listener.dart';

@injectable
class ErrorObserver {
  final List<ErrorListener> _listeners = [];

  void addListener(ErrorListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ErrorListener listener) {
    _listeners.remove(listener);
  }

  void notifyError(AppError error) {
    for (final listener in _listeners) {
      listener.onError(error);
    }
  }
}
