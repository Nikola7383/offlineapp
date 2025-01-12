import 'package:injectable/injectable.dart';
import 'base_service.dart';
import '../models/test_message.dart';

abstract class ICommunicationManager extends IService {
  Future<void> sendViaBluetooth(TestMessage message);
  Future<void> sendViaSound(TestMessage message);
  Future<void> sendViaMesh(TestMessage message);
  Future<void> initialize();
  Future<void> dispose();
}
