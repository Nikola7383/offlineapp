import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/broadcast/broadcast_provider.dart';
import '../../providers/guest/guest_provider.dart';

class CreateBroadcastScreen extends ConsumerStatefulWidget {
  const CreateBroadcastScreen({super.key});

  @override
  ConsumerState<CreateBroadcastScreen> createState() =>
      _CreateBroadcastScreenState();
}

class _CreateBroadcastScreenState extends ConsumerState<CreateBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  bool _isUrgent = false;
  bool _isSending = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    final guest = ref.read(guestProvider).value;
    if (guest == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Niste autorizovani za slanje poruka'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    try {
      await ref.read(broadcastsProvider.notifier).createBroadcast(
            content: _contentController.text,
            senderId: guest.id,
            isUrgent: _isUrgent,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poruka je uspešno poslata'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Broadcast Poruka'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Sadržaj poruke',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unesite sadržaj poruke';
                }
                if (value.length < 10) {
                  return 'Poruka mora imati najmanje 10 karaktera';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Hitna poruka'),
              subtitle: const Text(
                'Označite ako je poruka hitna i treba da bude istaknuta',
              ),
              value: _isUrgent,
              onChanged: (value) => setState(() => _isUrgent = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSending ? null : _sendBroadcast,
              child: _isSending
                  ? const CircularProgressIndicator()
                  : const Text('Pošalji Poruku'),
            ),
          ],
        ),
      ),
    );
  }
}
