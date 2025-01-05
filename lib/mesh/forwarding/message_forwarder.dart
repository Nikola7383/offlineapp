class MessageForwarder {
  final Set<String> processedMessages = {};
  final int maxRetries = 3;

  Future<void> forwardMessage(Message message) async {
    if (shouldForward(message)) {
      final nodes = await findForwardingNodes();
      for (var node in nodes) {
        await attemptForward(message, node);
      }
    }
  }

  bool shouldForward(Message message) {
    return !processedMessages.contains(message.id) && message.hops < maxHops;
  }
}
