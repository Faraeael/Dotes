import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';

enum AppStatusTone { neutral, positive, warning, negative, info }

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    required this.label,
    this.tone = AppStatusTone.neutral,
    super.key,
  });

  final String label;
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppThemeTokens.of(context);
    final color = switch (tone) {
      AppStatusTone.neutral => theme.colorScheme.onSurfaceVariant,
      AppStatusTone.positive => tokens.positive,
      AppStatusTone.warning => tokens.warning,
      AppStatusTone.negative => tokens.negative,
      AppStatusTone.info => tokens.info,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(110)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
