import 'package:injectable/injectable.dart';

@injectable
class ResourceTracker extends InjectableService {
  final Map<String, ResourceUsage> _resourceUsage = {};

  void trackResourceUsage(String resourceId, int amount) {
    _resourceUsage.update(
      resourceId,
      (usage) => usage..addUsage(amount),
      ifAbsent: () => ResourceUsage()..addUsage(amount),
    );
  }

  List<ResourceAlert> checkThresholds() {
    final alerts = <ResourceAlert>[];

    for (final entry in _resourceUsage.entries) {
      if (entry.value.isOverThreshold()) {
        alerts.add(ResourceAlert(
          resourceId: entry.key,
          usage: entry.value.currentUsage,
          threshold: entry.value.threshold,
        ));
      }
    }

    return alerts;
  }
}

class ResourceUsage {
  int currentUsage = 0;
  final int threshold;

  ResourceUsage({this.threshold = 1000});

  void addUsage(int amount) {
    currentUsage += amount;
  }

  bool isOverThreshold() => currentUsage > threshold;
}
