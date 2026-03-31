import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme_tokens.dart';
import '../../../../app/widgets/app_card_header.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.title,
    required this.body,
    this.leading,
    this.action,
    super.key,
  });

  final String title;
  final String body;
  final Widget? leading;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.panelBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: leading!,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(child: AppCardHeader(title: title)),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
