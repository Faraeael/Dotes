import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../../checkpoints/domain/models/training_block_action.dart';
import '../../../matches/presentation/utils/hero_labels.dart';
import '../../domain/models/session_plan.dart';
import '../../domain/models/session_plan_meta_sanity.dart';
import 'hero_link_chips.dart';
import 'session_plan_block_action_panel.dart';

class SessionPlanCard extends StatelessWidget {
  const SessionPlanCard({
    required this.plan,
    this.metaSanity,
    this.onSelectHero,
    this.trainingBlockActionControl,
    this.onStartTrainingBlock,
    this.isStartingTrainingBlock = false,
    super.key,
  });

  final SessionPlan plan;
  final SessionPlanMetaSanity? metaSanity;
  final ValueChanged<int>? onSelectHero;
  final TrainingBlockActionControl? trainingBlockActionControl;
  final VoidCallback? onStartTrainingBlock;
  final bool isStartingTrainingBlock;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCardHeader(
              title: 'Session plan',
              subtitle: 'Keep the next block tight so the review stays honest.',
              trailing: _buildManualSummary(),
            ),
            const SizedBox(height: 16),
            AppMetricTile(
              label: 'Focus',
              value: plan.target,
              minWidth: double.infinity,
            ),
            const SizedBox(height: 12),
            AppMetricGrid(
              children: [
                AppMetricTile(label: 'Queue', value: plan.queue),
                AppMetricTile(label: 'Heroes', value: plan.heroBlock),
                AppMetricTile(label: 'Review window', value: plan.reviewWindow),
              ],
            ),
            if (plan.hasHeroSpecificBlock && onSelectHero != null) ...[
              const SizedBox(height: 12),
              HeroLinkChips(
                heroes: plan.heroBlockHeroIds
                    .map(
                      (heroId) => HeroLinkChipData(
                        heroId: heroId,
                        label: heroDisplayName(heroId),
                      ),
                    )
                    .toList(growable: false),
                onSelectHero: onSelectHero!,
              ),
            ],
            if (metaSanity != null) ...[
              const SizedBox(height: 12),
              _SessionPlanMetaSanityPanel(metaSanity: metaSanity!),
            ],
            if (trainingBlockActionControl != null &&
                onStartTrainingBlock != null) ...[
              const SizedBox(height: 12),
              SessionPlanBlockActionPanel(
                control: trainingBlockActionControl!,
                isSaving: isStartingTrainingBlock,
                onPressed: onStartTrainingBlock!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildManualSummary() {
    if (plan.usesManualRoleSetup && plan.usesManualHeroBlock) {
      return const AppStatusBadge(
        label: 'Manual role + heroes',
        tone: AppStatusTone.info,
      );
    }

    if (plan.usesManualRoleSetup) {
      return const AppStatusBadge(
        label: 'Manual role',
        tone: AppStatusTone.info,
      );
    }

    if (plan.usesManualHeroBlock) {
      return const AppStatusBadge(
        label: 'Manual heroes',
        tone: AppStatusTone.info,
      );
    }

    return null;
  }
}

class _SessionPlanMetaSanityPanel extends StatelessWidget {
  const _SessionPlanMetaSanityPanel({required this.metaSanity});

  final SessionPlanMetaSanity metaSanity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Meta sanity',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              AppStatusBadge(
                label: metaSanity.status.label,
                tone: _toneFor(metaSanity.status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(metaSanity.message),
        ],
      ),
    );
  }

  AppStatusTone _toneFor(SessionPlanMetaSanityStatus status) {
    return switch (status) {
      SessionPlanMetaSanityStatus.metaAligned => AppStatusTone.positive,
      SessionPlanMetaSanityStatus.mixed => AppStatusTone.info,
      SessionPlanMetaSanityStatus.comfortFirst => AppStatusTone.warning,
      SessionPlanMetaSanityStatus.noReference => AppStatusTone.neutral,
      SessionPlanMetaSanityStatus.stale => AppStatusTone.warning,
    };
  }
}
