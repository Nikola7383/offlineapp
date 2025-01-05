import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class OfflineService {
  final DatabaseService _db;
  final ApiService _api;
  final LoggerService _logger;
  bool _isOnline = false;
  Timer? _syncTimer;

  OfflineService({
    required DatabaseService db,
    required ApiService api,
    required LoggerService logger,
  })  : _db = db,
        _api = api,
        _logger = logger {
    _initConnectivityListener();
  }

  Future<void> _initConnectivityListener() async {
    // Slušamo promene konekcije
    Connectivity().onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _syncMessages();
      }
    });
  }

  Future<void> sendMessage(Message message) async {
    try {
      // Prvo sačuvaj lokalno
      await _db.saveMessage(message.copyWith(synced: false));

      // Pokušaj slanje ako smo online
      if (_isOnline) {
        await _api.sendMessage(message);
        await _db.updateMessageSync(message.id, true);
      }
    } catch (e) {
      _logger.error('Greška pri slanju poruke: $e');
      // Poruka ostaje u bazi sa synced = false
    }
  }

  Future<void> _syncMessages() async {
    try {
      // Uzmi sve nesinhronizovane poruke
      final unsynced = await _db.getUnsyncedMessages();

      for (final message in unsynced) {
        try {
          await _api.sendMessage(message);
          await _db.updateMessageSync(message.id, true);
        } catch (e) {
          _logger.error('Sync greška za poruku ${message.id}: $e');
        }
      }
    } catch (e) {
      _logger.error('Sync greška: $e');
    }
  }

  // Periodična sinhronizacija (na svakih 15 minuta kad smo online)
  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (_isOnline) _syncMessages();
    });
  }
}
