import 'base_service.dart';
import '../models/message.dart';

/// Interfejs za određivanje prioriteta poruka
abstract class IMessagePriorityService implements IService {
  /// Izračunava prioritet poruke
  int calculatePriority(Message message);

  /// Vraća poruke sortirane po prioritetu
  Future<List<Message>> getPrioritizedMessages();
}

/// Rezultat prioritizacije
class PriorityResult {
  /// Izračunati prioritet
  final int priority;

  /// Razlozi za prioritet
  final Map<String, int> factors;

  /// Vreme izračunavanja
  final DateTime calculatedAt;

  PriorityResult({
    required this.priority,
    required this.factors,
    required this.calculatedAt,
  });
}
