import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/master_admin/logs_provider.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(logsProvider.notifier).refreshLogs());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logovi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref.read(logsProvider.notifier).refreshLogs(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'ERROR',
                          state.showError,
                          Colors.red,
                          (value) => ref
                              .read(logsProvider.notifier)
                              .toggleErrorFilter(value),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'WARNING',
                          state.showWarning,
                          Colors.orange,
                          (value) => ref
                              .read(logsProvider.notifier)
                              .toggleWarningFilter(value),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'INFO',
                          state.showInfo,
                          Colors.blue,
                          (value) => ref
                              .read(logsProvider.notifier)
                              .toggleInfoFilter(value),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'DEBUG',
                          state.showDebug,
                          Colors.grey,
                          (value) => ref
                              .read(logsProvider.notifier)
                              .toggleDebugFilter(value),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Pretraži logove...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          ref.read(logsProvider.notifier).setSearchQuery(value),
                    ),
                  ),

                  // Log list
                  Expanded(
                    child: state.filteredLogs.isEmpty
                        ? const Center(
                            child: Text(
                              'Nema pronađenih logova',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.filteredLogs.length,
                            itemBuilder: (context, index) {
                              final log = state.filteredLogs[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _getLogLevelColor(log.level),
                                    child: Text(
                                      log.level[0],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(log.message),
                                  subtitle: Text(
                                      '${log.timestamp}\nIzvor: ${log.source}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () => _showLogDetails(log),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool selected,
    Color color,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: selected,
      selectedColor: color,
      checkmarkColor: Colors.white,
      backgroundColor: color.withOpacity(0.1),
      onSelected: onSelected,
    );
  }

  Color _getLogLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'ERROR':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      case 'INFO':
        return Colors.blue;
      case 'DEBUG':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filteri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(
              'Prikaži ERROR logove',
              ref.read(logsProvider).showError,
              (value) {
                ref.read(logsProvider.notifier).toggleErrorFilter(value);
                Navigator.pop(context);
              },
            ),
            _buildFilterOption(
              'Prikaži WARNING logove',
              ref.read(logsProvider).showWarning,
              (value) {
                ref.read(logsProvider.notifier).toggleWarningFilter(value);
                Navigator.pop(context);
              },
            ),
            _buildFilterOption(
              'Prikaži INFO logove',
              ref.read(logsProvider).showInfo,
              (value) {
                ref.read(logsProvider.notifier).toggleInfoFilter(value);
                Navigator.pop(context);
              },
            ),
            _buildFilterOption(
              'Prikaži DEBUG logove',
              ref.read(logsProvider).showDebug,
              (value) {
                ref.read(logsProvider.notifier).toggleDebugFilter(value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (value) => onChanged(value!),
    );
  }

  void _showLogDetails(LogInfo log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log nivo: ${log.level}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vreme: ${log.timestamp}'),
            const SizedBox(height: 8),
            Text('Izvor: ${log.source}'),
            const SizedBox(height: 8),
            const Text('Poruka:'),
            const SizedBox(height: 4),
            Text(
              log.message,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (log.stackTrace != null) ...[
              const SizedBox(height: 8),
              const Text('Stack Trace:'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.stackTrace!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }
}
