class MeshService {
  final MeshRouter router;
  final ProtocolSelector protocolSelector;
  final PowerManager powerManager;
  final MessageSecurity security;
  final MessageStorage storage;

  Future<void> sendMessage(Message message) async {
    powerManager.optimizePowerConsumption();

    final encrypted = await security.encryptMessage(message.content);
    final protocol =
        protocolSelector.selectOptimalProtocol(getCurrentContext());

    final route =
        await router.findOptimalRoute(getCurrentNode(), message.destination);

    await storage.saveMessage(message);
    await transmitMessage(encrypted, route, protocol);
  }
}
