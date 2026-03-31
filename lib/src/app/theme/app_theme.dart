import 'package:flutter/material.dart';

import 'app_theme_tokens.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const scaffold = Color(0xFF090D12);
    const surface = Color(0xFF10161D);
    const raised = Color(0xFF151D26);
    const muted = Color(0xFF0D1319);
    const primary = Color(0xFFC96C42);
    const secondary = Color(0xFF7F97A6);
    const positive = Color(0xFF4FBF8A);
    const warning = Color(0xFFD6A24A);
    const negative = Color(0xFFD86C64);
    const info = Color(0xFF6E9BD6);
    const outline = Color(0xFF28313B);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      onPrimary: const Color(0xFF0B0E12),
      secondary: secondary,
      onSecondary: const Color(0xFF0B0E12),
      tertiary: info,
      surface: surface,
      surfaceDim: scaffold,
      surfaceBright: const Color(0xFF1A222C),
      surfaceContainerLowest: scaffold,
      surfaceContainerLow: muted,
      surfaceContainer: surface,
      surfaceContainerHigh: raised,
      surfaceContainerHighest: const Color(0xFF1C2630),
      outline: outline,
      outlineVariant: const Color(0xFF1D252E),
      error: negative,
      onError: const Color(0xFF0B0E12),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      dividerColor: outline,
      textTheme: Typography.whiteCupertino.copyWith(
        displayLarge: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
        headlineMedium: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(fontSize: 15, height: 1.45),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.45),
        bodySmall: const TextStyle(fontSize: 12, height: 1.4),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: muted,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        shadowColor: Colors.black.withAlpha(80),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: primary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: const BorderSide(color: outline),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: muted,
        side: const BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      extensions: const [
        AppThemeTokens(
          panelBorder: outline,
          panelBorderStrong: Color(0xFF37424E),
          panelRaised: raised,
          panelMuted: muted,
          positive: positive,
          warning: warning,
          negative: negative,
          info: info,
        ),
      ],
    );
  }
}
