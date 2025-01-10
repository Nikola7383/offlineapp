import 'dart:async';
import '../models/node.dart';
import 'message_transport.dart';

/// Klasa za izbor optimalnog transporta na osnovu više faktora
class TransportSelector {
  // Težinski faktori za različite metrike
  static const double LATENCY_WEIGHT = 0.3;
  static const double SUCCESS_RATE_WEIGHT = 0.3;
  static const double SIGNAL_STRENGTH_WEIGHT = 0.2;
  static const double BATTERY_IMPACT_WEIGHT = 0.2;

  // Pragovi za različite metrike
  static const double MIN_SUCCESS_RATE = 0.7;
  static const double MIN_SIGNAL_STRENGTH = 0.4;
  static const double MAX_ACCEPTABLE_LATENCY = 1000.0; // ms

  // Potrošnja baterije po transportu (0-1)
  static const Map<String, double> BATTERY_IMPACT = {
    'bluetooth': 0.3,
    'wifi_direct': 0.7,
    'sound': 0.4,
  };

  /// Bira najbolji transport na osnovu dostupnih metrika
  MessageTransport? selectBestTransport(
    List<MessageTransport> availableTransports,
    TransportPriority priority,
    Map<String, TransportStats> transportStats,
  ) {
    if (availableTransports.isEmpty) return null;

    // Ako je kritičan prioritet, koristi sve dostupne transporte
    if (priority == TransportPriority.critical) {
      return _selectMostReliableTransport(availableTransports, transportStats);
    }

    // Filtriraj transporte koji ne zadovoljavaju minimalne uslove
    final qualifiedTransports = availableTransports.where((transport) {
      final stats = transportStats[transport.runtimeType.toString()];
      if (stats == null) return true; // Novi transport, daj mu šansu

      return _meetsMinimumRequirements(stats, priority);
    }).toList();

    if (qualifiedTransports.isEmpty) {
      // Ako nema kvalifikovanih, vrati najbolji dostupan
      return _selectMostReliableTransport(availableTransports, transportStats);
    }

    // Izračunaj score za svaki transport
    final scores = <MessageTransport, double>{};

    for (final transport in qualifiedTransports) {
      final stats = transportStats[transport.runtimeType.toString()];
      if (stats == null) {
        scores[transport] = 0.5; // Srednji score za nove transporte
        continue;
      }

      scores[transport] = _calculateTransportScore(
        stats,
        transport.runtimeType.toString(),
        priority,
      );
    }

    // Vrati transport sa najboljim score-om
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Proverava da li transport zadovoljava minimalne uslove
  bool _meetsMinimumRequirements(
    TransportStats stats,
    TransportPriority priority,
  ) {
    // Za nizak prioritet, nema minimalnih uslova
    if (priority == TransportPriority.low) return true;

    // Osnovni uslovi za normalan prioritet
    if (stats.deliverySuccessRate < MIN_SUCCESS_RATE) return false;
    if (stats.averageSignalStrength < MIN_SIGNAL_STRENGTH) return false;
    if (stats.averageLatency > MAX_ACCEPTABLE_LATENCY) return false;

    // Dodatni uslovi za visok prioritet
    if (priority == TransportPriority.high) {
      if (stats.deliverySuccessRate < MIN_SUCCESS_RATE + 0.1) return false;
      if (stats.averageSignalStrength < MIN_SIGNAL_STRENGTH + 0.1) return false;
      if (stats.averageLatency > MAX_ACCEPTABLE_LATENCY * 0.8) return false;
    }

    return true;
  }

  /// Računa score za transport
  double _calculateTransportScore(
    TransportStats stats,
    String transportType,
    TransportPriority priority,
  ) {
    // Normalizuj metrike na skalu 0-1
    final latencyScore = _normalizeLatency(stats.averageLatency);
    final successScore = stats.deliverySuccessRate;
    final signalScore = stats.averageSignalStrength;
    final batteryScore = 1.0 - (BATTERY_IMPACT[transportType] ?? 0.5);

    // Prilagodi težine prema prioritetu
    var latencyWeight = LATENCY_WEIGHT;
    var successWeight = SUCCESS_RATE_WEIGHT;
    var signalWeight = SIGNAL_STRENGTH_WEIGHT;
    var batteryWeight = BATTERY_IMPACT_WEIGHT;

    switch (priority) {
      case TransportPriority.high:
        // Veći značaj pouzdanosti i latencije
        latencyWeight *= 1.5;
        successWeight *= 1.5;
        batteryWeight *= 0.5;
        break;
      case TransportPriority.low:
        // Veći značaj uštede baterije
        batteryWeight *= 2;
        latencyWeight *= 0.5;
        break;
      case TransportPriority.critical:
        // Maksimalan značaj pouzdanosti
        successWeight *= 2;
        signalWeight *= 1.5;
        batteryWeight = 0;
        break;
      default:
        // Normalan prioritet - standardne težine
        break;
    }

    // Normalizuj težine
    final totalWeight =
        latencyWeight + successWeight + signalWeight + batteryWeight;
    latencyWeight /= totalWeight;
    successWeight /= totalWeight;
    signalWeight /= totalWeight;
    batteryWeight /= totalWeight;

    // Izračunaj ukupan score
    return (latencyScore * latencyWeight) +
        (successScore * successWeight) +
        (signalScore * signalWeight) +
        (batteryScore * batteryWeight);
  }

  /// Normalizuje latenciju na skalu 0-1
  double _normalizeLatency(double latency) {
    if (latency <= 0) return 1.0;
    if (latency >= MAX_ACCEPTABLE_LATENCY) return 0.0;
    return 1.0 - (latency / MAX_ACCEPTABLE_LATENCY);
  }

  /// Bira najpouzdaniji transport za kritične poruke
  MessageTransport _selectMostReliableTransport(
    List<MessageTransport> transports,
    Map<String, TransportStats> stats,
  ) {
    var bestTransport = transports.first;
    var bestScore = double.negativeInfinity;

    for (final transport in transports) {
      final transportStats = stats[transport.runtimeType.toString()];
      if (transportStats == null) continue;

      final score = transportStats.deliverySuccessRate * 0.7 +
          transportStats.averageSignalStrength * 0.3;

      if (score > bestScore) {
        bestScore = score;
        bestTransport = transport;
      }
    }

    return bestTransport;
  }
}
