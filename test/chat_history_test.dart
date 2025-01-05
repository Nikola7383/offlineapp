import 'package:test/test.dart';
import '../lib/services/chat_history_service.dart';

void main() async {
  final service = ChatHistoryService();

  // Sačuvaj test poruke
  await service.saveMessage("Test poruka 1", true);
  await service.saveMessage("AI odgovor", false);
  await service.saveMessage("Još jedna test poruka", true);

  // Prikaži sadržaj
  print('\n=== SADRŽAJ FAJLA ===');
  print(await service.getFileContent());

  // Prikaži rezultate pretrage
  print('\n=== PRETRAGA "test" ===');
  final searchResults = service.searchMessages("test");
  searchResults.forEach((msg) => print('${msg.timestamp}: ${msg.content}'));

  // Prikaži današnje poruke
  print('\n=== DANAŠNJE PORUKE ===');
  final todayMessages = service.getTodayMessages();
  todayMessages.forEach((msg) => print('${msg.timestamp}: ${msg.content}'));
}
