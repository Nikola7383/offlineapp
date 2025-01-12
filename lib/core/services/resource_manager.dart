import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../interfaces/resource_manager_interface.dart';
import '../interfaces/logger_service.dart';
import '../storage/secure_storage.dart';

@LazySingleton(as: IResourceManager)
class ResourceManager implements IResourceManager {
  final ILoggerService _logger;
  final SecureStorage _storage;
  final _resourceController = StreamController<ResourceUsage>.broadcast();

  final Map<ResourceType, double> _resourceLimits = {};
  final Map<ResourceType, double> _reservedAmounts = {};
  final Map<ResourceType, ResourceStatus> _resourceStatuses = {};
  final Map<ResourceType, List<ResourceUsage>> _usageHistory = {};

  static const String _configKey = 'resource_manager_config';
  static const Duration _historyRetention = Duration(days: 7);
  static const int _maxHistoryEntries = 1000;

  ResourceManager(this._logger, this._storage);

  @override
  Stream<ResourceUsage> get resourceStream => _resourceController.stream;

  @override
  Future<void> initialize() async {
    try {
      _logger.info('Initializing ResourceManager');

      // Učitaj konfiguraciju
      await _loadConfiguration();

      // Postavi inicijalne limite
      _setDefaultLimits();

      // Očisti staru istoriju
      await _cleanupHistory();

      _logger.info('ResourceManager initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize ResourceManager', e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    await _resourceController.close();
  }

  @override
  Future<ResourceUsage> getCurrentUsage(ResourceType type) async {
    try {
      _logger.info('Getting current usage for resource: ${type.name}');

      final currentValue = await _measureResourceUsage(type);
      final maxValue = _resourceLimits[type] ?? 100.0;
      final status = await getResourceStatus(type);

      final usage = ResourceUsage(
        type: type,
        currentValue: currentValue,
        maxValue: maxValue,
        status: status,
        timestamp: DateTime.now(),
      );

      _addToHistory(usage);
      _resourceController.add(usage);

      return usage;
    } catch (e) {
      _logger.error(
          'Failed to get current usage for resource: ${type.name}', e);
      rethrow;
    }
  }

  @override
  Future<List<ResourceUsage>> getUsageHistory(
    ResourceType type, {
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      _logger.info('Getting usage history for resource: ${type.name}');

      final history = _usageHistory[type] ?? [];
      return history.where((usage) {
        return usage.timestamp.isAfter(startTime) &&
            usage.timestamp.isBefore(endTime);
      }).toList();
    } catch (e) {
      _logger.error(
          'Failed to get usage history for resource: ${type.name}', e);
      rethrow;
    }
  }

  @override
  Future<void> optimizeResource(ResourceType type) async {
    try {
      _logger.info('Optimizing resource: ${type.name}');

      // TODO: Implementirati optimizaciju resursa

      _logger.info('Resource optimized successfully: ${type.name}');
    } catch (e) {
      _logger.error('Failed to optimize resource: ${type.name}', e);
      rethrow;
    }
  }

  @override
  Future<void> releaseResource(ResourceType type) async {
    try {
      _logger.info('Releasing resource: ${type.name}');

      _reservedAmounts[type] = 0.0;
      _resourceStatuses[type] = ResourceStatus.available;

      final usage = await getCurrentUsage(type);
      _resourceController.add(usage);

      _logger.info('Resource released successfully: ${type.name}');
    } catch (e) {
      _logger.error('Failed to release resource: ${type.name}', e);
      rethrow;
    }
  }

  @override
  Future<bool> reserveResource(
    ResourceType type, {
    required double amount,
    Duration? timeout,
  }) async {
    try {
      _logger.info('Reserving resource: ${type.name}, amount: $amount');

      final currentUsage = await getCurrentUsage(type);
      final availableAmount = currentUsage.maxValue - currentUsage.currentValue;

      if (amount > availableAmount) {
        _logger.warning(
          'Insufficient resource available: ${type.name}, '
          'requested: $amount, available: $availableAmount',
        );
        return false;
      }

      _reservedAmounts[type] = (_reservedAmounts[type] ?? 0.0) + amount;
      _resourceStatuses[type] = ResourceStatus.busy;

      _resourceController.add(currentUsage.copyWith(
        status: ResourceStatus.busy,
        metadata: {
          'reservedAmount': _reservedAmounts[type],
        },
      ));

      return true;
    } catch (e) {
      _logger.error('Failed to reserve resource: ${type.name}', e);
      return false;
    }
  }

  @override
  Future<void> setResourceLimit(
    ResourceType type, {
    required double maxValue,
  }) async {
    try {
      _logger.info(
        'Setting resource limit: ${type.name}, maxValue: $maxValue',
      );

      _resourceLimits[type] = maxValue;

      // Ažuriraj konfiguraciju
      await _saveConfiguration();

      _logger.info('Resource limit set successfully: ${type.name}');
    } catch (e) {
      _logger.error('Failed to set resource limit: ${type.name}', e);
      rethrow;
    }
  }

  @override
  Future<ResourceStatus> getResourceStatus(ResourceType type) async {
    try {
      final usage = await _measureResourceUsage(type);
      final limit = _resourceLimits[type] ?? 100.0;
      final usagePercentage = (usage / limit) * 100;

      if (usagePercentage > 90) {
        return ResourceStatus.critical;
      } else if (_resourceStatuses[type] == ResourceStatus.busy) {
        return ResourceStatus.busy;
      } else if (usagePercentage > 70) {
        return ResourceStatus.busy;
      } else {
        return ResourceStatus.available;
      }
    } catch (e) {
      _logger.error('Failed to get resource status: ${type.name}', e);
      return ResourceStatus.unavailable;
    }
  }

  @override
  Future<void> reportResourceIssue(
    ResourceType type, {
    required String issue,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.warning('Resource issue reported: ${type.name} - $issue');

      final usage = await getCurrentUsage(type);
      _resourceController.add(usage.copyWith(
        status: ResourceStatus.critical,
        metadata: {
          ...metadata ?? {},
          'issue': issue,
          'reportedAt': DateTime.now().toIso8601String(),
        },
      ));
    } catch (e) {
      _logger.error('Failed to report resource issue: ${type.name}', e);
      rethrow;
    }
  }

  Future<void> _loadConfiguration() async {
    try {
      final configStr = await _storage.read(_configKey);
      if (configStr != null) {
        final config = Map<String, dynamic>.from(configStr as Map);

        // Učitaj limite
        if (config.containsKey('limits')) {
          final limits = Map<String, double>.from(config['limits'] as Map);
          for (final entry in limits.entries) {
            final type = ResourceType.values.firstWhere(
              (t) => t.name == entry.key,
              orElse: () => ResourceType.cpu,
            );
            _resourceLimits[type] = entry.value;
          }
        }
      }
    } catch (e) {
      _logger.error('Failed to load configuration', e);
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      final config = {
        'limits': Map.fromEntries(
          _resourceLimits.entries.map(
            (e) => MapEntry(e.key.name, e.value),
          ),
        ),
      };

      await _storage.write(_configKey, jsonEncode(config));
    } catch (e) {
      _logger.error('Failed to save configuration', e);
    }
  }

  void _setDefaultLimits() {
    _resourceLimits.putIfAbsent(ResourceType.cpu, () => 100.0);
    _resourceLimits.putIfAbsent(ResourceType.memory, () => 1024.0);
    _resourceLimits.putIfAbsent(ResourceType.battery, () => 100.0);
    _resourceLimits.putIfAbsent(ResourceType.network, () => 100.0);
    _resourceLimits.putIfAbsent(ResourceType.storage, () => 1024.0);
  }

  Future<void> _cleanupHistory() async {
    try {
      final now = DateTime.now();

      for (final type in ResourceType.values) {
        final history = _usageHistory[type] ?? [];
        history.removeWhere((usage) {
          return now.difference(usage.timestamp) > _historyRetention;
        });

        // Ograniči broj zapisa
        if (history.length > _maxHistoryEntries) {
          history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          history.removeRange(_maxHistoryEntries, history.length);
        }

        _usageHistory[type] = history;
      }
    } catch (e) {
      _logger.error('Failed to cleanup history', e);
    }
  }

  void _addToHistory(ResourceUsage usage) {
    final history = _usageHistory[usage.type] ?? [];
    history.add(usage);
    _usageHistory[usage.type] = history;
  }

  Future<double> _measureResourceUsage(ResourceType type) async {
    // TODO: Implementirati stvarno merenje resursa
    return 50.0;
  }
}

extension ResourceUsageExtension on ResourceUsage {
  ResourceUsage copyWith({
    ResourceType? type,
    double? currentValue,
    double? maxValue,
    ResourceStatus? status,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ResourceUsage(
      type: type ?? this.type,
      currentValue: currentValue ?? this.currentValue,
      maxValue: maxValue ?? this.maxValue,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? Map.from(this.metadata),
    );
  }
}
