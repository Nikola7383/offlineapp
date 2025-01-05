class CriticalAnalysis {
  static List<SecurityConcern> findCriticalIssues() {
    return [
      SecurityConcern(
        type: ConcernType.timing,
        description: 'QR i zvučna verifikacija mogu biti van sinhronizacije',
        risk: 'Man-in-the-middle napad',
        solution: 'Dodati timestamp sinhronizaciju između uređaja',
      ),
      
      SecurityConcern(
        type: ConcernType.recovery,
        description: 'Nedostaje mehanizam za recovery ako padnu SVI admini',
        risk: 'Potpuni gubitak kontrole',
        solution: 'Implementirati "golden key" recovery sistem',
      ),
      
      SecurityConcern(
        type: ConcernType.cascade,
        description: 'Emergency shutdown može izazvati kaskadni efekat',
        risk: 'Nekontrolisani pad sistema',
        solution: 'Dodati postepeni, kontrolisani shutdown',
      ),
    ];
  }
} 