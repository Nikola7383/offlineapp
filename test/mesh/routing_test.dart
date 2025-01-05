void main() {
  group('MeshRouter Tests', () {
    test('should find optimal route', () {
      final router = MeshRouter();
      final source = Node('A');
      final destination = Node('B');

      final route = router.findOptimalRoute(source, destination);

      expect(route, isNotNull);
      expect(route.nodes.length, lessThanOrEqualTo(router.maxHops));
    });
  });
}
