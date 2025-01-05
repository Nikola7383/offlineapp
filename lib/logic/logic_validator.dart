class LogicValidator {
  static List<LogicError> findLogicErrors() {
    return [
      LogicError(
        system: 'Seed Rotation',
        error:
            'Moguće je da privremeni seed postane admin bez pune verifikacije',
        fix: 'Dodati obaveznu punu verifikaciju pre admin promocije',
      ),
      LogicError(
        system: 'Emergency Protocol',
        error:
            'Emergency protokol može biti aktiviran bez potvrde drugih admina',
        fix: 'Zahtevati multi-admin potvrdu za kritične akcije',
      ),
      LogicError(
        system: 'User Management',
        error:
            'Korisnici mogu imati konfliktne role u različitim delovima sistema',
        fix: 'Implementirati centralizovanu role kontrolu',
      ),
    ];
  }
}
