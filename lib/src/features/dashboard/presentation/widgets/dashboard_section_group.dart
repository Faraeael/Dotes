import 'package:flutter/material.dart';

class DashboardSectionGroup extends StatelessWidget {
  const DashboardSectionGroup({
    required this.title,
    required this.subtitle,
    required this.children,
    this.collapsible = false,
    this.isExpanded = true,
    this.onToggleExpanded,
    this.emptyMessage,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool collapsible;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (collapsible)
              TextButton.icon(
                onPressed: onToggleExpanded,
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(
                  isExpanded ? 'Collapse details' : 'Expand details',
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (!isExpanded && collapsible) ...[
          const SizedBox(height: 12),
          Text(
            'Supporting cards are collapsed for now.',
            style: theme.textTheme.bodySmall,
          ),
        ] else if (children.isEmpty && emptyMessage != null) ...[
          const SizedBox(height: 12),
          Text(emptyMessage!, style: theme.textTheme.bodyMedium),
        ] else if (children.isNotEmpty) ...[
          const SizedBox(height: 16),
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1) const SizedBox(height: 16),
          ],
        ],
      ],
    );
  }
}
