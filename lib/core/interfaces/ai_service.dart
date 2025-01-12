import 'base_service.dart';

/// Interfejs za AI health monitoring
abstract class IHealthMonitoringService implements IAsyncService {
  /// Analizira zdravlje sistema
  Future<HealthAnalysis> analyzeSystemHealth();

  /// Predviđa potencijalne probleme
  Future<List<PotentialIssue>> predictIssues();

  /// Predlaže optimizacije
  Future<List<OptimizationSuggestion>> suggestOptimizations();

  /// Stream za praćenje anomalija
  Stream<AnomalyDetection> get anomalyStream;
}

/// Interfejs za AI recovery
abstract class IRecoveryService implements IAsyncService {
  /// Kreira plan oporavka
  Future<RecoveryPlan> createRecoveryPlan(SystemFailure failure);

  /// Izvršava plan oporavka
  Future<RecoveryResult> executeRecoveryPlan(RecoveryPlan plan);

  /// Validira rezultate oporavka
  Future<ValidationResult> validateRecovery(RecoveryResult result);

  /// Stream za praćenje progresa oporavka
  Stream<RecoveryProgress> get recoveryProgressStream;
}

/// Analiza zdravlja sistema
class HealthAnalysis {
  /// Ukupna ocena (0-100)
  final double overallScore;

  /// Detaljna analiza po komponentama
  final Map<String, ComponentHealth> componentScores;

  /// Identifikovani rizici
  final List<IdentifiedRisk> risks;

  /// Preporuke
  final List<HealthRecommendation> recommendations;

  /// Vreme analize
  final DateTime timestamp;

  /// Kreira novu analizu zdravlja
  HealthAnalysis({
    required this.overallScore,
    required this.componentScores,
    required this.risks,
    required this.recommendations,
    required this.timestamp,
  });
}

/// Zdravlje komponente
class ComponentHealth {
  /// Ime komponente
  final String name;

  /// Ocena (0-100)
  final double score;

  /// Status
  final ComponentStatus status;

  /// Metrike
  final Map<String, double> metrics;

  /// Kreira novo zdravlje komponente
  ComponentHealth({
    required this.name,
    required this.score,
    required this.status,
    required this.metrics,
  });
}

/// Identifikovani rizik
class IdentifiedRisk {
  /// Nivo rizika
  final RiskLevel level;

  /// Opis
  final String description;

  /// Verovatnoća (0-100)
  final double probability;

  /// Uticaj (0-100)
  final double impact;

  /// Predložene mere
  final List<String> mitigationSteps;

  /// Kreira novi identifikovani rizik
  IdentifiedRisk({
    required this.level,
    required this.description,
    required this.probability,
    required this.impact,
    required this.mitigationSteps,
  });
}

/// Preporuka za zdravlje
class HealthRecommendation {
  /// Prioritet
  final Priority priority;

  /// Opis
  final String description;

  /// Očekivani benefit
  final String benefit;

  /// Procenjeni trud
  final Effort effort;

  /// Koraci implementacije
  final List<String> implementationSteps;

  /// Kreira novu preporuku
  HealthRecommendation({
    required this.priority,
    required this.description,
    required this.benefit,
    required this.effort,
    required this.implementationSteps,
  });
}

/// Plan oporavka
class RecoveryPlan {
  /// ID plana
  final String id;

  /// Opis problema
  final String problemDescription;

  /// Koraci oporavka
  final List<RecoveryStep> steps;

  /// Procenjeno vreme
  final Duration estimatedDuration;

  /// Rizici
  final List<String> risks;

  /// Kreira novi plan oporavka
  RecoveryPlan({
    required this.id,
    required this.problemDescription,
    required this.steps,
    required this.estimatedDuration,
    required this.risks,
  });
}

/// Korak oporavka
class RecoveryStep {
  /// ID koraka
  final String id;

  /// Opis
  final String description;

  /// Akcija
  final String action;

  /// Validacija
  final String validation;

  /// Rollback procedura
  final String? rollback;

  /// Kreira novi korak oporavka
  RecoveryStep({
    required this.id,
    required this.description,
    required this.action,
    required this.validation,
    this.rollback,
  });
}

/// Rezultat oporavka
class RecoveryResult {
  /// ID rezultata
  final String id;

  /// Status
  final RecoveryStatus status;

  /// Detalji
  final String details;

  /// Vreme izvršenja
  final Duration executionTime;

  /// Primenjeni koraci
  final List<AppliedStep> appliedSteps;

  /// Kreira novi rezultat oporavka
  RecoveryResult({
    required this.id,
    required this.status,
    required this.details,
    required this.executionTime,
    required this.appliedSteps,
  });
}

/// Primenjeni korak
class AppliedStep {
  /// ID koraka
  final String stepId;

  /// Status
  final StepStatus status;

  /// Rezultat
  final String result;

  /// Vreme izvršenja
  final Duration executionTime;

  /// Kreira novi primenjeni korak
  AppliedStep({
    required this.stepId,
    required this.status,
    required this.result,
    required this.executionTime,
  });
}

/// Detekcija anomalije
class AnomalyDetection {
  /// Tip anomalije
  final String type;

  /// Opis
  final String description;

  /// Nivo sigurnosti (0-100)
  final double confidence;

  /// Vreme detekcije
  final DateTime timestamp;

  /// Povezane metrike
  final Map<String, double> relatedMetrics;

  /// Kreira novu detekciju anomalije
  AnomalyDetection({
    required this.type,
    required this.description,
    required this.confidence,
    required this.timestamp,
    required this.relatedMetrics,
  });
}

/// Status komponente
enum ComponentStatus {
  /// Zdravo
  healthy,

  /// Degradirano
  degraded,

  /// Kritično
  critical,

  /// Nepoznato
  unknown
}

/// Nivo rizika
enum RiskLevel {
  /// Nizak
  low,

  /// Srednji
  medium,

  /// Visok
  high,

  /// Kritičan
  critical
}

/// Prioritet
enum Priority {
  /// Nizak
  low,

  /// Srednji
  medium,

  /// Visok
  high,

  /// Kritičan
  critical
}

/// Procenjeni trud
enum Effort {
  /// Mali
  small,

  /// Srednji
  medium,

  /// Veliki
  large,

  /// Vrlo veliki
  xlarge
}

/// Status oporavka
enum RecoveryStatus {
  /// Uspešno
  successful,

  /// Delimično uspešno
  partiallySuccessful,

  /// Neuspešno
  failed,

  /// Prekinuto
  aborted
}

/// Status koraka
enum StepStatus {
  /// Uspešno
  successful,

  /// Neuspešno
  failed,

  /// Preskočeno
  skipped,

  /// Rollback
  rolledBack
}

/// Potencijalni problem
class PotentialIssue {
  /// Tip problema
  final String type;

  /// Opis
  final String description;

  /// Verovatnoća (0-100)
  final double probability;

  /// Procenjeni uticaj
  final String impact;

  /// Predložena rešenja
  final List<String> suggestedSolutions;

  /// Kreira novi potencijalni problem
  PotentialIssue({
    required this.type,
    required this.description,
    required this.probability,
    required this.impact,
    required this.suggestedSolutions,
  });
}

/// Predlog optimizacije
class OptimizationSuggestion {
  /// Tip optimizacije
  final String type;

  /// Opis
  final String description;

  /// Očekivani benefit
  final String benefit;

  /// Procenjeni trud
  final Effort effort;

  /// Koraci implementacije
  final List<String> implementationSteps;

  /// Kreira novi predlog optimizacije
  OptimizationSuggestion({
    required this.type,
    required this.description,
    required this.benefit,
    required this.effort,
    required this.implementationSteps,
  });
}

/// Sistemski pad
class SystemFailure {
  /// ID pada
  final String id;

  /// Tip pada
  final String type;

  /// Opis
  final String description;

  /// Vreme pada
  final DateTime timestamp;

  /// Pogođene komponente
  final List<String> affectedComponents;

  /// Detalji greške
  final Map<String, dynamic> errorDetails;

  /// Kreira novi sistemski pad
  SystemFailure({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.affectedComponents,
    required this.errorDetails,
  });
}

/// Rezultat validacije
class ValidationResult {
  /// Da li je validacija uspešna
  final bool isValid;

  /// Poruka
  final String message;

  /// Detalji validacije
  final Map<String, dynamic> details;

  /// Preporuke
  final List<String> recommendations;

  /// Kreira novi rezultat validacije
  ValidationResult({
    required this.isValid,
    required this.message,
    required this.details,
    required this.recommendations,
  });
}

/// Progress oporavka
class RecoveryProgress {
  /// ID oporavka
  final String recoveryId;

  /// Trenutni korak
  final int currentStep;

  /// Ukupan broj koraka
  final int totalSteps;

  /// Status
  final RecoveryStatus status;

  /// Poruka o progresu
  final String message;

  /// Procenat završenosti
  final double completionPercentage;

  /// Kreira novi progress oporavka
  RecoveryProgress({
    required this.recoveryId,
    required this.currentStep,
    required this.totalSteps,
    required this.status,
    required this.message,
    required this.completionPercentage,
  });
}
