import 'base_service.dart';

/// Interfejs za asinhrone servise
abstract class IAsyncService implements IService {
  /// Ponovo uspostavlja konekciju
  Future<void> reconnect();

  /// Pauzira servis
  Future<void> pause();

  /// Nastavlja rad servisa
  Future<void> resume();
}
