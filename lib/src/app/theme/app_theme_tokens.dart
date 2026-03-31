import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.panelBorder,
    required this.panelBorderStrong,
    required this.panelRaised,
    required this.panelMuted,
    required this.positive,
    required this.warning,
    required this.negative,
    required this.info,
  });

  final Color panelBorder;
  final Color panelBorderStrong;
  final Color panelRaised;
  final Color panelMuted;
  final Color positive;
  final Color warning;
  final Color negative;
  final Color info;

  factory AppThemeTokens.fallback(ColorScheme scheme) {
    return AppThemeTokens(
      panelBorder: scheme.outline,
      panelBorderStrong: scheme.outlineVariant,
      panelRaised: scheme.surfaceContainerHigh,
      panelMuted: scheme.surfaceContainerLow,
      positive: const Color(0xFF2E8B57),
      warning: const Color(0xFFB8860B),
      negative: scheme.error,
      info: scheme.primary,
    );
  }

  static AppThemeTokens of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppThemeTokens>() ??
        AppThemeTokens.fallback(theme.colorScheme);
  }

  @override
  AppThemeTokens copyWith({
    Color? panelBorder,
    Color? panelBorderStrong,
    Color? panelRaised,
    Color? panelMuted,
    Color? positive,
    Color? warning,
    Color? negative,
    Color? info,
  }) {
    return AppThemeTokens(
      panelBorder: panelBorder ?? this.panelBorder,
      panelBorderStrong: panelBorderStrong ?? this.panelBorderStrong,
      panelRaised: panelRaised ?? this.panelRaised,
      panelMuted: panelMuted ?? this.panelMuted,
      positive: positive ?? this.positive,
      warning: warning ?? this.warning,
      negative: negative ?? this.negative,
      info: info ?? this.info,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }

    return AppThemeTokens(
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t)!,
      panelBorderStrong:
          Color.lerp(panelBorderStrong, other.panelBorderStrong, t)!,
      panelRaised: Color.lerp(panelRaised, other.panelRaised, t)!,
      panelMuted: Color.lerp(panelMuted, other.panelMuted, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
