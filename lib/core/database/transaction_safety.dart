import 'package:injectable/injectable.dart';

@injectable
class TransactionSafetyManager extends InjectableService {
  final Map<String, Set<String>> _resourceLocks = {};
  final Map<String, DateTime> _transactionStartTimes = {};
  static const DEADLOCK_TIMEOUT = Duration(seconds: 5);

  Future<T> runSafeTransaction<T>(
    String transactionId,
    List<String> requiredResources,
    Future<T> Function() operation,
  ) async {
    try {
      await _acquireResources(transactionId, requiredResources);
      final result = await operation();
      await _commitTransaction(transactionId);
      return result;
    } catch (e) {
      await _rollbackTransaction(transactionId);
      rethrow;
    } finally {
      await _releaseResources(transactionId);
    }
  }

  Future<void> _acquireResources(
    String transactionId,
    List<String> resources,
  ) async {
    // Sortiramo resurse da sprečimo deadlock
    resources.sort();

    _transactionStartTimes[transactionId] = DateTime.now();

    for (final resource in resources) {
      if (!await _tryAcquireResource(transactionId, resource)) {
        await _rollbackTransaction(transactionId);
        throw DeadlockException('Deadlock detected for $transactionId');
      }
    }
  }

  Future<bool> _tryAcquireResource(
    String transactionId,
    String resource,
  ) async {
    final startTime = _transactionStartTimes[transactionId]!;

    while (true) {
      // Provera timeout-a
      if (DateTime.now().difference(startTime) > DEADLOCK_TIMEOUT) {
        return false;
      }

      // Ako resurs nije zaključan, zaključaj ga
      if (!_resourceLocks.containsKey(resource)) {
        _resourceLocks[resource] = {transactionId};
        return true;
      }

      // Ako je resurs već zaključan od strane ove transakcije
      if (_resourceLocks[resource]!.contains(transactionId)) {
        return true;
      }

      // Čekaj malo pre sledećeg pokušaja
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> _commitTransaction(String transactionId) async {
    logger.info('Committing transaction: $transactionId');
    // Implementacija commit logike
  }

  Future<void> _rollbackTransaction(String transactionId) async {
    logger.warning('Rolling back transaction: $transactionId');
    await _releaseResources(transactionId);
    // Implementacija rollback logike
  }

  Future<void> _releaseResources(String transactionId) async {
    _resourceLocks.forEach((resource, transactions) {
      transactions.remove(transactionId);
      if (transactions.isEmpty) {
        _resourceLocks.remove(resource);
      }
    });
    _transactionStartTimes.remove(transactionId);
  }
}

class DeadlockException implements Exception {
  final String message;
  DeadlockException(this.message);

  @override
  String toString() => 'DeadlockException: $message';
}
