import 'package:flutter/material.dart';
import 'conversation_history.dart';

void main() {
  var history = ConversationHistory();

  history.save("Da ali ti se crveni", false);
  history.save(
      "Da, crveni se jer nam fale dependencies. Dodajmo ih u pubspec.yaml",
      true);

  history.open();

  runApp(const MaterialApp(home: Scaffold()));
}
