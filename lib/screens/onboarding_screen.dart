import 'package:flutter/material.dart';

import '../state/preferences_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/decorations.dart';
import '../widgets/shapes.dart';

/// Halaman perkenalan yang muncul saat aplikasi pertama kali dibuka
/// di sebuah perangkat. Nama disimpan lokal, jadi setiap pengguna
/// (setiap perangkat/browser) punya nama dan datanya sendiri.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.preferences});

  final PreferencesController preferences;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    // Setelah nama tersimpan, aplikasi otomatis pindah ke beranda
    // (main.dart mendengarkan perubahan preferensi).
    await widget.preferences.save(
      widget.preferences.value.copyWith(
        displayName: _nameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.preferences.isSaving;

    return Scaffold(
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
                    const SizedBox(
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
                    ),
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
                      'Siapa nama kamu? Nama ini cuma disimpan '
                      'di perangkat ini.',
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
                        onPressed: isSaving ? null : _start,
                        child: Text(isSaving ? 'Menyimpan...' : 'Mulai'),
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
