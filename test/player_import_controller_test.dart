import 'dart:async';

import 'package:dotes/src/core/failures/app_failure.dart';
import 'package:dotes/src/core/result/result.dart';
import 'package:dotes/src/features/checkpoints/application/coaching_checkpoint_providers.dart';
import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/checkpoints/domain/repositories/coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/player_import/application/imported_player_provider.dart';
import 'package:dotes/src/features/player_import/application/player_import_controller.dart';
import 'package:dotes/src/features/player_import/data/repositories/opendota_player_repository.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/player_import/domain/repositories/player_import_repository.dart';
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
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
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
      expect(container.read(playerImportControllerProvider).playerId, '86745912');

      final importedPlayer = container.read(importedPlayerProvider);
      expect(importedPlayer, isNotNull);
      expect(importedPlayer!.profile.accountId, 86745912);
      expect(importedPlayer.recentMatches, hasLength(1));
    });

    test('clears stale imported data on validation failure', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile()),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = ImportedPlayerData(
        profile: _profile(),
        recentMatches: [_match()],
      );

      final controller = container.read(
        playerImportControllerProvider.notifier,
      );

      controller.updatePlayerId('   ');
      final success = await controller.submit();

      expect(success, isFalse);
      expect(container.read(importedPlayerProvider), isNull);
      expect(
        container.read(playerImportControllerProvider).errorMessage,
        'Enter a player or account ID to continue.',
      );
      expect(repository.profileCalls, 0);
      expect(repository.recentMatchesCalls, 0);
    });

    test('clears stale imported data when recent matches request fails', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile()),
        recentMatchesResult: const Failure(
          AppFailure(
            type: AppFailureType.network,
            message: 'No internet connection detected, or OpenDota could not be reached.',
          ),
        ),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(importedPlayerProvider.notifier).state = ImportedPlayerData(
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
    });

    test('ignores duplicate submits while a request is already in flight', () async {
      final profileCompleter = Completer<Result<PlayerProfileSummary>>();
      final repository = FakePlayerImportRepository(
        profileResultFactory: () => profileCompleter.future,
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
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
      expect(container.read(playerImportControllerProvider).isSubmitting, isTrue);
      expect(repository.profileCalls, 1);

      profileCompleter.complete(Success(_profile()));

      expect(await firstSubmit, isTrue);
      expect(repository.profileCalls, 1);
      expect(repository.recentMatchesCalls, 1);
    });

    test('loads no previous checkpoint on first import for an account', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile()),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository();
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(playerImportControllerProvider.notifier);

      controller.updatePlayerId('86745912');
      final success = await controller.submit();

      expect(success, isTrue);
      expect(container.read(previousCoachingCheckpointProvider), isNull);
      expect(checkpointRepository.loadCalls, [86745912]);
    });

    test('loads the previous checkpoint for the same account on import', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile()),
        recentMatchesResult: Success([_match()]),
      );
      final checkpoint = _checkpoint(accountId: 86745912);
      final checkpointRepository = FakeCoachingCheckpointRepository(
        storedCheckpoints: {86745912: checkpoint},
      );
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(playerImportControllerProvider.notifier);

      controller.updatePlayerId('86745912');
      final success = await controller.submit();

      expect(success, isTrue);
      expect(
        container.read(previousCoachingCheckpointProvider)?.focusAction,
        checkpoint.focusAction,
      );
      expect(checkpointRepository.loadCalls, [86745912]);
    });

    test('does not reuse another player checkpoint on import', () async {
      final repository = FakePlayerImportRepository(
        profileResult: Success(_profile(accountId: 2222)),
        recentMatchesResult: Success([_match()]),
      );
      final checkpointRepository = FakeCoachingCheckpointRepository(
        storedCheckpoints: {86745912: _checkpoint(accountId: 86745912)},
      );
      final container = ProviderContainer(
        overrides: [
          playerImportRepositoryProvider.overrideWithValue(repository),
          coachingCheckpointRepositoryProvider.overrideWithValue(
            checkpointRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(playerImportControllerProvider.notifier);

      controller.updatePlayerId('2222');
      final success = await controller.submit();

      expect(success, isTrue);
      expect(container.read(previousCoachingCheckpointProvider), isNull);
      expect(checkpointRepository.loadCalls, [2222]);
    });
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
  final Future<Result<List<RecentMatch>>> Function()? recentMatchesResultFactory;

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
  }) : _storedCheckpoints = storedCheckpoints ?? {};

  final Map<int, CoachingCheckpoint> _storedCheckpoints;

  final List<int> loadCalls = [];
  final List<CoachingCheckpointDraft> savedDrafts = [];

  @override
  Future<CoachingCheckpoint?> loadForAccount(int accountId) async {
    loadCalls.add(accountId);
    return _storedCheckpoints[accountId];
  }

  @override
  Future<CoachingCheckpoint> saveDraft(CoachingCheckpointDraft draft) async {
    savedDrafts.add(draft);
    final checkpoint = draft.toCheckpoint(DateTime.utc(2025, 3, 21));
    _storedCheckpoints[draft.accountId] = checkpoint;
    return checkpoint;
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
