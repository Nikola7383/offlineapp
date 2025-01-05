class ConsistencyChecker {
  static List<Inconsistency> findInconsistencies() {
    return [
      Inconsistency(
        component: 'Admin Verifikacija',
        issue: 'Različiti timeoutovi za različite metode verifikacije',
        fix: 'Standardizovati timeoutove',
      ),
      Inconsistency(
        component: 'Backup Sistem',
        issue: 'Backup podataka nije sinhronizovan sa main sistemom',
        fix: 'Dodati real-time sinhronizaciju',
      ),
      Inconsistency(
        component: 'Event Logging',
        issue: 'Neki eventi se loguju različito u različitim delovima sistema',
        fix: 'Standardizovati event logging',
      ),
    ];
  }
}
