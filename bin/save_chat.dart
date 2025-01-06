import 'package:secure_event_app/conversation_history.dart';

void main() {
  final history = ConversationHistory();

  try {
    history.save("Sada vidim poruke. Hocu ovvu poruku da vidim tamo.", false);

    history.save(
        "Odlično! Konačno radi kako treba. Sačuvaću i ovu poruku, i svaku sledeću će se automatski čuvati u chat_history.txt",
        true);

    history.open();
  } catch (e) {
    print('FATAL ERROR: $e');
  }
}
