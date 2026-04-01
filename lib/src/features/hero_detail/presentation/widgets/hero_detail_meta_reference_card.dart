import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../../meta_reference/domain/models/hero_meta_freshness.dart';
import '../../../meta_reference/domain/models/hero_meta_reference.dart';
import '../../domain/models/hero_detail.dart';

class HeroDetailMetaReferenceCard extends StatelessWidget {
  const HeroDetailMetaReferenceCard({required this.detail, super.key});

  final HeroDetail detail;

  @override
  Widget build(BuildContext context) {
    final metaSummary = detail.metaSummary;
    final reference = metaSummary.reference;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCardHeader(
              title: 'Meta reference',
              subtitle: reference == null
                  ? metaSummary.fallbackMessage
                  : 'High-level patch context for this hero.',
              trailing: reference == null ? null : _MetaBadges(detail: detail),
            ),
            if (metaSummary.isStale && metaSummary.staleWarning != null) ...[
              const SizedBox(height: 12),
              AppStatusBadge(
                label: metaSummary.staleWarning!,
                tone: AppStatusTone.warning,
              ),
            ],
            if (reference != null) ...[
              const SizedBox(height: 16),
              AppMetricGrid(
                children: [
                  AppMetricTile(label: 'Patch', value: reference.patchLabel),
                  AppMetricTile(label: 'Common role', value: reference.roleLabel),
                ],
              ),
              const SizedBox(height: 16),
              _MetaLine(
                label: 'Core item direction',
                value: reference.coreItemDirection,
              ),
              if (reference.skillBuildDirection != null) ...[
                const SizedBox(height: 12),
                _MetaLine(
                  label: 'Skill build direction',
                  value: reference.skillBuildDirection!,
                ),
              ],
            ],
            const SizedBox(height: 16),
            _MetaLine(
              label: 'Interpretation',
              value: metaSummary.interpretation,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaBadges extends StatelessWidget {
  const _MetaBadges({required this.detail});

  final HeroDetail detail;

  @override
  Widget build(BuildContext context) {
    final reference = detail.metaSummary.reference!;
    final freshness = detail.metaSummary.freshness;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusBadge(
          label: reference.tier.label,
          tone: _tierTone(reference.tier),
        ),
        if (freshness != null)
          AppStatusBadge(
            label: freshness.status.label,
            tone: _freshnessTone(freshness.status),
          ),
      ],
    );
  }

  AppStatusTone _tierTone(HeroMetaTier tier) {
    return switch (tier) {
      HeroMetaTier.top => AppStatusTone.positive,
      HeroMetaTier.strong => AppStatusTone.info,
      HeroMetaTier.neutral => AppStatusTone.neutral,
      HeroMetaTier.niche => AppStatusTone.warning,
    };
  }

  AppStatusTone _freshnessTone(HeroMetaFreshnessStatus status) {
    return switch (status) {
      HeroMetaFreshnessStatus.current => AppStatusTone.info,
      HeroMetaFreshnessStatus.outdated => AppStatusTone.warning,
    };
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(value),
      ],
    );
  }
}
