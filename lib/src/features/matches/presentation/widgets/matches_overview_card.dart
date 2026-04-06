import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/section_card.dart';
import '../../../player_import/domain/models/recent_match.dart';
import '../utils/hero_labels.dart';
import '../utils/match_formatters.dart';
import 'match_info_chip.dart';

class MatchesOverviewCard extends StatefulWidget {
  const MatchesOverviewCard({
    required this.recentMatches,
    required this.onSelectHero,
    super.key,
  });

  final List<RecentMatch> recentMatches;
  final ValueChanged<int> onSelectHero;

  @override
  State<MatchesOverviewCard> createState() => _MatchesOverviewCardState();
}

class _MatchesOverviewCardState extends State<MatchesOverviewCard> {
  static const _collapsedMatchCount = 5;
  bool _showAllMatches = false;

  @override
  Widget build(BuildContext context) {
    final visibleMatches = _showAllMatches
        ? widget.recentMatches
        : widget.recentMatches.take(_collapsedMatchCount).toList(
            growable: false,
          );

    if (visibleMatches.isEmpty) {
      return const SectionCard(
        title: 'Recent matches',
        body: 'No recent matches from OpenDota yet.',
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
              _MatchRow(
                match: visibleMatches[index],
                onTap: () => widget.onSelectHero(visibleMatches[index].heroId),
              ),
              if (index < visibleMatches.length - 1) const Divider(height: 24),
            ],
            if (widget.recentMatches.length > _collapsedMatchCount) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    setState(() => _showAllMatches = !_showAllMatches);
                  },
                  child: Text(_showAllMatches ? 'See less' : 'See more'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match, required this.onTap});

  final RecentMatch match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultColor = match.didWin
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.errorContainer;
    final resultLabel = match.didWin ? 'Win' : 'Loss';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
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
                MatchInfoChip(label: 'KDA', value: match.kdaLine),
                MatchInfoChip(
                  label: 'Duration',
                  value: formatMatchDuration(match.duration),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
