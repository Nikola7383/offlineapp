class Route {
  final List<Node> nodes;
  final String id;

  Route({required this.nodes}) : id = nodes.map((n) => n.id).join('-');

  int get hopCount => nodes.length - 1;
}
