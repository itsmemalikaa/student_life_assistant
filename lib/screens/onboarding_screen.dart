import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/decorations.dart';
import '../widgets/shapes.dart';

/// Halaman perkenalan (pendaftaran pengguna baru).
/// Kalau nama yang diketik sudah pernah terdaftar di perangkat ini,
/// pengguna langsung masuk ke datanya yang lama.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onSubmit, this.onBack});

  final Future<void> Function(String name) onSubmit;
  final VoidCallback? onBack; // muncul jika sudah ada pengguna lain

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await widget.onSubmit(_nameController.text.trim());
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.onBack == null
          ? null
          : AppBar(
              leading: IconButton(
                tooltip: 'Kembali',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              ),
            ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const _FlowerCluster(),
                    const SizedBox(height: 20),
                    const Text(
                      'Hai, kenalan dulu yuk!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.title,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.wineDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Squiggle(),
                    const SizedBox(height: 12),
                    const Text(
                      'Siapa nama kamu? Kalau namamu sudah pernah dipakai '
                      'di perangkat ini, datamu akan langsung muncul lagi.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _start(),
                      decoration: const InputDecoration(
                        labelText: 'Nama panggilan',
                        prefixIcon: Icon(Icons.face_retouching_natural),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Isi nama dulu ya'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _start,
                        child: Text(_isSaving ? 'Menyiapkan...' : 'Mulai'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hiasan bunga di atas halaman perkenalan & sambutan.
class _FlowerCluster extends StatelessWidget {
  const _FlowerCluster();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Sticker('flower', size: 96, floatDistance: 6),
          Positioned(
            left: 40,
            top: 0,
            child: Sticker('sparkle', size: 40, angle: -0.2),
          ),
          Positioned(
            right: 40,
            bottom: 0,
            child: Sticker('heart', size: 44, angle: 0.3),
          ),
        ],
      ),
    );
  }
}
