import 'dart:async';

import 'package:dotes/src/features/player_import/application/imported_player_provider.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/tester_feedback/application/tester_feedback_providers.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback_record.dart';
import 'package:dotes/src/features/tester_feedback/domain/repositories/tester_feedback_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TesterFeedbackController', () {
    test('saveForAccount does not overwrite new account state after a switch',
        () async {
      final saveCompleter = Completer<void>();
      const accountBFeedback = TesterFeedback(
        rating: TesterFeedbackRating.clear,
        note: 'Account B feedback note.',
      );
      final repository = _SlowSaveTesterFeedbackRepository(
        saveCompleter: saveCompleter,
        storedValues: {
          2222: accountBFeedback,
        },
      );
      final container = ProviderContainer(
        overrides: [
          testerFeedbackRepositoryProvider.overrideWithValue(repository),
          testerFeedbackClockProvider.overrideWithValue(
            () => DateTime.utc(2026, 4, 1, 12),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Load account A, then start saving feedback (in flight)
      container.read(importedPlayerProvider.notifier).state =
          _importedPlayer(accountId: 86745912);
      await container
          .read(testerFeedbackControllerProvider)
          .loadForAccount(86745912);

      final saveFuture = container
          .read(testerFeedbackControllerProvider)
          .saveForAccount(
            86745912,
            const TesterFeedback(
              rating: TesterFeedbackRating.confusing,
              note: 'Account A feedback — should not bleed into B.',
            ),
          );

      // Switch to account B while A's save is still in flight
      container.read(importedPlayerProvider.notifier).state =
          _importedPlayer(accountId: 2222);
      container.read(testerFeedbackControllerProvider).clearSession();
      await container
          .read(testerFeedbackControllerProvider)
          .loadForAccount(2222);

      // Account B feedback loaded correctly before A's save completes
      expect(
        container.read(currentTesterFeedbackProvider)?.trimmedNote,
        'Account B feedback note.',
      );

      // Complete account A's save
      saveCompleter.complete();
      await saveFuture;

      // Account B's loaded state must remain intact
      expect(
        container.read(currentTesterFeedbackProvider)?.trimmedNote,
        'Account B feedback note.',
      );
      expect(
        container.read(currentTesterFeedbackProvider)?.rating,
        TesterFeedbackRating.clear,
      );
    });

    test('saveForAccount updates state normally when account has not changed',
        () async {
      final repository = _SlowSaveTesterFeedbackRepository(
        saveCompleter: Completer()..complete(),
        storedValues: {},
      );
      final container = ProviderContainer(
        overrides: [
          testerFeedbackRepositoryProvider.overrideWithValue(repository),
          testerFeedbackClockProvider.overrideWithValue(
            () => DateTime.utc(2026, 4, 1, 12),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state =
          _importedPlayer(accountId: 86745912);
      await container
          .read(testerFeedbackControllerProvider)
          .loadForAccount(86745912);

      await container
          .read(testerFeedbackControllerProvider)
          .saveForAccount(
            86745912,
            const TesterFeedback(
              rating: TesterFeedbackRating.clear,
              note: 'All good.',
            ),
          );

      expect(
        container.read(currentTesterFeedbackProvider)?.trimmedNote,
        'All good.',
      );
      expect(
        container.read(currentTesterFeedbackProvider)?.rating,
        TesterFeedbackRating.clear,
      );
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
        duration: const Duration(minutes: 30),
        kills: 8,
        deaths: 4,
        assists: 10,
        didWin: true,
        partySize: 1,
      ),
    ],
  );
}

class _SlowSaveTesterFeedbackRepository implements TesterFeedbackRepository {
  _SlowSaveTesterFeedbackRepository({
    required this.saveCompleter,
    Map<int, TesterFeedback>? storedValues,
  }) : _storedValues = Map<int, TesterFeedback>.from(
          storedValues ?? const {},
        );

  final Completer<void> saveCompleter;
  final Map<int, TesterFeedback> _storedValues;

  @override
  Future<TesterFeedback?> loadForAccount(int accountId) async {
    return _storedValues[accountId];
  }

  @override
  Future<List<TesterFeedbackRecord>> loadAll() async {
    return [
      for (final entry in _storedValues.entries)
        TesterFeedbackRecord(accountId: entry.key, feedback: entry.value),
    ];
  }

  @override
  Future<void> saveForAccount(int accountId, TesterFeedback feedback) async {
    await saveCompleter.future;
    _storedValues[accountId] = feedback;
  }
}
