import 'package:injectable/injectable.dart';

@injectable
class SystemMetrics extends InjectableService {
  Future<int> getCurrentMemoryUsage() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return await _getMobileMemoryUsage();
      } else {
        return await _getDesktopMemoryUsage();
      }
    } catch (e, stack) {
      logger.error('Failed to get memory usage', e, stack);
      rethrow;
    }
  }

  Future<int> _getMobileMemoryUsage() async {
    final result = await const MethodChannel('system_metrics')
        .invokeMethod<int>('getMemoryUsage');
    return result ?? 0;
  }

  Future<int> _getDesktopMemoryUsage() async {
    if (Platform.isLinux || Platform.isMacOS) {
      final result = await Process.run('ps', ['-o', 'rss=', '-p', '${pid}']);
      return int.parse(result.stdout.toString().trim()) * 1024;
    } else if (Platform.isWindows) {
      final result =
          await Process.run('tasklist', ['/FI', 'PID eq $pid', '/FO', 'CSV']);
      final memory =
          RegExp(r'(\d+) K').firstMatch(result.stdout.toString())?.group(1);
      return (int.parse(memory ?? '0')) * 1024;
    }
    return 0;
  }
}
