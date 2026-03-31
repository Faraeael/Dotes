import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/block_review.dart';

class BlockReviewCard extends StatelessWidget {
  const BlockReviewCard({required this.review, super.key});

  final BlockReview review;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCardHeader(
              title: 'Block review',
              subtitle:
                  'Check whether the last block stayed clean enough to trust and moved in the right direction.',
              trailing: AppStatusBadge(
                label: review.overallOutcome.label,
                tone: _toneForOutcome(review.overallOutcome),
              ),
            ),
            const SizedBox(height: 16),
            AppMetricGrid(
              children: [
                AppMetricTile(label: 'Block', value: review.blockStatus.label),
                AppMetricTile(label: 'Games', value: review.gamesLoggedLabel),
                AppMetricTile(
                  label: 'Discipline',
                  value: review.adherence.label,
                ),
                AppMetricTile(
                  label: 'Target',
                  value: review.targetResult.label,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppStatusTone _toneForOutcome(BlockReviewOutcome outcome) {
    return switch (outcome) {
      BlockReviewOutcome.onTrack => AppStatusTone.positive,
      BlockReviewOutcome.mixed => AppStatusTone.warning,
      BlockReviewOutcome.offTrack => AppStatusTone.negative,
    };
  }
}
