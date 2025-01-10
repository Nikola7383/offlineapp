/// Tipovi bezbednosnih događaja u sistemu
enum SecurityEvent {
  /// Detektovan napad na sistem
  attackDetected,

  /// Detektovana anomalija u ponašanju
  anomalyDetected,

  /// Protokol je kompromitovan
  protocolCompromised,

  /// Započeta Phoenix regeneracija
  phoenixRegeneration,

  /// Detektovana manipulacija podacima
  dataManipulationDetected,

  /// Detektovan pokušaj DoS napada
  dosAttemptDetected,

  /// Detektovan pokušaj MitM napada
  mitMAttemptDetected,

  /// Detektovan pokušaj replay napada
  replayAttemptDetected,

  /// Detektovan pokušaj timing napada
  timingAttemptDetected,

  /// Detektovan pokušaj side-channel napada
  sideChannelAttemptDetected,

  /// Detektovan pokušaj social engineering napada
  socialEngineeringAttemptDetected,

  /// Detektovan pokušaj phishing napada
  phishingAttemptDetected,

  /// Detektovan pokušaj brute force napada
  bruteForceAttemptDetected,

  /// Detektovan pokušaj SQL injection napada
  sqlInjectionAttemptDetected,

  /// Detektovan pokušaj XSS napada
  xssAttemptDetected,

  /// Detektovan pokušaj CSRF napada
  csrfAttemptDetected,

  /// Detektovan pokušaj buffer overflow napada
  bufferOverflowAttemptDetected,

  /// Detektovan pokušaj race condition napada
  raceConditionAttemptDetected,

  /// Detektovan pokušaj privilege escalation napada
  privilegeEscalationAttemptDetected,

  /// Detektovan pokušaj backdoor napada
  backdoorAttemptDetected,

  /// Detektovan pokušaj rootkit napada
  rootkitAttemptDetected,

  /// Detektovan pokušaj ransomware napada
  ransomwareAttemptDetected,

  /// Detektovan pokušaj malware napada
  malwareAttemptDetected,

  /// Detektovan pokušaj spyware napada
  spywareAttemptDetected,

  /// Detektovan pokušaj adware napada
  adwareAttemptDetected,

  /// Detektovan pokušaj cryptojacking napada
  cryptojackingAttemptDetected,

  /// Detektovan pokušaj zero-day napada
  zeroDayAttemptDetected,
}
