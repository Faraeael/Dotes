import 'dart:async';

import 'package:dotes/src/core/failures/app_failure.dart';
import 'package:dotes/src/core/result/result.dart';
import 'package:dotes/src/features/checkpoints/application/coaching_checkpoint_providers.dart';
import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/checkpoints/domain/repositories/coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/player_import/application/imported_player_provider.dart';
import 'package:dotes/src/features/player_import/application/player_import_controller.dart';
import 'package:dotes/src/features/player_import/application/saved_accounts_providers.dart';
import 'package:dotes/src/features/player_import/data/repositories/opendota_player_repository.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/player_import/domain/models/saved_account_entry.dart';
import 'package:dotes/src/features/player_import/domain/repositories/player_import_repository.dart';
import 'package:dotes/src/features/player_import/domain/repositories/saved_account_repository.dart';
import 'package:dotes/src/features/dashboard/application/saved_block_summary_providers.dart';
import 'package:dotes/src/features/dashboard/domain/models/saved_block_summary.dart';
import 'package:dotes/src/features/dashboard/domain/repositories/saved_block_summary_repository.dart';
import 'package:dotes/src/features/tester_feedback/application/tester_feedback_providers.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback_record.dart';
import 'package:dotes/src/features/tester_feedback/domain/repositories/tester_feedback_repository.dart';
import 'package:dotes/src/features/training_preferences/application/training_preferences_providers.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:dotes/src/features/training_preferences/domain/repositories/training_preferences_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('PlayerImportController', () {
    test('stores imported player data only after full success', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile()),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final testerFeedbackRepository = FakeTesterFeedbackRepository();
      final trainingPreferencesRepository = FakeTrainingPreferencesRepository();
      final savedAccountRepository = FakeSavedAccountRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
          testerFeedbackRepositoryProvider.overrideWithValue(
            testerFeedbackRepository,
          ),
          trainingPreferencesRepositoryProvider.overrideWithValue(
            trainingPreferencesRepository,
          ),

          savedBlockSummaryRepositoryProvider.overrideWithValue(
            FakeSavedBlockSummaryRepository(),
          ),
          savedAccountRepositoryProvider.overrideWithValue(
            savedAccountRepository,
          ),
          savedAccountsClockProvider.overrideWithValue(
            () => DateTime.utc(2026, 4, 1, 12),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        playerImportControllerProvider.notifier,
      );

      controller.updatePlayerId(' 86745912 ');
      final success = await controller.submit();

      expect(success, isTrue);
      expect(
        container.read(playerImportControllerProvider).playerId,
        '86745912',
      );

      final importedPlayer = container.read(importedPlayerProvider);
      expect(importedPlayer, isNotNull);
      expect(importedPlayer!.profile.accountId, 86745912);
      expect(importedPlayer.recentMatches, hasLength(1));
      expect(savedAccountRepository.entries, hasLength(1));
      expect(savedAccountRepository.entries.single.accountId, 86745912);
      expect(
        savedAccountRepository.entries.single.displayName,
        'Week 1 Player',
      );
    });

    test('rejects account IDs that are too short', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile()),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final testerFeedbackRepository = FakeTesterFeedbackRepository();
      final trainingPreferencesRepository = FakeTrainingPreferencesRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
          testerFeedbackRepositoryProvider.overrideWithValue(
            testerFeedbackRepository,
          ),
          trainingPreferencesRepositoryProvider.overrideWithValue(
            trainingPreferencesRepository,
          ),

          savedBlockSummaryRepositoryProvider.overrideWithValue(
            FakeSavedBlockSummaryRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        playerImportControllerProvider.notifier,
      );

      controller.updatePlayerId('123');
      final success = await controller.submit();

      expect(success, isFalse);
      expect(
        container.read(playerImportControllerProvider).errorMessage,
        'That account ID looks too short. Enter at least 4 digits.',
      );
      expect(repository.profileCalls, 0);
      expect(repository.recentMatchesCalls, 0);
    });

    test('clears stale imported data on validation failure', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile()),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final testerFeedbackRepository = FakeTesterFeedbackRepository();
      final trainingPreferencesRepository = FakeTrainingPreferencesRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
          testerFeedbackRepositoryProvider.overrideWithValue(
            testerFeedbackRepository,
          ),
          trainingPreferencesRepositoryProvider.overrideWithValue(
            trainingPreferencesRepository,
          ),

          savedBlockSummaryRepositoryProvider.overrideWithValue(
            FakeSavedBlockSummaryRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state =
          ImportedPlayerData(profile: _profile(), recentMatches: [_match()]);

      final controller = container.read(
        playerImportControllerProvider.notifier,
      );

      controller.updatePlayerId('   ');
      final success = await controller.submit();

      expect(success, isFalse);
      expect(container.read(importedPlayerProvider), isNull);
      expect(
        container.read(playerImportControllerProvider).errorMessage,
        'Enter the numeric account ID from the player profile you want to review.',
      );
      expect(repository.profileCalls, 0);
      expect(repository.recentMatchesCalls, 0);
    });

    test(
      'clears stale imported data when recent matches request fails',
      () async {
        final repository = FakePlayerImportRepository(
          profileResult: Success(_profile()),
          recentMatchesResult: const Failure(
            AppFailure(
              type: AppFailureType.network,
              message:
                  'No internet connection detected, or OpenDota could not be reached.',
            ),
          ),
        );
        final checkpointRepository = FakeCoachingCheckpointRepository();
        final testerFeedbackRepository = FakeTesterFeedbackRepository();
        final trainingPreferencesRepository =
            FakeTrainingPreferencesRepository();
        final container = ProviderContainer(
          overrides: [
            playerImportRepositoryProvider.overrideWithValue(repository),
            coachingCheckpointRepositoryProvider.overrideWithValue(
              checkpointRepository,
            ),
            testerFeedbackRepositoryProvider.overrideWithValue(
              testerFeedbackRepository,
            ),
            trainingPreferencesRepositoryProvider.overrideWithValue(
              trainingPreferencesRepository,
            ),

            savedBlockSummaryRepositoryProvider.overrideWithValue(
              FakeSavedBlockSummaryRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);

        container
            .read(importedPlayerProvider.notifier)
            .state = ImportedPlayerData(
          profile: _profile(accountId: 1),
          recentMatches: [_match(matchId: 1)],
        );

        final controller = container.read(
          playerImportControllerProvider.notifier,
        );

        controller.updatePlayerId('86745912');
        final success = await controller.submit();

        expect(success, isFalse);
        expect(container.read(importedPlayerProvider), isNull);
        expect(repository.profileCalls, 1);
        expect(repository.recentMatchesCalls, 1);
      },
    );

    test(
      'ignores duplicate submits while a request is already in flight',
      () async {
        final profileCompleter = Completer<Result<PlayerProfileSummary>>();
        final repository = FakePlayerImportRepository(
          profileResultFactory: () => profileCompleter.future,
          recentMatchesResult: Success([_match()]),
        );
        final checkpointRepository = FakeCoachingCheckpointRepository();
        final testerFeedbackRepository = FakeTesterFeedbackRepository();
        final trainingPreferencesRepository =
            FakeTrainingPreferencesRepository();
        final container = ProviderContainer(
          overrides: [
            playerImportRepositoryProvider.overrideWithValue(repository),
            coachingCheckpointRepositoryProvider.overrideWithValue(
              checkpointRepository,
            ),
            testerFeedbackRepositoryProvider.overrideWithValue(
              testerFeedbackRepository,
            ),
            trainingPreferencesRepositoryProvider.overrideWithValue(
              trainingPreferencesRepository,
            ),

            savedBlockSummaryRepositoryProvider.overrideWithValue(
              FakeSavedBlockSummaryRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          playerImportControllerProvider.notifier,
        );

        controller.updatePlayerId('86745912');

        final firstSubmit = controller.submit();
        final secondSubmit = await controller.submit();

        expect(secondSubmit, isFalse);
        expect(
          container.read(playerImportControllerProvider).isSubmitting,
          isTrue,
        );
        expect(repository.profileCalls, 1);

        profileCompleter.complete(Success(_profile()));

        expect(await firstSubmit, isTrue);
        expect(repository.profileCalls, 1);
        expect(repository.recentMatchesCalls, 1);
      },
    );

    test(
      'loads no previous checkpoint on first import for an account',
      () async {
        final repository = FakePlayerImportRepository(
          profileResult: Success(_profile()),
          recentMatchesResult: Success([_match()]),
        );
        final checkpointRepository = FakeCoachingCheckpointRepository();
        final testerFeedbackRepository = FakeTesterFeedbackRepository();
        final trainingPreferencesRepository =
            FakeTrainingPreferencesRepository();
        final container = ProviderContainer(
          overrides: [
            playerImportRepositoryProvider.overrideWithValue(repository),
            coachingCheckpointRepositoryProvider.overrideWithValue(
              checkpointRepository,
            ),
            testerFeedbackRepositoryProvider.overrideWithValue(
              testerFeedbackRepository,
            ),
            trainingPreferencesRepositoryProvider.overrideWithValue(
              trainingPreferencesRepository,
            ),

            savedBlockSummaryRepositoryProvider.overrideWithValue(
              FakeSavedBlockSummaryRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          playerImportControllerProvider.notifier,
        );

        controller.updatePlayerId('86745912');
        final success = await controller.submit();

        expect(success, isTrue);
        expect(container.read(previousCoachingCheckpointProvider), isNull);
        expect(checkpointRepository.loadCalls, [86745912]);
      },
    );

    test(
      'loads the previous checkpoint for the same account on import',
      () async {
        final repository = FakePlayerImportRepository(
          profileResult: Success(_profile()),
          recentMatchesResult: Success([_match()]),
        );
        final checkpoint = _checkpoint(accountId: 86745912);
        final checkpointRepository = FakeCoachingCheckpointRepository(
          storedCheckpoints: {86745912: checkpoint},
        );
        final testerFeedbackRepository = FakeTesterFeedbackRepository();
        final trainingPreferencesRepository =
            FakeTrainingPreferencesRepository();
        final container = ProviderContainer(
          overrides: [
            playerImportRepositoryProvider.overrideWithValue(repository),
            coachingCheckpointRepositoryProvider.overrideWithValue(
              checkpointRepository,
            ),
            testerFeedbackRepositoryProvider.overrideWithValue(
              testerFeedbackRepository,
            ),
            trainingPreferencesRepositoryProvider.overrideWithValue(
              trainingPreferencesRepository,
            ),

            savedBlockSummaryRepositoryProvider.overrideWithValue(
              FakeSavedBlockSummaryRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          playerImportControllerProvider.notifier,
        );

        controller.updatePlayerId('86745912');
        final success = await controller.submit();

        expect(success, isTrue);
        expect(
          container.read(previousCoachingCheckpointProvider)?.focusAction,
          checkpoint.focusAction,
        );
        expect(checkpointRepository.loadCalls, [86745912]);
      },
    );

    test('does not reuse another player checkpoint on import', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile(accountId: 2222)),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository(
        storedCheckpoints: {86745912: _checkpoint(accountId: 86745912)},
      );
      final testerFeedbackRepository = FakeTesterFeedbackRepository();
      final trainingPreferencesRepository = FakeTrainingPreferencesRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
          testerFeedbackRepositoryProvider.overrideWithValue(
            testerFeedbackRepository,
          ),
          trainingPreferencesRepositoryProvider.overrideWithValue(
            trainingPreferencesRepository,
          ),

          savedBlockSummaryRepositoryProvider.overrideWithValue(
            FakeSavedBlockSummaryRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        playerImportControllerProvider.notifier,
      );

      controller.updatePlayerId('2222');
      final success = await controller.submit();

      expect(success, isTrue);
      expect(container.read(previousCoachingCheckpointProvider), isNull);
      expect(checkpointRepository.loadCalls, [2222]);
    });

    test('loads saved tester feedback for the imported account', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile()),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final testerFeedbackRepository = FakeTesterFeedbackRepository(
        storedFeedback: {
          86745912: const TesterFeedback(
            rating: TesterFeedbackRating.clear,
            note: 'The coaching loop felt easy to follow.',
          ),
        },
      );
      final trainingPreferencesRepository = FakeTrainingPreferencesRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
          testerFeedbackRepositoryProvider.overrideWithValue(
            testerFeedbackRepository,
          ),
          trainingPreferencesRepositoryProvider.overrideWithValue(
            trainingPreferencesRepository,
          ),

          savedBlockSummaryRepositoryProvider.overrideWithValue(
            FakeSavedBlockSummaryRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        playerImportControllerProvider.notifier,
      );

      controller.updatePlayerId('86745912');
      final success = await controller.submit();

      expect(success, isTrue);
      expect(
        container.read(currentTesterFeedbackProvider)?.trimmedNote,
        'The coaching loop felt easy to follow.',
      );
    });

    test('does not reuse another player feedback on import', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile(accountId: 2222)),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final testerFeedbackRepository = FakeTesterFeedbackRepository(
        storedFeedback: {
          86745912: const TesterFeedback(
            rating: TesterFeedbackRating.confusing,
            note: 'This should stay with the first account only.',
          ),
        },
      );
      final trainingPreferencesRepository = FakeTrainingPreferencesRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
          testerFeedbackRepositoryProvider.overrideWithValue(
            testerFeedbackRepository,
          ),
          trainingPreferencesRepositoryProvider.overrideWithValue(
            trainingPreferencesRepository,
          ),

          savedBlockSummaryRepositoryProvider.overrideWithValue(
            FakeSavedBlockSummaryRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        playerImportControllerProvider.notifier,
      );

      controller.updatePlayerId('2222');
      final success = await controller.submit();

      expect(success, isTrue);
      expect(container.read(currentTesterFeedbackProvider), isNull);
    });

    test('loads a seeded demo scenario into imported state', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile()),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final testerFeedbackRepository = FakeTesterFeedbackRepository();
      final trainingPreferencesRepository = FakeTrainingPreferencesRepository();
      final savedAccountRepository = FakeSavedAccountRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
          testerFeedbackRepositoryProvider.overrideWithValue(
            testerFeedbackRepository,
          ),
          trainingPreferencesRepositoryProvider.overrideWithValue(
            trainingPreferencesRepository,
          ),

          savedBlockSummaryRepositoryProvider.overrideWithValue(
            FakeSavedBlockSummaryRepository(),
          ),
          savedAccountRepositoryProvider.overrideWithValue(
            savedAccountRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        playerImportControllerProvider.notifier,
      );
      final scenario = container
          .read(demoPlayerScenariosProvider)
          .firstWhere((item) => item.id == 'completed_on_track_block');

      final success = await controller.importDemoScenario(scenario);

      expect(success, isTrue);
      final importedPlayer = container.read(importedPlayerProvider);
      expect(importedPlayer, isNotNull);
      expect(importedPlayer!.source.isDemo, isTrue);
      expect(importedPlayer.source.scenarioLabel, 'Completed on-track block');
      expect(
        container.read(previousCoachingCheckpointProvider)?.savedSessionPlan,
        isNotNull,
      );
      expect(container.read(coachingCheckpointHistoryProvider), hasLength(2));
      expect(
        container.read(currentTrainingPreferencesProvider).activeLockedHeroIds,
        [28, 129],
      );
      expect(
        container.read(currentTesterFeedbackProvider)?.trimmedNote,
        contains('on-track review'),
      );
      expect(checkpointRepository.loadCalls, isEmpty);
      expect(repository.profileCalls, 0);
      expect(repository.recentMatchesCalls, 0);
    });

    test('demo state stays isolated from real imported accounts', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile(accountId: 86745912)),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository(
        storedCheckpoints: {86745912: _checkpoint(accountId: 86745912)},
      );
      final testerFeedbackRepository = FakeTesterFeedbackRepository(
        storedFeedback: {
          86745912: const TesterFeedback(
            rating: TesterFeedbackRating.clear,
            note: 'Real account feedback',
          ),
        },
      );
      final trainingPreferencesRepository = FakeTrainingPreferencesRepository(
        storedPreferences: {
          86745912: const TrainingPreferences(
            coachingMode: TrainingCoachingMode.preferManualSetup,
            preferredRole: TrainingRolePreference.carry,
            lockedHeroIds: [8, 48],
          ),
        },
      );
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
          testerFeedbackRepositoryProvider.overrideWithValue(
            testerFeedbackRepository,
          ),
          trainingPreferencesRepositoryProvider.overrideWithValue(
            trainingPreferencesRepository,
          ),

          savedBlockSummaryRepositoryProvider.overrideWithValue(
            FakeSavedBlockSummaryRepository(),
          ),
          savedAccountRepositoryProvider.overrideWithValue(
            FakeSavedAccountRepository(),
          ),
          savedAccountsClockProvider.overrideWithValue(
            () => DateTime.utc(2026, 4, 1, 12),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        playerImportControllerProvider.notifier,
      );
      final demoScenario = container
          .read(demoPlayerScenariosProvider)
          .firstWhere((item) => item.id == 'completed_off_track_block');

      expect(await controller.importDemoScenario(demoScenario), isTrue);
      expect(
        container.read(importedPlayerProvider)?.profile.accountId,
        demoScenario.importedPlayer.profile.accountId,
      );
      expect(
        container.read(currentTesterFeedbackProvider)?.trimmedNote,
        contains('drift outside the block'),
      );
      expect(
        container.read(currentTrainingPreferencesProvider).activeLockedHeroIds,
        [28, 129],
      );

      controller.updatePlayerId('86745912');
      expect(await controller.submit(), isTrue);

      expect(
        container.read(importedPlayerProvider)?.profile.accountId,
        86745912,
      );
      expect(
        container.read(currentTesterFeedbackProvider)?.trimmedNote,
        'Real account feedback',
      );
      expect(
        container.read(currentTrainingPreferencesProvider).activeLockedHeroIds,
        [8, 48],
      );
      expect(
        container.read(previousCoachingCheckpointProvider)?.accountId,
        86745912,
      );
      expect(repository.profileCalls, 1);
      expect(repository.recentMatchesCalls, 1);
    });

    test(
      'reopens a saved account and refreshes the last-opened order',
      () async {
        final repository = FakePlayerImportRepository(
          profileResult: Success(_profile(accountId: 2222)),
          recentMatchesResult: Success([_match()]),
        );
        final savedAccountRepository = FakeSavedAccountRepository(
          initialEntries: [
            SavedAccountEntry(
              accountId: 86745912,
              displayName: 'Week 1 Player',
              sourceType: SavedAccountSourceType.real,
              lastOpenedAt: DateTime.utc(2026, 3, 31, 12),
            ),
            SavedAccountEntry(
              accountId: 2222,
              displayName: 'Offlane Player',
              sourceType: SavedAccountSourceType.real,
              lastOpenedAt: DateTime.utc(2026, 3, 30, 12),
            ),
          ],
        );
        final container = ProviderContainer(
          overrides: [
            playerImportRepositoryProvider.overrideWithValue(repository),
            coachingCheckpointRepositoryProvider.overrideWithValue(
              FakeCoachingCheckpointRepository(),
            ),
            testerFeedbackRepositoryProvider.overrideWithValue(
              FakeTesterFeedbackRepository(),
            ),
            trainingPreferencesRepositoryProvider.overrideWithValue(
              FakeTrainingPreferencesRepository(),
            ),
            savedBlockSummaryRepositoryProvider.overrideWithValue(
              FakeSavedBlockSummaryRepository(),
            ),
            savedAccountRepositoryProvider.overrideWithValue(
              savedAccountRepository,
            ),
            savedAccountsClockProvider.overrideWithValue(
              () => DateTime.utc(2026, 4, 1, 18),
            ),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          playerImportControllerProvider.notifier,
        );
        final savedAccount = savedAccountRepository.entries.last;

        expect(await controller.submitSavedAccount(savedAccount), isTrue);
        expect(container.read(importedPlayerProvider)?.profile.accountId, 2222);
        expect(container.read(lastOpenedSavedAccountProvider)?.accountId, 2222);
        expect(savedAccountRepository.entries.first.accountId, 2222);
        expect(
          savedAccountRepository.entries.first.displayName,
          'Week 1 Player',
        );
      },
    );
  });
}

class FakePlayerImportRepository implements PlayerImportRepository {
  FakePlayerImportRepository({
    this.profileResult,
    this.recentMatchesResult,
    this.profileResultFactory,
    this.recentMatchesResultFactory,
  });

  final Result<PlayerProfileSummary>? profileResult;
  final Result<List<RecentMatch>>? recentMatchesResult;
  final Future<Result<PlayerProfileSummary>> Function()? profileResultFactory;
  final Future<Result<List<RecentMatch>>> Function()?
  recentMatchesResultFactory;

  int profileCalls = 0;
  int recentMatchesCalls = 0;

  @override
  Future<Result<PlayerProfileSummary>> fetchPlayerProfileSummary(
    String accountId,
  ) async {
    profileCalls++;
    if (profileResultFactory != null) {
      return profileResultFactory!.call();
    }

    return profileResult!;
  }

  @override
  Future<Result<List<RecentMatch>>> fetchRecentMatches(String accountId) async {
    recentMatchesCalls++;
    if (recentMatchesResultFactory != null) {
      return recentMatchesResultFactory!.call();
    }

    return recentMatchesResult!;
  }
}

class FakeCoachingCheckpointRepository implements CoachingCheckpointRepository {
  FakeCoachingCheckpointRepository({
    Map<int, CoachingCheckpoint>? storedCheckpoints,
  }) : _storedCheckpoints = {
         for (final entry in (storedCheckpoints ?? {}).entries)
           entry.key: [entry.value],
       };

  final Map<int, List<CoachingCheckpoint>> _storedCheckpoints;

  final List<int> loadCalls = [];
  final List<CoachingCheckpointDraft> savedDrafts = [];

  @override
  Future<CoachingCheckpoint?> loadForAccount(int accountId) async {
    loadCalls.add(accountId);
    final history = _storedCheckpoints[accountId];
    if (history == null || history.isEmpty) {
      return null;
    }

    return history.first;
  }

  @override
  Future<List<CoachingCheckpoint>> loadHistoryForAccount(int accountId) async {
    loadCalls.add(accountId);
    return (_storedCheckpoints[accountId] ?? const []).toList(growable: false);
  }

  @override
  Future<CoachingCheckpoint> saveDraft(CoachingCheckpointDraft draft) async {
    savedDrafts.add(draft);
    final checkpoint = draft.toCheckpoint(DateTime.utc(2025, 3, 21));
    _storedCheckpoints.update(
      draft.accountId,
      (history) => [checkpoint, ...history],
      ifAbsent: () => [checkpoint],
    );
    return checkpoint;
  }
}

class FakeTrainingPreferencesRepository
    implements TrainingPreferencesRepository {
  FakeTrainingPreferencesRepository({
    Map<int, TrainingPreferences>? storedPreferences,
  }) : _storedPreferences = Map<int, TrainingPreferences>.from(
         storedPreferences ?? const {},
       );

  final Map<int, TrainingPreferences> _storedPreferences;

  @override
  Future<TrainingPreferences> loadForAccount(int accountId) async {
    return _storedPreferences[accountId] ?? const TrainingPreferences();
  }

  @override
  Future<void> saveForAccount(
    int accountId,
    TrainingPreferences preferences,
  ) async {
    _storedPreferences[accountId] = preferences;
  }
}

class FakeSavedAccountRepository implements SavedAccountRepository {
  FakeSavedAccountRepository({List<SavedAccountEntry>? initialEntries})
    : entries = [...?initialEntries];

  List<SavedAccountEntry> entries;

  @override
  Future<List<SavedAccountEntry>> loadAll() async {
    return [...entries];
  }

  @override
  Future<void> remove(int accountId) async {
    entries = entries.where((entry) => entry.accountId != accountId).toList();
  }

  @override
  Future<void> saveEntry(SavedAccountEntry entry) async {
    final index = entries.indexWhere(
      (candidate) => candidate.accountId == entry.accountId,
    );
    if (index >= 0) {
      final isPinned = entries[index].isPinned;
      entries[index] = entry.copyWith(isPinned: isPinned);
    } else {
      entries.add(entry);
    }
    entries.sort(
      (left, right) => right.lastOpenedAt.compareTo(left.lastOpenedAt),
    );
  }

  @override
  Future<void> setPinnedAccount(int? accountId) async {
    entries = [
      for (final entry in entries)
        entry.copyWith(
          isPinned: accountId != null && entry.accountId == accountId,
        ),
    ];
  }
}

class FakeSavedBlockSummaryRepository implements SavedBlockSummaryRepository {
  final Map<int, List<SavedBlockSummary>> _summariesByAccount = {};

  @override
  Future<List<SavedBlockSummary>> loadForAccount(int accountId) async {
    return (_summariesByAccount[accountId] ?? const []).toList(growable: false);
  }

  @override
  Future<void> saveForAccount(int accountId, SavedBlockSummary summary) async {
    final existing = _summariesByAccount[accountId] ?? const [];
    if (existing.any((entry) => entry.shareText == summary.shareText)) {
      return;
    }

    _summariesByAccount[accountId] = [summary, ...existing];
  }
}

class FakeTesterFeedbackRepository implements TesterFeedbackRepository {
  FakeTesterFeedbackRepository({Map<int, TesterFeedback>? storedFeedback})
    : _storedFeedback = Map<int, TesterFeedback>.from(
        storedFeedback ?? const {},
      );

  final Map<int, TesterFeedback> _storedFeedback;

  @override
  Future<TesterFeedback?> loadForAccount(int accountId) async {
    return _storedFeedback[accountId];
  }

  @override
  Future<List<TesterFeedbackRecord>> loadAll() async {
    return [
      for (final entry in _storedFeedback.entries)
        TesterFeedbackRecord(accountId: entry.key, feedback: entry.value),
    ];
  }

  @override
  Future<void> saveForAccount(int accountId, TesterFeedback feedback) async {
    _storedFeedback[accountId] = feedback;
  }
}

PlayerProfileSummary _profile({int accountId = 86745912}) {
  return PlayerProfileSummary(
    accountId: accountId,
    personaName: 'Week 1 Player',
    avatarUrl: '',
    rankTier: 50,
    leaderboardRank: null,
  );
}

RecentMatch _match({int matchId = 8221177334}) {
  return RecentMatch(
    matchId: matchId,
    heroId: 53,
    startedAt: DateTime(2025, 3, 20),
    duration: const Duration(minutes: 28, seconds: 22),
    kills: 8,
    deaths: 4,
    assists: 19,
    didWin: true,
    partySize: 1,
  );
}

CoachingCheckpoint _checkpoint({required int accountId}) {
  return CoachingCheckpoint(
    accountId: accountId,
    savedAt: DateTime.utc(2025, 3, 21),
    focusAction: 'Play the next 5 games on one role and no more than 2 heroes.',
    focusSourceLabel: 'Weak recent trend',
    topInsightType: null,
    sample: const CoachingCheckpointSample(
      matchesAnalyzed: 10,
      wins: 4,
      losses: 6,
      winRate: 0.4,
      uniqueHeroesPlayed: 5,
      averageDeaths: 6.8,
      likelyRoleSummaryLabel: 'Core role leaning',
      roleEstimateStrengthLabel: 'Moderate estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'carry',
    ),
  );
}
