class RecommendedImprovements {
  static List<Improvement> getImprovements() {
    return [
      Improvement(
        area: "P2P Komunikacija",
        suggestion: "Dodati više fallback mehanizama za P2P povezivanje",
        priority: Priority.high
      ),
      
      Improvement(
        area: "Korisnički Interfejs",
        suggestion: "Pojednostaviti security odluke za krajnje korisnike",
        priority: Priority.medium
      ),
      
      Improvement(
        area: "Performance",
        suggestion: "Optimizovati enkripciju za brže P2P transfere",
        priority: Priority.high
      ),
      
      Improvement(
        area: "Recovery",
        suggestion: "Dodati više automatskih recovery opcija",
        priority: Priority.medium
      )
    ];
  }
} 