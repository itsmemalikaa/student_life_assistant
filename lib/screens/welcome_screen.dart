import 'package:flutter/material.dart';

import '../models/account.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy.dart';
import '../widgets/decorations.dart';
import '../widgets/shapes.dart';

/// Sambutan untuk pengguna yang pernah masuk (login dengan nama).
class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({
    super.key,
    required this.name,
    required this.onContinue,
    required this.onNotYou,
  });

  final String name;
  final Future<void> Function() onContinue;
  final VoidCallback onNotYou;

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  bool _isLoading = false;

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    await widget.onContinue();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const SizedBox(
                    height: 130,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Sticker('tulip', size: 110, floatDistance: 6),
                        Positioned(
                          left: 30,
                          bottom: 8,
                          child: Sticker('daisy', size: 46, angle: -0.2),
                        ),
                        Positioned(
                          right: 36,
                          top: 4,
                          child: Sticker('sparkle', size: 40, angle: 0.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Halo, ${widget.name}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.title,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.wineDark,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Senang bertemu kembali ya',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.script,
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      color: AppColors.wine,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Squiggle(),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _continue,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(_isLoading ? 'Memuat datamu...' : 'Masuk'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Bukan kamu?'),
                      TextButton(
                        onPressed: _isLoading ? null : widget.onNotYou,
                        child: const Text('Ganti nama'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Daftar pengguna yang pernah masuk di perangkat ini.
class AccountPickerScreen extends StatelessWidget {
  const AccountPickerScreen({
    super.key,
    required this.accounts,
    required this.onPick,
    required this.onAddNew,
    this.onBack,
  });

  final List<Account> accounts;
  final ValueChanged<Account> onPick;
  final VoidCallback onAddNew;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    const colors = [AppColors.rose, AppColors.mustard, AppColors.sage];

    return Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(
                tooltip: 'Kembali',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SectionTitle(
                  'Siapa yang mau masuk?',
                  decoration: Sticker('heart', size: 28, angle: 0.2),
                ),
                const SizedBox(height: 8),
                const Text('Pilih namamu untuk membuka data milikmu.'),
                const SizedBox(height: 20),
                for (var i = 0; i < accounts.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Bouncy(
                      child: Material(
                        color: colors[i % colors.length],
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => onPick(accounts[i]),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.wineDark,
                                  child: Text(
                                    accounts[i].name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: AppFonts.title,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    accounts[i].name,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.title,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.ink,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onAddNew,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Pengguna baru'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
