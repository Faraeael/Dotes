import 'package:dotes/src/features/hero_compare/presentation/hero_compare_screen.dart';
import 'package:dotes/src/features/player_import/application/imported_player_provider.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/training_preferences/application/training_preferences_providers.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:dotes/src/features/training_preferences/domain/repositories/training_preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeroCompareScreen actions', () {
    testWidgets('promotes a compared hero into a partial block and switches to manual setup', (
      tester,
    ) async {
      final repository = FakeTrainingPreferencesRepository(
        storedValues: {
          86745912: const TrainingPreferences(lockedHeroIds: [129]),
        },
      );
      final container = ProviderContainer(
        overrides: [
          trainingPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = _importedPlayer();
      await container.read(trainingPreferencesControllerProvider).loadForAccount(86745912);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HeroCompareScreen(primaryHeroId: 129, secondaryHeroId: 28),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mars'), findsWidgets);
      expect(find.text('Current training block'), findsOneWidget);
      expect(find.text('Follow app read'), findsOneWidget);

      await tester.ensureVisible(find.text('Use Slardar in block'));
      await tester.tap(find.text('Use Slardar in block'));
      await tester.pumpAndSettle();

      expect(repository.savedValues[86745912]!.normalizedLockedHeroIds, [129, 28]);
      expect(
        repository.savedValues[86745912]!.coachingMode,
        TrainingCoachingMode.preferManualSetup,
      );
    });

    testWidgets('replaces a hero in a full block from compare', (tester) async {
      final repository = FakeTrainingPreferencesRepository(
        storedValues: {
          86745912: const TrainingPreferences(
            coachingMode: TrainingCoachingMode.preferManualSetup,
            lockedHeroIds: [129, 135],
          ),
        },
      );
      final container = ProviderContainer(
        overrides: [
          trainingPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = _importedPlayer();
      await container.read(trainingPreferencesControllerProvider).loadForAccount(86745912);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HeroCompareScreen(primaryHeroId: 129, secondaryHeroId: 28),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Replace current block hero with Slardar'));
      await tester.tap(find.text('Replace current block hero with Slardar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dawnbreaker'));
      await tester.pumpAndSettle();

      expect(repository.savedValues[86745912]!.normalizedLockedHeroIds, [129, 28]);
    });

    testWidgets('renders current-block hero state clearly', (tester) async {
      final repository = FakeTrainingPreferencesRepository(
        storedValues: {
          86745912: const TrainingPreferences(
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

      container.read(importedPlayerProvider.notifier).state = _importedPlayer();
      await container.read(trainingPreferencesControllerProvider).loadForAccount(86745912);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HeroCompareScreen(primaryHeroId: 129, secondaryHeroId: 28),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mars already in block'), findsOneWidget);
      expect(find.text('Already in block'), findsOneWidget);
      expect(find.text('Mars'), findsWidgets);
    });
  });
}

ImportedPlayerData _importedPlayer() {
  return ImportedPlayerData(
    profile: const PlayerProfileSummary(
      accountId: 86745912,
      personaName: 'Compare Player',
      avatarUrl: '',
      rankTier: 50,
      leaderboardRank: null,
    ),
    recentMatches: [
      _match(1, 129, true, 1, deaths: 4),
      _match(2, 129, true, 2, deaths: 5),
      _match(3, 129, false, 3, deaths: 4),
      _match(4, 28, true, 4, deaths: 3),
      _match(5, 28, true, 5, deaths: 4),
      _match(6, 28, false, 6, deaths: 5),
      _match(7, 135, true, 7, deaths: 4),
      _match(8, 135, true, 8, deaths: 4),
    ],
  );
}

RecentMatch _match(
  int matchId,
  int heroId,
  bool didWin,
  int daysAgo, {
  required int deaths,
}) {
  return RecentMatch(
    matchId: matchId,
    heroId: heroId,
    startedAt: DateTime(2026, 4, 1, 18).subtract(Duration(days: daysAgo)),
    duration: const Duration(minutes: 34),
    kills: 6,
    deaths: deaths,
    assists: 8,
    didWin: didWin,
    goldPerMin: 450,
    xpPerMin: 520,
    lastHits: 120,
    laneRole: 3,
    partySize: 1,
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
