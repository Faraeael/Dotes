import 'package:flutter/material.dart';

import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/hero_compare_block_actions.dart';
import '../../../hero_detail/domain/models/hero_detail.dart';

class HeroCompareHeroCard extends StatefulWidget {
  const HeroCompareHeroCard({
    required this.detail,
    required this.blockAction,
    required this.onUseHero,
    super.key,
  });

  final HeroDetail detail;
  final HeroCompareBlockActionEntry blockAction;
  final Future<void> Function() onUseHero;

  @override
  State<HeroCompareHeroCard> createState() => _HeroCompareHeroCardState();
}

class _HeroCompareHeroCardState extends State<HeroCompareHeroCard> {
  bool _isSaving = false;

  Future<void> _handlePressed() async {
    setState(() => _isSaving = true);
    try {
      await widget.onUseHero();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.detail.heroName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            AppMetricGrid(
              children: [
                AppMetricTile(
                  label: 'Matches',
                  value: '${widget.detail.matchesInSample}',
                ),
                AppMetricTile(label: 'Wins', value: '${widget.detail.wins}'),
                AppMetricTile(
                  label: 'Losses',
                  value: '${widget.detail.losses}',
                ),
                AppMetricTile(
                  label: 'Win rate',
                  value: '${widget.detail.winRatePercentage}%',
                ),
                AppMetricTile(
                  label: 'Average deaths',
                  value: widget.detail.averageDeaths?.toStringAsFixed(1) ?? '-',
                ),
                AppMetricTile(
                  label: 'Meta',
                  value: widget.detail.metaSummary.reference?.tier.label ??
                      'No meta reference',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statusBadge(
                  label: widget.detail.tags.contains(HeroDetailTag.comfortCore)
                      ? 'Comfort core'
                      : 'Outside comfort core',
                  tone: widget.detail.tags.contains(HeroDetailTag.comfortCore)
                      ? AppStatusTone.info
                      : AppStatusTone.neutral,
                ),
                _statusBadge(
                  label: widget.detail.tags
                          .contains(HeroDetailTag.inCurrentPlan)
                      ? 'In current plan'
                      : 'Outside current plan',
                  tone: widget.detail.tags.contains(HeroDetailTag.inCurrentPlan)
                      ? AppStatusTone.positive
                      : AppStatusTone.warning,
                ),
                if (widget.blockAction.isAlreadyInBlock)
                  _statusBadge(
                    label: 'Already in block',
                    tone: AppStatusTone.positive,
                  ),
              ],
            ),
            if (widget.detail.blockContext != null) ...[
              const SizedBox(height: 12),
              Text(
                'Block context: ${widget.detail.blockContext!.lastPlanStatus.label}. ${widget.detail.blockContext!.trendStatus.label}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _isSaving ? null : _handlePressed,
                child: Text(
                  _isSaving
                      ? 'Saving...'
                      : widget.blockAction.actionLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge({
    required String label,
    required AppStatusTone tone,
  }) {
    return AppStatusBadge(label: label, tone: tone);
  }
}
