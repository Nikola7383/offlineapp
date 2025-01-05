import '../logging/logger_service.dart';
import '../config/app_config.dart';

class SecurityMiddleware {
  final LoggerService _logger;
  final Map<String, _RateLimit> _rateLimits = {};
  final Set<String> _blacklist = {};

  SecurityMiddleware({
    required LoggerService logger,
  }) : _logger = logger;

  bool validateRequest(String deviceId, String action) {
    if (_blacklist.contains(deviceId)) {
      _logger.warning('Blocked request from blacklisted device: $deviceId');
      return false;
    }

    if (!_checkRateLimit(deviceId, action)) {
      _logger.warning(
          'Rate limit exceeded for device: $deviceId, action: $action');
      return false;
    }

    return true;
  }

  bool validateFileTransfer(String fileName, int fileSize) {
    final extension = fileName.split('.').last.toLowerCase();

    if (!AppConfig.allowedFileTypes.contains(extension)) {
      _logger.warning('Invalid file type: $extension');
      return false;
    }

    if (fileSize > AppConfig.maxFileSize) {
      _logger.warning('File too large: $fileSize bytes');
      return false;
    }

    return true;
  }

  bool _checkRateLimit(String deviceId, String action) {
    final now = DateTime.now();
    final key = '$deviceId:$action';
    final limit = AppConfig.rateLimits[action] ?? 0;

    _rateLimits[key] ??= _RateLimit(
      count: 0,
      resetTime: now.add(const Duration(minutes: 1)),
    );

    final rateLimit = _rateLimits[key]!;

    if (now.isAfter(rateLimit.resetTime)) {
      rateLimit.count = 1;
      rateLimit.resetTime = now.add(const Duration(minutes: 1));
      return true;
    }

    if (rateLimit.count >= limit) {
      return false;
    }

    rateLimit.count++;
    return true;
  }

  void blacklistDevice(String deviceId) {
    _blacklist.add(deviceId);
    _logger.info('Device blacklisted: $deviceId');
  }

  void removeFromBlacklist(String deviceId) {
    _blacklist.remove(deviceId);
    _logger.info('Device removed from blacklist: $deviceId');
  }
}

class _RateLimit {
  int count;
  DateTime resetTime;

  _RateLimit({
    required this.count,
    required this.resetTime,
  });
}
