import 'package:flutter/material.dart';

/// Palet warna aplikasi (cherry, blueberry, limeade, strawberry, raspberry).
/// Semua warna dikumpulkan di satu tempat supaya mudah diganti.
class AppColors {
  static const cherry = Color(0xFFDB1374);
  static const blueberry = Color(0xFFB9C9E7);
  static const limeade = Color(0xFFDBE586);
  static const strawberry = Color(0xFFEFC0DA);
  static const raspberry = Color(0xFF991E5A);

  // Warna pendukung (turunan dari palet).
  static const blush = Color(0xFFFFF5F9); // latar belakang halaman
  static const ink = Color(0xFF3A1027); // teks gelap bernuansa raspberry
  static const navy = Color(0xFF26355C); // teks di atas blueberry
  static const olive = Color(0xFF4A5214); // teks di atas limeade
  static const white15 = Color(0x26FFFFFF); // putih transparan 15%
  static const white30 = Color(0x4DFFFFFF); // putih transparan 30%
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cherry,
    ).copyWith(
      primary: AppColors.cherry,
      onPrimary: Colors.white,
      primaryContainer: AppColors.strawberry,
      onPrimaryContainer: AppColors.raspberry,
      secondary: AppColors.navy,
      secondaryContainer: AppColors.blueberry,
      onSecondaryContainer: AppColors.navy,
      tertiary: AppColors.raspberry,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.limeade,
      onTertiaryContainer: AppColors.olive,
      surface: AppColors.blush,
      onSurface: AppColors.ink,
    );
    return _build(scheme, cardColor: Colors.white);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cherry,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.strawberry,
      onPrimary: AppColors.raspberry,
      primaryContainer: AppColors.raspberry,
      onPrimaryContainer: AppColors.strawberry,
      secondaryContainer: AppColors.navy,
      onSecondaryContainer: AppColors.blueberry,
      tertiary: AppColors.cherry,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.olive,
      onTertiaryContainer: AppColors.limeade,
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
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: scheme.brightness == Brightness.light
              ? AppColors.raspberry
              : AppColors.strawberry,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.primaryContainer, width: 1.2),
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
        backgroundColor: AppColors.raspberry,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: AppColors.limeade,
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
