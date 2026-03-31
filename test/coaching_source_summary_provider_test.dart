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
  group('coachingSourceSummaryProvider', () {
    test('does not leak manual source state to another account', () async {
      final repository = FakeTrainingPreferencesRepository();
      final container = ProviderContainer(
        overrides: [
          trainingPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = _importedPlayer(
        accountId: 86745912,
      );
      await container.read(trainingPreferencesControllerProvider).saveForAccount(
        86745912,
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          preferredRole: TrainingRolePreference.mid,
          lockedHeroIds: [28],
        ),
      );

      final manualSummary = container.read(coachingSourceSummaryProvider);
      expect(manualSummary, isNotNull);
      expect(manualSummary!.headline, 'Coaching source: Manual setup');

      container.read(importedPlayerProvider.notifier).state = _importedPlayer(
        accountId: 2222,
      );

      final fallbackSummary = container.read(coachingSourceSummaryProvider);
      expect(fallbackSummary, isNotNull);
      expect(fallbackSummary!.headline, 'Coaching source: App read');
      expect(fallbackSummary.detail, 'Using the app read for role and hero block.');
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

class FakeTrainingPreferencesRepository implements TrainingPreferencesRepository {
  final Map<int, TrainingPreferences> _savedValues = {};

  @override
  Future<TrainingPreferences> loadForAccount(int accountId) async {
    return _savedValues[accountId] ?? const TrainingPreferences();
  }

  @override
  Future<void> saveForAccount(
    int accountId,
    TrainingPreferences preferences,
  ) async {
    _savedValues[accountId] = preferences;
  }
}
