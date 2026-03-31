import 'package:dotes/src/features/player_import/application/imported_player_provider.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/training_preferences/application/manual_hero_block_action_providers.dart';
import 'package:dotes/src/features/training_preferences/application/training_preferences_providers.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:dotes/src/features/training_preferences/domain/repositories/training_preferences_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeroTrainingBlockActionController', () {
    test(
      'keeps training block updates isolated to the active account',
      () async {
        final repository = FakeTrainingPreferencesRepository(
          storedValues: {
            86745912: const TrainingPreferences(
              coachingMode: TrainingCoachingMode.preferManualSetup,
              lockedHeroIds: [28],
            ),
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

        container.read(importedPlayerProvider.notifier).state = _importedPlayer(
          accountId: 86745912,
        );
        await container
            .read(trainingPreferencesControllerProvider)
            .loadForAccount(86745912);

        await container
            .read(heroTrainingBlockActionControllerProvider)
            .addHeroToCurrentBlock(53);

        expect(repository.savedValues[86745912]!.normalizedLockedHeroIds, [
          28,
          53,
        ]);
        expect(
          repository.savedValues[86745912]!.coachingMode,
          TrainingCoachingMode.preferManualSetup,
        );
        expect(repository.savedValues[2222]!.normalizedLockedHeroIds, [129]);

        container.read(importedPlayerProvider.notifier).state = _importedPlayer(
          accountId: 2222,
        );
        await container
            .read(trainingPreferencesControllerProvider)
            .loadForAccount(2222);

        expect(
          container
              .read(currentTrainingPreferencesProvider)
              .normalizedLockedHeroIds,
          [129],
        );
      },
    );
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

class FakeTrainingPreferencesRepository
    implements TrainingPreferencesRepository {
  FakeTrainingPreferencesRepository({
    Map<int, TrainingPreferences>? storedValues,
  }) : savedValues = Map<int, TrainingPreferences>.from(
         storedValues ?? const {},
       );

  final Map<int, TrainingPreferences> savedValues;

  @override
  Future<TrainingPreferences> loadForAccount(int accountId) async {
    return savedValues[accountId] ?? const TrainingPreferences();
  }

  @override
  Future<void> saveForAccount(
    int accountId,
    TrainingPreferences preferences,
  ) async {
    savedValues[accountId] = preferences;
  }
}
