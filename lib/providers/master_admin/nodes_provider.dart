import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'nodes_provider.freezed.dart';

@freezed
class NodeInfo with _$NodeInfo {
  const factory NodeInfo({
    required String id,
    required String name,
    required bool isActive,
    required String lastActivity,
    required int messageCount,
    required double uptime,
  }) = _NodeInfo;
}

@freezed
class NodesState with _$NodesState {
  const factory NodesState({
    @Default([]) List<NodeInfo> nodes,
    @Default('all') String filter,
    @Default(false) bool isLoading,
    String? error,
  }) = _NodesState;

  const NodesState._();

  List<NodeInfo> get filteredNodes {
    switch (filter) {
      case 'active':
        return nodes.where((node) => node.isActive).toList();
      case 'inactive':
        return nodes.where((node) => !node.isActive).toList();
      default:
        return nodes;
    }
  }

  int get activeNodes => nodes.where((node) => node.isActive).length;
  int get inactiveNodes => nodes.where((node) => !node.isActive).length;
}

class NodesNotifier extends StateNotifier<NodesState> {
  NodesNotifier() : super(const NodesState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati učitavanje podataka
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(
        isLoading: false,
        nodes: [
          const NodeInfo(
            id: '1',
            name: 'Node 1',
            isActive: true,
            lastActivity: '2024-01-15 14:30',
            messageCount: 145,
            uptime: 0.98,
          ),
          const NodeInfo(
            id: '2',
            name: 'Node 2',
            isActive: true,
            lastActivity: '2024-01-15 14:25',
            messageCount: 89,
            uptime: 0.95,
          ),
          const NodeInfo(
            id: '3',
            name: 'Node 3',
            isActive: false,
            lastActivity: '2024-01-15 10:15',
            messageCount: 56,
            uptime: 0.75,
          ),
        ],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshNodes() async {
    await _loadInitialData();
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> reconnectNode(String nodeId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati ponovno povezivanje čvora
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final updatedNodes = state.nodes.map((node) {
        if (node.id == nodeId) {
          return node.copyWith(isActive: true);
        }
        return node;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        nodes: updatedNodes,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeNode(String nodeId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati uklanjanje čvora
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final updatedNodes =
          state.nodes.where((node) => node.id != nodeId).toList();

      state = state.copyWith(
        isLoading: false,
        nodes: updatedNodes,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final nodesProvider = StateNotifierProvider<NodesNotifier, NodesState>((ref) {
  return NodesNotifier();
});
