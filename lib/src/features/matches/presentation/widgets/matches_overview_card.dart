import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/section_card.dart';
import '../../../player_import/domain/models/recent_match.dart';
import '../utils/hero_labels.dart';
import '../utils/match_formatters.dart';
import 'match_info_chip.dart';

class MatchesOverviewCard extends StatelessWidget {
  const MatchesOverviewCard({
    required this.recentMatches,
    super.key,
  });

  final List<RecentMatch> recentMatches;

  @override
  Widget build(BuildContext context) {
    final visibleMatches = recentMatches.take(5).toList(growable: false);

    if (visibleMatches.isEmpty) {
      return const SectionCard(
        title: 'Recent matches',
        body:
            'No recent matches are available from OpenDota for this account yet.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent matches',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < visibleMatches.length; index++) ...[
              _MatchRow(match: visibleMatches[index]),
              if (index < visibleMatches.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match});

  final RecentMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultColor = match.didWin
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.errorContainer;
    final resultLabel = match.didWin ? 'Win' : 'Loss';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                heroDisplayName(match.heroId),
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                formatMatchDateTime(match.startedAt),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MatchInfoChip(
              label: 'Result',
              value: resultLabel,
              backgroundColor: resultColor,
            ),
            MatchInfoChip(
              label: 'KDA',
              value: match.kdaLine,
            ),
            MatchInfoChip(
              label: 'Duration',
              value: formatMatchDuration(match.duration),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Match #${match.matchId}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
