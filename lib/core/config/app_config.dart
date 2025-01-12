import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    @Default('development') String environment,
    @Default(false) bool enableLogging,
    @Default(false) bool enableAnalytics,
    @Default(false) bool enableCrashlytics,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
}

@singleton
class ConfigService {
  final AppConfig config;

  ConfigService() : config = const AppConfig();
}

class AppConfig {
  static const int maxRetries = 3;
  static const int backoffMultiplier = 2;
  static const Duration recoveryInterval = Duration(minutes: 1);

  // Prevent instantiation
  AppConfig._();
}
