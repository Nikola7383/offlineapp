import 'dart:async';
import 'base_service.dart';
import '../models/event.dart';

/// Interfejs za upravljanje događajima u sistemu
abstract class IEventService extends IService {
  /// Kreira novi događaj
  Future<Event> createEvent(Event event);

  /// Ažurira postojeći događaj
  Future<Event> updateEvent(String eventId, Event event);

  /// Briše događaj
  Future<void> deleteEvent(String eventId);

  /// Vraća događaj po ID-u
  Future<Event?> getEvent(String eventId);

  /// Vraća listu događaja sa opcionalnim filterima
  Future<List<Event>> getEvents({
    EventType? type,
    EventPriority? priority,
    EventStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Vraća stream događaja za real-time praćenje
  Stream<Event> get eventStream;

  /// Procesira događaj (npr. šalje notifikacije, ažurira status)
  Future<void> processEvent(String eventId);

  /// Označava događaj kao završen
  Future<void> completeEvent(String eventId);

  /// Dodaje komentar na događaj
  Future<void> addComment(String eventId, String comment);

  /// Dodaje tag na događaj
  Future<void> addTag(String eventId, String tag);

  /// Arhivira stare događaje
  Future<void> archiveOldEvents(Duration olderThan);

  /// Vraća događaje za određenog korisnika
  Future<List<Event>> getUserEvents(String userId);
}
