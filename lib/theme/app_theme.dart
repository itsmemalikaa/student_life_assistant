import 'package:flutter/material.dart';

import 'page_transitions.dart';

/// Palet warna dominan pink ala "soft clay studio": lembut dan ceria.
/// Semua warna dikumpulkan di satu tempat supaya mudah diganti.
class AppColors {
  static const wine = Color(0xFFD94680); // pink utama (tombol, tab aktif)
  static const wineDark = Color(0xFFA82A5E); // pink raspberry, judul
  static const rose = Color(0xFFF8C8DA); // pink lembut
  static const mustard = Color(0xFFF6D47A); // kuning lembut (aksen)
  static const sage = Color(0xFFBFD8B5); // hijau sage (aksen)
  static const coral = Color(0xFFF2849E); // pink coral

  // Warna pendukung
  static const cream = Color(0xFFFFF0F5); // latar belakang blush pink
  static const paper = Color(0xFFFFF8FB); // warna kartu
  static const ink = Color(0xFF4A1830); // teks gelap (plum)
  static const forest = Color(0xFF3E5B3A); // teks di atas sage
  static const cocoa = Color(0xFF7A5512); // teks di atas kuning
  static const white15 = Color(0x26FFFFFF); // putih transparan 15%
  static const white30 = Color(0x4DFFFFFF); // putih transparan 30%
}

/// Font yang dipakai aplikasi (dibundel di assets/fonts).
class AppFonts {
  static const body = 'Nunito'; // teks biasa, bulat & mudah dibaca
  static const title = 'Baloo2'; // judul tebal, bulat & ceria
  static const script = 'DancingScript'; // tulisan sambung untuk nama & pesan
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.wine,
    ).copyWith(
      primary: AppColors.wine,
      onPrimary: Colors.white,
      primaryContainer: AppColors.rose,
      onPrimaryContainer: AppColors.wineDark,
      secondary: AppColors.forest,
      secondaryContainer: AppColors.sage,
      onSecondaryContainer: AppColors.forest,
      tertiary: AppColors.coral,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.mustard,
      onTertiaryContainer: AppColors.cocoa,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
    );
    return _build(scheme, cardColor: AppColors.paper);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.wine,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.rose,
      onPrimary: AppColors.wineDark,
      primaryContainer: AppColors.wineDark,
      onPrimaryContainer: AppColors.rose,
      secondaryContainer: AppColors.forest,
      onSecondaryContainer: AppColors.sage,
      tertiary: AppColors.wine,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.cocoa,
      onTertiaryContainer: AppColors.mustard,
      surface: const Color(0xFF1F0A15),
    );
    return _build(scheme, cardColor: const Color(0xFF2C1120));
  }

  static ThemeData _build(ColorScheme scheme, {required Color cardColor}) {
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppFonts.body,
      // Transparan supaya latar gradasi (GradientBackground) terlihat.
      scaffoldBackgroundColor: Colors.transparent,
      // Transisi halus untuk semua perpindahan halaman (push/pop).
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const SmoothPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.title,
          color: scheme.brightness == Brightness.light
              ? AppColors.wineDark
              : AppColors.rose,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
          color: scheme.brightness == Brightness.light
              ? const Color(0xFFF6D3E1)
              : scheme.primaryContainer,
          width: 1.2,
        ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: rounded,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primaryContainer),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primaryContainer),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.wineDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: AppColors.mustard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
      ),
    );
  }
}
