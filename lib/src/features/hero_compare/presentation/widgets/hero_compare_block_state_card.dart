import 'package:flutter/material.dart';

import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/hero_compare_block_actions.dart';

class HeroCompareBlockStateCard extends StatelessWidget {
  const HeroCompareBlockStateCard({
    required this.blockActions,
    super.key,
  });

  final HeroCompareBlockActions blockActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Current training block',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                AppStatusBadge(
                  label: blockActions.coachingModeLabel,
                  tone: AppStatusTone.info,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(blockActions.currentBlockLabel),
            if (blockActions.willSwitchToManualSetup) ...[
              const SizedBox(height: 8),
              Text(
                'Using an action here will switch to Prefer manual setup.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
