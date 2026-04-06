import 'dart:async';

import 'package:dotes/src/features/player_import/application/imported_player_provider.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/training_preferences/application/training_preferences_providers.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:dotes/src/features/training_preferences/domain/repositories/training_preferences_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingPreferencesController', () {
    test(
      'saveForAccount does not overwrite new account state after a switch',
      () async {
        final saveCompleter = Completer<void>();
        final repository = _SlowSaveTrainingPreferencesRepository(
          saveCompleter: saveCompleter,
          storedValues: {
            86745912: const TrainingPreferences(),
            2222: const TrainingPreferences(
              coachingMode: TrainingCoachingMode.preferManualSetup,
              lockedHeroIds: [129],
            ),
          },
        );
        final container = ProviderContainer(
          overrides: [
            trainingPreferencesRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        // Load account A, then start saving a hero block change (in flight)
        container.read(importedPlayerProvider.notifier).state = _importedPlayer(
          accountId: 86745912,
        );
        await container
            .read(trainingPreferencesControllerProvider)
            .loadForAccount(86745912);

        final saveFuture = container
            .read(trainingPreferencesControllerProvider)
            .saveForAccount(
              86745912,
              const TrainingPreferences(
                coachingMode: TrainingCoachingMode.preferManualSetup,
                lockedHeroIds: [53],
              ),
            );

        // Switch to account B while A's save is still in flight
        container.read(importedPlayerProvider.notifier).state = _importedPlayer(
          accountId: 2222,
        );
        container.read(trainingPreferencesControllerProvider).clearSession();
        await container
            .read(trainingPreferencesControllerProvider)
            .loadForAccount(2222);

        // Confirm account B is loaded correctly before A's save completes
        expect(
          container
              .read(currentTrainingPreferencesProvider)
              .normalizedLockedHeroIds,
          [129],
        );

        // Now let account A's save complete
        saveCompleter.complete();
        await saveFuture;

        // Account B's loaded state must still be intact — not overwritten by A's save
        expect(
          container
              .read(currentTrainingPreferencesProvider)
              .normalizedLockedHeroIds,
          [129],
        );
        expect(
          container.read(currentTrainingPreferencesProvider).coachingMode,
          TrainingCoachingMode.preferManualSetup,
        );
      },
    );

    test(
      'saveForAccount updates state normally when account has not changed',
      () async {
        final repository = _SlowSaveTrainingPreferencesRepository(
          saveCompleter: Completer()..complete(),
          storedValues: {},
        );
        final container = ProviderContainer(
          overrides: [
            trainingPreferencesRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        container.read(importedPlayerProvider.notifier).state = _importedPlayer(
          accountId: 86745912,
        );
        await container
            .read(trainingPreferencesControllerProvider)
            .loadForAccount(86745912);

        await container
            .read(trainingPreferencesControllerProvider)
            .saveForAccount(
              86745912,
              const TrainingPreferences(
                coachingMode: TrainingCoachingMode.preferManualSetup,
                lockedHeroIds: [28, 53],
              ),
            );

        expect(
          container
              .read(currentTrainingPreferencesProvider)
              .normalizedLockedHeroIds,
          [28, 53],
        );
        expect(
          container.read(currentTrainingPreferencesProvider).coachingMode,
          TrainingCoachingMode.preferManualSetup,
        );
      },
    );

    test('saveForAccount keeps a per-account coaching note', () async {
      final repository = _SlowSaveTrainingPreferencesRepository(
        saveCompleter: Completer()..complete(),
        storedValues: {},
      );
      final container = ProviderContainer(
        overrides: [
          trainingPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = _importedPlayer(
        accountId: 86745912,
      );
      await container
          .read(trainingPreferencesControllerProvider)
          .loadForAccount(86745912);

      await container
          .read(trainingPreferencesControllerProvider)
          .saveForAccount(
            86745912,
            const TrainingPreferences(
              coachingMode: TrainingCoachingMode.preferManualSetup,
              coachingNote: 'Practice cleaner lane exits.',
            ),
          );

      expect(
        container.read(currentTrainingPreferencesProvider).trimmedCoachingNote,
        'Practice cleaner lane exits.',
      );
    });

    test('saveForAccount keeps a per-account focus priority', () async {
      final repository = _SlowSaveTrainingPreferencesRepository(
        saveCompleter: Completer()..complete(),
        storedValues: {},
      );
      final container = ProviderContainer(
        overrides: [
          trainingPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = _importedPlayer(
        accountId: 86745912,
      );
      await container
          .read(trainingPreferencesControllerProvider)
          .loadForAccount(86745912);

      await container
          .read(trainingPreferencesControllerProvider)
          .saveForAccount(
            86745912,
            const TrainingPreferences(
              coachingMode: TrainingCoachingMode.preferManualSetup,
              focusPriority: TrainingFocusPriority.reduceDeaths,
            ),
          );

      expect(
        container.read(currentTrainingPreferencesProvider).focusPriority,
        TrainingFocusPriority.reduceDeaths,
      );
    });

    test('saveForAccount keeps a per-account coaching style', () async {
      final repository = _SlowSaveTrainingPreferencesRepository(
        saveCompleter: Completer()..complete(),
        storedValues: {},
      );
      final container = ProviderContainer(
        overrides: [
          trainingPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = _importedPlayer(
        accountId: 86745912,
      );
      await container
          .read(trainingPreferencesControllerProvider)
          .loadForAccount(86745912);

      await container
          .read(trainingPreferencesControllerProvider)
          .saveForAccount(
            86745912,
            const TrainingPreferences(
              coachingMode: TrainingCoachingMode.preferManualSetup,
              coachingStyle: TrainingCoachingStyle.steady,
            ),
          );

      expect(
        container.read(currentTrainingPreferencesProvider).coachingStyle,
        TrainingCoachingStyle.steady,
      );
    });

    test('saveForAccount keeps a per-account queue preference', () async {
      final repository = _SlowSaveTrainingPreferencesRepository(
        saveCompleter: Completer()..complete(),
        storedValues: {},
      );
      final container = ProviderContainer(
        overrides: [
          trainingPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = _importedPlayer(
        accountId: 86745912,
      );
      await container
          .read(trainingPreferencesControllerProvider)
          .loadForAccount(86745912);

      await container
          .read(trainingPreferencesControllerProvider)
          .saveForAccount(
            86745912,
            const TrainingPreferences(
              coachingMode: TrainingCoachingMode.preferManualSetup,
              queuePreference: TrainingQueuePreference.partyOnly,
            ),
          );

      expect(
        container.read(currentTrainingPreferencesProvider).queuePreference,
        TrainingQueuePreference.partyOnly,
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

class _SlowSaveTrainingPreferencesRepository
    implements TrainingPreferencesRepository {
  _SlowSaveTrainingPreferencesRepository({
    required this.saveCompleter,
    Map<int, TrainingPreferences>? storedValues,
  }) : _storedValues = Map<int, TrainingPreferences>.from(
         storedValues ?? const {},
       );

  final Completer<void> saveCompleter;
  final Map<int, TrainingPreferences> _storedValues;

  @override
  Future<TrainingPreferences> loadForAccount(int accountId) async {
    return _storedValues[accountId] ?? const TrainingPreferences();
  }

  @override
  Future<void> saveForAccount(
    int accountId,
    TrainingPreferences preferences,
  ) async {
    await saveCompleter.future;
    _storedValues[accountId] = preferences;
  }
}
