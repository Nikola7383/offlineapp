class ProposedModules {
  static List<SecurityModule> getProposedModules() {
    return [
      SecurityModule(
          name: 'Behavior Analysis',
          purpose: 'Detekcija anomalija u ponašanju korisnika',
          priority: 'HIGH'),
      SecurityModule(
          name: 'Threat Intelligence',
          purpose: 'Proaktivna detekcija pretnji',
          priority: 'MEDIUM'),
      SecurityModule(
          name: 'Recovery Orchestration',
          purpose: 'Automatizovani oporavak sistema',
          priority: 'HIGH'),
      SecurityModule(
          name: 'Secure Communication',
          purpose: 'Unapređena enkripcija komunikacije',
          priority: 'HIGH')
    ];
  }
}
