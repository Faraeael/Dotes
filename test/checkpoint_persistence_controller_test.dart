import 'dart:async';

import 'package:dotes/src/features/checkpoints/application/coaching_checkpoint_providers.dart';
import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/checkpoints/domain/repositories/coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/checkpoints/domain/services/checkpoint_save_policy_service.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckpointPersistenceController', () {
    test(
      'same account re-import with no new matches should not save a new checkpoint',
      () async {
        final previousCheckpoint = _checkpoint(
          accountId: 86745912,
          matchIds: const [105, 104, 103, 102, 101],
        );
        final repository = _FakeCoachingCheckpointRepository(
          historyByAccount: {
            86745912: [previousCheckpoint],
          },
        );
        final container = ProviderContainer(
          overrides: [
            coachingCheckpointRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          checkpointPersistenceControllerProvider,
        );
        await controller.loadPreviousForAccount(86745912);

        final decision = await controller.saveCurrentDraftIfNeeded(
          _draft(
            accountId: 86745912,
            focusAction: 'Slightly different wording',
            matchIds: const [105, 104, 103, 102, 101],
          ),
        );

        expect(decision.status, CheckpointSaveStatus.skippedNoNewMatches);
        expect(
          container.read(latestCheckpointSaveDecisionProvider)?.status,
          CheckpointSaveStatus.skippedNoNewMatches,
        );
        expect(repository.savedDrafts, isEmpty);
        expect(container.read(coachingCheckpointHistoryProvider), hasLength(1));
      },
    );

    test(
      'overlapping block should not create duplicate history entries',
      () async {
        final previousCheckpoint = _checkpoint(
          accountId: 86745912,
          matchIds: const [205, 204, 203, 202, 201],
        );
        final repository = _FakeCoachingCheckpointRepository(
          historyByAccount: {
            86745912: [previousCheckpoint],
          },
        );
        final container = ProviderContainer(
          overrides: [
            coachingCheckpointRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          checkpointPersistenceControllerProvider,
        );
        await controller.loadPreviousForAccount(86745912);

        final decision = await controller.saveCurrentDraftIfNeeded(
          _draft(
            accountId: 86745912,
            focusSourceLabel: 'Hero pool spread',
            topInsightType: CoachingInsightType.heroPoolSpread,
            matchIds: const [206, 205, 204, 203, 202],
          ),
        );

        expect(decision.status, CheckpointSaveStatus.skippedDuplicateBlock);
        expect(
          container.read(latestCheckpointSaveDecisionProvider)?.status,
          CheckpointSaveStatus.skippedDuplicateBlock,
        );
        expect(repository.savedDrafts, isEmpty);
        expect(container.read(coachingCheckpointHistoryProvider), hasLength(1));
      },
    );

    test(
      'partial refresh without enough new signal should skip saving',
      () async {
        final previousCheckpoint = _checkpoint(
          accountId: 86745912,
          matchIds: const [305, 304, 303, 302, 301],
        );
        final repository = _FakeCoachingCheckpointRepository(
          historyByAccount: {
            86745912: [previousCheckpoint],
          },
        );
        final container = ProviderContainer(
          overrides: [
            coachingCheckpointRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          checkpointPersistenceControllerProvider,
        );
        await controller.loadPreviousForAccount(86745912);

        final decision = await controller.saveCurrentDraftIfNeeded(
          _draft(
            accountId: 86745912,
            matchIds: const [307, 306, 305, 304, 303],
          ),
        );

        expect(decision.status, CheckpointSaveStatus.skippedNotMeaningfullyNew);
        expect(
          container.read(latestCheckpointSaveDecisionProvider)?.status,
          CheckpointSaveStatus.skippedNotMeaningfullyNew,
        );
        expect(repository.savedDrafts, isEmpty);
        expect(container.read(coachingCheckpointHistoryProvider), hasLength(1));
      },
    );

    test('clearly new block should save successfully', () async {
      final previousCheckpoint = _checkpoint(
        accountId: 86745912,
        matchIds: const [405, 404, 403, 402, 401],
      );
      final repository = _FakeCoachingCheckpointRepository(
        historyByAccount: {
          86745912: [previousCheckpoint],
        },
      );
      final container = ProviderContainer(
        overrides: [
          coachingCheckpointRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        checkpointPersistenceControllerProvider,
      );
      await controller.loadPreviousForAccount(86745912);

      final decision = await controller.saveCurrentDraftIfNeeded(
        _draft(
          accountId: 86745912,
          focusSourceLabel: 'Hero pool spread',
          topInsightType: CoachingInsightType.heroPoolSpread,
          uniqueHeroesPlayed: 3,
          matchIds: const [410, 409, 408, 407, 406],
        ),
      );

      expect(decision.status, CheckpointSaveStatus.saved);
      expect(
        container.read(latestCheckpointSaveDecisionProvider)?.status,
        CheckpointSaveStatus.saved,
      );
      expect(repository.savedDrafts, hasLength(1));
      expect(container.read(coachingCheckpointHistoryProvider), hasLength(2));
      expect(
        container
            .read(coachingCheckpointHistoryProvider)
            .first
            .sample
            .latestMatchId,
        410,
      );
    });

    test('different accounts still stay isolated', () async {
      final repository = _FakeCoachingCheckpointRepository(
        historyByAccount: {
          86745912: [
            _checkpoint(
              accountId: 86745912,
              matchIds: const [505, 504, 503, 502, 501],
            ),
          ],
        },
      );
      final container = ProviderContainer(
        overrides: [
          coachingCheckpointRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        checkpointPersistenceControllerProvider,
      );
      await controller.loadPreviousForAccount(2222);

      final decision = await controller.saveCurrentDraftIfNeeded(
        _draft(accountId: 2222, matchIds: const [510, 509, 508, 507, 506]),
      );

      final firstAccountHistory = await repository.loadHistoryForAccount(
        86745912,
      );
      final secondAccountHistory = await repository.loadHistoryForAccount(2222);

      expect(decision.status, CheckpointSaveStatus.saved);
      expect(
        container.read(latestCheckpointSaveDecisionProvider)?.accountId,
        2222,
      );
      expect(firstAccountHistory, hasLength(1));
      expect(firstAccountHistory.first.accountId, 86745912);
      expect(secondAccountHistory, hasLength(1));
      expect(secondAccountHistory.first.accountId, 2222);
    });

    test(
      'clears the visible save status when another account is loaded',
      () async {
        final repository = _FakeCoachingCheckpointRepository(
          historyByAccount: {
            86745912: [
              _checkpoint(
                accountId: 86745912,
                matchIds: const [705, 704, 703, 702, 701],
              ),
            ],
          },
        );
        final container = ProviderContainer(
          overrides: [
            coachingCheckpointRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          checkpointPersistenceControllerProvider,
        );
        await controller.loadPreviousForAccount(86745912);
        await controller.saveCurrentDraftIfNeeded(
          _draft(
            accountId: 86745912,
            focusSourceLabel: 'Hero pool spread',
            topInsightType: CoachingInsightType.heroPoolSpread,
            uniqueHeroesPlayed: 3,
            matchIds: const [710, 709, 708, 707, 706],
          ),
        );

        expect(container.read(latestCheckpointSaveDecisionProvider), isNotNull);

        await controller.loadPreviousForAccount(2222);

        expect(container.read(latestCheckpointSaveDecisionProvider), isNull);
      },
    );

    test(
      'coalesces concurrent duplicate save attempts into one checkpoint',
      () async {
        final saveCompleter = Completer<void>();
        final previousCheckpoint = _checkpoint(
          accountId: 86745912,
          matchIds: const [605, 604, 603, 602, 601],
        );
        final repository = _FakeCoachingCheckpointRepository(
          historyByAccount: {
            86745912: [previousCheckpoint],
          },
          saveCompleter: saveCompleter,
        );
        final container = ProviderContainer(
          overrides: [
            coachingCheckpointRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          checkpointPersistenceControllerProvider,
        );
        await controller.loadPreviousForAccount(86745912);

        final draft = _draft(
          accountId: 86745912,
          focusSourceLabel: 'Hero pool spread',
          topInsightType: CoachingInsightType.heroPoolSpread,
          uniqueHeroesPlayed: 3,
          matchIds: const [610, 609, 608, 607, 606],
        );

        final firstSave = controller.saveCurrentDraftIfNeeded(draft);
        final secondSave = controller.saveCurrentDraftIfNeeded(draft);

        expect(repository.savedDrafts, hasLength(1));

        saveCompleter.complete();
        final firstDecision = await firstSave;
        final secondDecision = await secondSave;

        expect(firstDecision.status, CheckpointSaveStatus.saved);
        expect(secondDecision.status, CheckpointSaveStatus.saved);
        expect(repository.savedDrafts, hasLength(1));
        expect(container.read(coachingCheckpointHistoryProvider), hasLength(2));
      },
    );
  });
}

class _FakeCoachingCheckpointRepository
    implements CoachingCheckpointRepository {
  _FakeCoachingCheckpointRepository({
    Map<int, List<CoachingCheckpoint>>? historyByAccount,
    this.saveCompleter,
  }) : _historyByAccount = {
         for (final entry in (historyByAccount ?? {}).entries)
           entry.key: [...entry.value],
       };

  final Map<int, List<CoachingCheckpoint>> _historyByAccount;
  final List<CoachingCheckpointDraft> savedDrafts = [];
  final Completer<void>? saveCompleter;

  @override
  Future<CoachingCheckpoint?> loadForAccount(int accountId) async {
    final history = _historyByAccount[accountId];
    if (history == null || history.isEmpty) {
      return null;
    }

    return history.first;
  }

  @override
  Future<List<CoachingCheckpoint>> loadHistoryForAccount(int accountId) async {
    return (_historyByAccount[accountId] ?? const []).toList(growable: false);
  }

  @override
  Future<CoachingCheckpoint> saveDraft(CoachingCheckpointDraft draft) async {
    savedDrafts.add(draft);
    if (saveCompleter != null && !saveCompleter!.isCompleted) {
      await saveCompleter!.future;
    }
    final checkpoint = draft.toCheckpoint(DateTime.utc(2025, 3, 21, 12));
    _historyByAccount.update(
      draft.accountId,
      (history) => [checkpoint, ...history],
      ifAbsent: () => [checkpoint],
    );
    return checkpoint;
  }
}

CoachingCheckpoint _checkpoint({
  required int accountId,
  required List<int> matchIds,
}) {
  return CoachingCheckpoint(
    accountId: accountId,
    savedAt: DateTime.utc(2025, 3, 21, 10),
    focusAction: 'Play the next 5 games on one role and no more than 2 heroes.',
    focusSourceLabel: 'Weak recent trend',
    topInsightType: CoachingInsightType.weakRecentTrend,
    sample: CoachingCheckpointSample(
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
      recentMatchesWindow: [
        for (var index = 0; index < matchIds.length; index++)
          CoachingCheckpointMatchSummary(
            matchId: matchIds[index],
            heroId: 50 + index,
            didWin: index.isEven,
          ),
      ],
    ),
  );
}

CoachingCheckpointDraft _draft({
  required int accountId,
  String focusAction =
      'Play the next 5 games on one role and no more than 2 heroes.',
  String focusSourceLabel = 'Weak recent trend',
  CoachingInsightType topInsightType = CoachingInsightType.weakRecentTrend,
  int uniqueHeroesPlayed = 5,
  List<int> matchIds = const [105, 104, 103, 102, 101],
}) {
  return CoachingCheckpointDraft(
    accountId: accountId,
    focusAction: focusAction,
    focusSourceLabel: focusSourceLabel,
    topInsightType: topInsightType,
    sample: CoachingCheckpointSample(
      matchesAnalyzed: 10,
      wins: 4,
      losses: 6,
      winRate: 0.4,
      uniqueHeroesPlayed: uniqueHeroesPlayed,
      averageDeaths: 6.8,
      likelyRoleSummaryLabel: 'Core role leaning',
      roleEstimateStrengthLabel: 'Moderate estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'carry',
      recentMatchesWindow: [
        for (var index = 0; index < matchIds.length; index++)
          CoachingCheckpointMatchSummary(
            matchId: matchIds[index],
            heroId: 60 + index,
            didWin: index.isEven,
          ),
      ],
    ),
  );
}
