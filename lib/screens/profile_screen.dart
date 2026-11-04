import 'package:flutter/material.dart';

import '../models/user_preferences.dart';
import '../state/account_controller.dart';
import '../state/preferences_controller.dart';
import '../state/task_controller.dart';
import '../widgets/state_views.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.preferences,
    required this.tasks,
    required this.accounts,
    required this.onSwitchUser,
  });

  final PreferencesController preferences;
  final TaskController tasks;
  final AccountController accounts;
  final VoidCallback onSwitchUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: preferences,
          builder: (context, _) {
            if (preferences.isLoading) {
              return const LoadingView(message: 'Memuat preferensi...');
            }
            if (preferences.errorMessage != null) {
              return ErrorView(
                message: preferences.errorMessage!,
                onRetry: preferences.load,
              );
            }
            // Key berubah setiap preferensi tersimpan -> form diisi ulang.
            return _ProfileForm(
              key: ObjectKey(preferences.value),
              preferences: preferences,
              tasks: tasks,
              accounts: accounts,
              onSwitchUser: onSwitchUser,
            );
          },
        ),
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({
    super.key,
    required this.preferences,
    required this.tasks,
    required this.accounts,
    required this.onSwitchUser,
  });

  final PreferencesController preferences;
  final TaskController tasks;
  final AccountController accounts;
  final VoidCallback onSwitchUser;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  UserPreferences get _current => widget.preferences.value;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _current.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final messenger = ScaffoldMessenger.of(context);
    final newName = _nameController.text.trim();
    final ok = await widget.preferences.save(
      _current.copyWith(displayName: newName),
    );
    // Nama akun ikut diganti supaya muncul di halaman sambutan.
    final account = widget.accounts.current;
    if (ok && account != null) {
      await widget.accounts.rename(account.id, newName);
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Nama tersimpan di perangkat' : 'Gagal menyimpan nama',
        ),
      ),
    );
  }

  Future<void> _resetTasks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua tugas?'),
        content: const Text('Semua tugas yang tersimpan lokal akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.tasks.clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua tugas dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.preferences.isSaving;
    final name = _current.displayName;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama tampilan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: isSaving ? null : _saveName,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isSaving ? 'Menyimpan...' : 'Simpan Nama'),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.task_alt),
                      title: const Text('Tampilkan tugas selesai'),
                      value: _current.showCompletedTasks,
                      onChanged: widget.preferences.setShowCompletedTasks,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Mode gelap'),
                      value: _current.isDarkMode,
                      onChanged: widget.preferences.setDarkMode,
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.storage),
                      title: Text('Penyimpanan lokal'),
                      subtitle: Text(
                        'Preferensi, tugas, dan keuangan disimpan dengan '
                        'shared_preferences dan tetap ada setelah aplikasi '
                        'ditutup.',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: const Text('Hapus semua tugas'),
                      onTap: _resetTasks,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Tutup halaman Profil dulu, lalu kembali ke pemilihan
                  // pengguna. Data milik akun ini tetap tersimpan.
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  widget.onSwitchUser();
                },
                icon: const Icon(Icons.switch_account_rounded),
                label: const Text('Ganti pengguna'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
