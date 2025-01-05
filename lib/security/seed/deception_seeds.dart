class DeceptionSeeds {
  final Map<String, DeceptionSeed> _deceptionSeeds = {};

  Future<String> createDeceptionSeed(DeceptionType type) async {
    final seed = DeceptionSeed(
        id: _generateSeedId(),
        type: type,
        createdAt: DateTime.now(),
        behavior: await _generateDeceptiveBehavior(type));

    _deceptionSeeds[seed.id] = seed;
    return seed.id;
  }
}

enum DeceptionType {
  temporary, // Kratkoročni seed
  honeypot, // Mamac seed
  decoy // Seed koji šalje lažne podatke
}

class DeceptionSeed {
  final String id;
  final DeceptionType type;
  final DateTime createdAt;
  final DeceptiveBehavior behavior;

  DeceptionSeed(
      {required this.id,
      required this.type,
      required this.createdAt,
      required this.behavior});
}
