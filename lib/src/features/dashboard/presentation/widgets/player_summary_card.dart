import 'package:flutter/material.dart';

import '../../../player_import/domain/models/player_profile_summary.dart';
import 'section_card.dart';

class PlayerSummaryCard extends StatelessWidget {
  const PlayerSummaryCard({
    required this.profile,
    super.key,
  });

  final PlayerProfileSummary profile;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      'Account ID: ${profile.accountId}',
      if (profile.rankTier != null) 'Rank tier: ${profile.rankTier}',
      if (profile.leaderboardRank != null)
        'Leaderboard rank: #${profile.leaderboardRank}',
      if (profile.realName case final realName?) 'Steam name: $realName',
    ];

    return SectionCard(
      title: profile.displayName,
      body: details.join('\n'),
      leading: profile.avatarUrl.isEmpty
          ? const CircleAvatar(child: Icon(Icons.person_outline))
          : CircleAvatar(
              backgroundImage: NetworkImage(profile.avatarUrl),
            ),
    );
  }
}
