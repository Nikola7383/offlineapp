import 'package:injectable/injectable.dart';

class AppError {
  final String code;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.code,
    required this.message,
    this.originalError,
    this.stackTrace,
  });
}

abstract class ErrorListener {
  void onError(AppError error);
}
