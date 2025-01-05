import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class SeedUser {
  String id;
  String name;
  String accessCode;
  bool isActive;
  DateTime createdAt;
  DateTime? lastActive;

  SeedUser({
    required this.id,
    required this.name,
    required this.accessCode,
    this.isActive = false,
    required this.createdAt,
    this.lastActive,
  });
}

class SeedManagementScreen extends StatefulWidget {
  const SeedManagementScreen({super.key});

  @override
  State<SeedManagementScreen> createState() => _SeedManagementScreenState();
}

class _SeedManagementScreenState extends State<SeedManagementScreen> {
  final List<SeedUser> _seeds = [];
  final _nameController = TextEditingController();
  final _random = Random.secure();
  DateTime? _lastAddAttempt;
  int _addAttempts = 0;
  DateTime? _lastActivationAttempt;
  int _activationAttempts = 0;

  // Pojačan rate limiting - 3 pokušaja u 60 sekundi
  bool _checkRateLimit() {
    final now = DateTime.now();
    if (_lastAddAttempt != null) {
      final timeDiff = now.difference(_lastAddAttempt!);
      if (timeDiff < const Duration(minutes: 1)) {
        _addAttempts++;
        if (_addAttempts >= 3) {
          final remainingSeconds = 60 - timeDiff.inSeconds;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Too many attempts. Please wait $remainingSeconds seconds.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: remainingSeconds),
            ),
          );
          return false;
        }
      } else {
        _addAttempts = 1;
      }
    }
    _lastAddAttempt = now;
    return true;
  }

  // Rate limiting za aktivaciju - 3 aktivacije u 60 sekundi
  bool _checkActivationRateLimit() {
    final now = DateTime.now();
    if (_lastActivationAttempt != null) {
      final timeDiff = now.difference(_lastActivationAttempt!);
      if (timeDiff < const Duration(minutes: 1)) {
        _activationAttempts++;
        if (_activationAttempts >= 3) {
          final remainingSeconds = 60 - timeDiff.inSeconds;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Too many activation attempts. Please wait $remainingSeconds seconds.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: remainingSeconds),
            ),
          );
          return false;
        }
      } else {
        _activationAttempts = 1;
      }
    }
    _lastActivationAttempt = now;
    return true;
  }

  String _generateAccessCode() {
    final bytes = List<int>.generate(32, (i) => _random.nextInt(256));
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 8).toUpperCase();
  }

  String _generateSecureId() {
    final bytes = List<int>.generate(16, (i) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  void _addNewSeed() {
    if (!_checkRateLimit()) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Sprečava zatvaranje klikom van dijaloga
      builder: (context) => AlertDialog(
        title: const Text('Add New Seed User'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Seed User Name (minimum 5 characters)',
            border: OutlineInputBorder(),
            helperText: 'Use only letters, numbers and spaces',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
            LengthLimitingTextInputFormatter(50),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.length >= 5) {
                // Povećan minimum na 5 karaktera
                if (_seeds
                    .any((s) => s.name.toLowerCase() == name.toLowerCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('A seed user with this name already exists'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                setState(() {
                  _seeds.add(
                    SeedUser(
                      id: _generateSecureId(),
                      name: name,
                      accessCode: _generateAccessCode(),
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                _nameController.clear();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name must be at least 5 characters long'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _copyAccessCode(String code) {
    Clipboard.setData(ClipboardData(text: code)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access code copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Seeds: ${_seeds.where((s) => s.isActive).length}/${_seeds.length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  onPressed: _addNewSeed,
                  child: const Text('Add Seed User'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _seeds.length,
              itemBuilder: (context, index) {
                final seed = _seeds[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              seed.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: seed.isActive ||
                                          !_checkActivationRateLimit()
                                      ? null
                                      : () => setState(() {
                                            seed.isActive = true;
                                            seed.lastActive = DateTime.now();
                                          }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Activate'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: !seed.isActive
                                      ? null
                                      : () => setState(() {
                                            seed.isActive = false;
                                          }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Deactivate'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text('Access Code: ${seed.accessCode}'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyAccessCode(seed.accessCode),
                              tooltip: 'Copy access code',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _seeds.removeAt(index);
                                });
                              },
                              tooltip: 'Delete seed user',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${seed.createdAt.toString().substring(0, 16)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (seed.lastActive != null)
                          Text(
                            'Last Active: ${seed.lastActive.toString().substring(0, 16)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
