import 'package:dotes/src/features/checkpoints/application/coaching_checkpoint_providers.dart';
import 'package:dotes/src/features/checkpoints/domain/services/checkpoint_save_policy_service.dart';
import 'package:dotes/src/features/player_import/application/imported_player_provider.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('checkpointSaveStatusSummaryProvider', () {
    test('returns the mapped status for the active account', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = _importedPlayer(
        accountId: 86745912,
      );
      container
          .read(latestCheckpointSaveDecisionProvider.notifier)
          .state = const CheckpointSaveDecision(
        accountId: 86745912,
        status: CheckpointSaveStatus.skippedNoNewMatches,
        newWindowMatchCount: 0,
        overlapCount: 5,
        blockFingerprint: 'm5|m4|m3|m2|m1',
      );

      final summary = container.read(checkpointSaveStatusSummaryProvider);

      expect(summary, isNotNull);
      expect(summary!.headline, 'No new matches since the last checkpoint.');
    });

    test('hides a stale status from another account', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = _importedPlayer(
        accountId: 2222,
      );
      container
          .read(latestCheckpointSaveDecisionProvider.notifier)
          .state = const CheckpointSaveDecision(
        accountId: 86745912,
        status: CheckpointSaveStatus.saved,
        newWindowMatchCount: 5,
        overlapCount: 0,
        blockFingerprint: 'm5|m4|m3|m2|m1',
      );

      final summary = container.read(checkpointSaveStatusSummaryProvider);

      expect(summary, isNull);
    });
  });
}

ImportedPlayerData _importedPlayer({required int accountId}) {
  return ImportedPlayerData(
    profile: PlayerProfileSummary(
      accountId: accountId,
      personaName: 'Player $accountId',
      avatarUrl: '',
      rankTier: 50,
      leaderboardRank: null,
    ),
    recentMatches: [
      RecentMatch(
        matchId: 9001,
        heroId: 53,
        startedAt: DateTime.utc(2025, 3, 20),
        duration: Duration(minutes: 30),
        kills: 8,
        deaths: 4,
        assists: 10,
        didWin: true,
        partySize: 1,
      ),
    ],
  );
}
