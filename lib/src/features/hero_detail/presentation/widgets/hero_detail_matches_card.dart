import 'package:flutter/material.dart';

import '../../../matches/presentation/utils/match_formatters.dart';
import '../../../matches/presentation/widgets/match_info_chip.dart';
import '../../../player_import/domain/models/recent_match.dart';
import '../../domain/models/hero_detail.dart';

class HeroDetailMatchesCard extends StatelessWidget {
  const HeroDetailMatchesCard({required this.detail, super.key});

  final HeroDetail detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent matches on this hero',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (detail.recentMatches.isEmpty)
              Text(
                'No imported matches on this hero in the current sample.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (
                var index = 0;
                index < detail.recentMatches.length;
                index++
              ) ...[
                _HeroDetailMatchRow(match: detail.recentMatches[index]),
                if (index < detail.recentMatches.length - 1)
                  const Divider(height: 24),
              ],
          ],
        ),
      ),
    );
  }
}

class _HeroDetailMatchRow extends StatelessWidget {
  const _HeroDetailMatchRow({required this.match});

  final RecentMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultLabel = match.didWin ? 'Win' : 'Loss';
    final resultColor = match.didWin
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.errorContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatMatchDateTime(match.startedAt),
          style: theme.textTheme.bodySmall,
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
            MatchInfoChip(label: 'KDA', value: match.kdaLine),
            MatchInfoChip(label: 'Deaths', value: '${match.deaths}'),
          ],
        ),
      ],
    );
  }
}
