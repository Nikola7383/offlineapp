class MessageService {
  final List<String> _messages = [];

  void addMessage(String message) {
    _messages.add(message);
  }

  List<String> getMessages() {
    return List.from(_messages);
  }

  void deleteMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
    }
  }

  void clearMessages() {
    _messages.clear();
  }

  int get messageCount => _messages.length;
}
