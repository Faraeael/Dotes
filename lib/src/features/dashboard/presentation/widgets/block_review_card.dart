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
                  'Whether you followed the plan, and whether the coaching target moved.',
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
                  label: 'Adherence',
                  value: review.adherence.label,
                ),
                AppMetricTile(
                  label: 'Target result',
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
