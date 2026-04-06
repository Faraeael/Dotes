import 'package:flutter/material.dart';

class AppReasonList extends StatelessWidget {
  const AppReasonList({required this.reasons, super.key});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < reasons.length; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(reasons[index], style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
          if (index < reasons.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
