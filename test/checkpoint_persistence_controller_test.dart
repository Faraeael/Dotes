import 'package:dotes/src/features/checkpoints/application/coaching_checkpoint_providers.dart';
import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/checkpoints/domain/repositories/coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckpointPersistenceController', () {
    test('same account re-import with no new matches should not save a new checkpoint', () async {
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

      final controller = container.read(checkpointPersistenceControllerProvider);
      await controller.loadPreviousForAccount(86745912);

      await controller.saveCurrentDraftIfNeeded(
        _draft(
          accountId: 86745912,
          focusAction: 'Slightly different wording',
          matchIds: const [105, 104, 103, 102, 101],
        ),
      );

      expect(repository.savedDrafts, isEmpty);
      expect(container.read(coachingCheckpointHistoryProvider), hasLength(1));
    });

    test('overlapping block should not create duplicate history entries', () async {
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

      final controller = container.read(checkpointPersistenceControllerProvider);
      await controller.loadPreviousForAccount(86745912);

      await controller.saveCurrentDraftIfNeeded(
        _draft(
          accountId: 86745912,
          focusSourceLabel: 'Hero pool spread',
          topInsightType: CoachingInsightType.heroPoolSpread,
          matchIds: const [206, 205, 204, 203, 202],
        ),
      );

      expect(repository.savedDrafts, isEmpty);
      expect(container.read(coachingCheckpointHistoryProvider), hasLength(1));
    });

    test('clearly new block should save successfully', () async {
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

      final controller = container.read(checkpointPersistenceControllerProvider);
      await controller.loadPreviousForAccount(86745912);

      await controller.saveCurrentDraftIfNeeded(
        _draft(
          accountId: 86745912,
          focusSourceLabel: 'Hero pool spread',
          topInsightType: CoachingInsightType.heroPoolSpread,
          uniqueHeroesPlayed: 3,
          matchIds: const [310, 309, 308, 307, 306],
        ),
      );

      expect(repository.savedDrafts, hasLength(1));
      expect(container.read(coachingCheckpointHistoryProvider), hasLength(2));
      expect(
        container.read(coachingCheckpointHistoryProvider).first.sample.latestMatchId,
        310,
      );
    });

    test('different accounts still stay isolated', () async {
      final repository = _FakeCoachingCheckpointRepository(
        historyByAccount: {
          86745912: [
            _checkpoint(
              accountId: 86745912,
              matchIds: const [405, 404, 403, 402, 401],
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

      final controller = container.read(checkpointPersistenceControllerProvider);
      await controller.loadPreviousForAccount(2222);

      await controller.saveCurrentDraftIfNeeded(
        _draft(
          accountId: 2222,
          matchIds: const [510, 509, 508, 507, 506],
        ),
      );

      final firstAccountHistory = await repository.loadHistoryForAccount(86745912);
      final secondAccountHistory = await repository.loadHistoryForAccount(2222);

      expect(firstAccountHistory, hasLength(1));
      expect(firstAccountHistory.first.accountId, 86745912);
      expect(secondAccountHistory, hasLength(1));
      expect(secondAccountHistory.first.accountId, 2222);
    });
  });
}

class _FakeCoachingCheckpointRepository implements CoachingCheckpointRepository {
  _FakeCoachingCheckpointRepository({
    Map<int, List<CoachingCheckpoint>>? historyByAccount,
  }) : _historyByAccount = {
         for (final entry in (historyByAccount ?? {}).entries)
           entry.key: [...entry.value],
       };

  final Map<int, List<CoachingCheckpoint>> _historyByAccount;
  final List<CoachingCheckpointDraft> savedDrafts = [];

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
  String focusAction = 'Play the next 5 games on one role and no more than 2 heroes.',
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
