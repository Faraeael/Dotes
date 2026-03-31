import 'package:dotes/src/features/checkpoints/application/coaching_checkpoint_providers.dart';
import 'package:dotes/src/features/checkpoints/application/training_block_action_providers.dart';
import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/checkpoints/domain/repositories/coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/dashboard/application/session_plan_provider.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/training_preferences/application/training_preferences_providers.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _draftStateProvider = StateProvider<CoachingCheckpointDraft?>(
  (ref) => null,
);
final _sessionPlanStateProvider = StateProvider<SessionPlan?>((ref) => null);
final _trainingPreferencesStateProvider = StateProvider<TrainingPreferences>(
  (ref) => const TrainingPreferences(),
);

void main() {
  group('TrainingBlockActionController', () {
    test('starts a new block and promotes it to the active baseline', () async {
      final repository = _FakeCoachingCheckpointRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      container.read(_draftStateProvider.notifier).state = _draft(
        accountId: 86745912,
        focusAction: 'Start focus',
      );
      container.read(_sessionPlanStateProvider.notifier).state = _sessionPlan(
        heroBlockHeroIds: const [53, 129],
      );

      await container
          .read(trainingBlockActionControllerProvider)
          .startOrRestartCurrentBlock();

      expect(repository.savedDrafts, hasLength(1));
      expect(
        container.read(previousCoachingCheckpointProvider)?.focusAction,
        'Start focus',
      );
      expect(container.read(coachingCheckpointHistoryProvider), hasLength(1));
      expect(
        container
            .read(previousCoachingCheckpointProvider)
            ?.savedSessionPlan
            ?.heroBlockHeroIds,
        [53, 129],
      );
    });

    test('restarting a block replaces the active baseline', () async {
      final repository = _FakeCoachingCheckpointRepository(
        historyByAccount: {
          86745912: [
            _checkpoint(
              accountId: 86745912,
              savedAt: DateTime.utc(2025, 3, 20, 10),
              focusAction: 'Old block',
            ),
          ],
        },
      );
      final container = _container(repository);
      addTearDown(container.dispose);

      await container
          .read(checkpointPersistenceControllerProvider)
          .loadPreviousForAccount(86745912);
      container.read(_draftStateProvider.notifier).state = _draft(
        accountId: 86745912,
        focusAction: 'Restarted block',
      );
      container.read(_sessionPlanStateProvider.notifier).state = _sessionPlan(
        heroBlockHeroIds: const [28, 129],
      );

      await container
          .read(trainingBlockActionControllerProvider)
          .startOrRestartCurrentBlock();

      expect(repository.historyByAccount[86745912], hasLength(2));
      expect(
        container.read(previousCoachingCheckpointProvider)?.focusAction,
        'Restarted block',
      );
      expect(
        container.read(coachingCheckpointHistoryProvider).first.focusAction,
        'Restarted block',
      );
    });

    test('includes the manual hero block in the started baseline', () async {
      final repository = _FakeCoachingCheckpointRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      container.read(_draftStateProvider.notifier).state = _draft(
        accountId: 86745912,
      );
      container.read(_sessionPlanStateProvider.notifier).state = _sessionPlan(
        heroBlockHeroIds: const [28, 129],
        usesManualHeroBlock: true,
      );
      container.read(_trainingPreferencesStateProvider.notifier).state =
          const TrainingPreferences(
            coachingMode: TrainingCoachingMode.preferManualSetup,
            lockedHeroIds: [28, 129],
          );

      await container
          .read(trainingBlockActionControllerProvider)
          .startOrRestartCurrentBlock();

      final checkpoint = container.read(previousCoachingCheckpointProvider)!;
      expect(
        checkpoint.savedTrainingPreferences?.coachingMode,
        TrainingCoachingMode.preferManualSetup,
      );
      expect(
        checkpoint.savedTrainingPreferences?.activeLockedHeroIds,
        [28, 129],
      );
      expect(checkpoint.savedSessionPlan?.heroBlockHeroIds, [28, 129]);
      expect(checkpoint.savedSessionPlan?.usesManualHeroBlock, isTrue);
    });

    test('keeps app-read mode when the block starts from the automatic plan', () async {
      final repository = _FakeCoachingCheckpointRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      container.read(_draftStateProvider.notifier).state = _draft(
        accountId: 86745912,
      );
      container.read(_sessionPlanStateProvider.notifier).state = _sessionPlan(
        heroBlockHeroIds: const [53, 129],
      );
      container.read(_trainingPreferencesStateProvider.notifier).state =
          const TrainingPreferences();

      await container
          .read(trainingBlockActionControllerProvider)
          .startOrRestartCurrentBlock();

      final checkpoint = container.read(previousCoachingCheckpointProvider)!;
      expect(
        checkpoint.savedTrainingPreferences?.coachingMode,
        TrainingCoachingMode.followAppRead,
      );
      expect(checkpoint.savedSessionPlan?.heroBlockHeroIds, [53, 129]);
      expect(checkpoint.savedSessionPlan?.usesManualHeroBlock, isFalse);
    });

    test('keeps active block state isolated by account', () async {
      final repository = _FakeCoachingCheckpointRepository(
        historyByAccount: {
          2222: [
            _checkpoint(
              accountId: 2222,
              savedAt: DateTime.utc(2025, 3, 19, 9),
              focusAction: 'Account two old block',
            ),
          ],
        },
      );
      final container = _container(repository);
      addTearDown(container.dispose);

      container.read(_draftStateProvider.notifier).state = _draft(
        accountId: 86745912,
        focusAction: 'Account one block',
      );
      container.read(_sessionPlanStateProvider.notifier).state = _sessionPlan(
        heroBlockHeroIds: const [28, 129],
      );
      await container
          .read(trainingBlockActionControllerProvider)
          .startOrRestartCurrentBlock();

      await container
          .read(checkpointPersistenceControllerProvider)
          .loadPreviousForAccount(2222);

      expect(container.read(previousCoachingCheckpointProvider)?.accountId, 2222);
      expect(
        container.read(previousCoachingCheckpointProvider)?.focusAction,
        'Account two old block',
      );

      container.read(_draftStateProvider.notifier).state = _draft(
        accountId: 2222,
        focusAction: 'Account two new block',
      );
      container.read(_sessionPlanStateProvider.notifier).state = _sessionPlan(
        heroBlockHeroIds: const [53],
      );
      await container
          .read(trainingBlockActionControllerProvider)
          .startOrRestartCurrentBlock();

      expect(repository.historyByAccount[86745912], hasLength(1));
      expect(repository.historyByAccount[2222], hasLength(2));
      expect(repository.historyByAccount[86745912]!.first.accountId, 86745912);
      expect(repository.historyByAccount[2222]!.first.focusAction, 'Account two new block');
    });
  });
}

ProviderContainer _container(_FakeCoachingCheckpointRepository repository) {
  return ProviderContainer(
    overrides: [
      coachingCheckpointRepositoryProvider.overrideWithValue(repository),
      currentCoachingCheckpointDraftProvider.overrideWith(
        (ref) => ref.watch(_draftStateProvider),
      ),
      sessionPlanProvider.overrideWith(
        (ref) => ref.watch(_sessionPlanStateProvider),
      ),
      currentTrainingPreferencesProvider.overrideWith(
        (ref) => ref.watch(_trainingPreferencesStateProvider),
      ),
    ],
  );
}

class _FakeCoachingCheckpointRepository implements CoachingCheckpointRepository {
  _FakeCoachingCheckpointRepository({
    Map<int, List<CoachingCheckpoint>>? historyByAccount,
  }) : historyByAccount = {
         for (final entry in (historyByAccount ?? {}).entries)
           entry.key: [...entry.value],
       };

  final Map<int, List<CoachingCheckpoint>> historyByAccount;
  final List<CoachingCheckpointDraft> savedDrafts = [];
  int _saveCount = 0;

  @override
  Future<CoachingCheckpoint?> loadForAccount(int accountId) async {
    final history = historyByAccount[accountId];
    if (history == null || history.isEmpty) {
      return null;
    }

    return history.first;
  }

  @override
  Future<List<CoachingCheckpoint>> loadHistoryForAccount(int accountId) async {
    return (historyByAccount[accountId] ?? const []).toList(growable: false);
  }

  @override
  Future<CoachingCheckpoint> saveDraft(CoachingCheckpointDraft draft) async {
    savedDrafts.add(draft);
    _saveCount++;
    final checkpoint = draft.toCheckpoint(
      DateTime.utc(2025, 3, 21, 12, _saveCount),
    );
    historyByAccount.update(
      draft.accountId,
      (history) => [checkpoint, ...history],
      ifAbsent: () => [checkpoint],
    );
    return checkpoint;
  }
}

CoachingCheckpointDraft _draft({
  required int accountId,
  String focusAction = 'Focus action',
}) {
  return CoachingCheckpointDraft(
    accountId: accountId,
    focusAction: focusAction,
    focusSourceLabel: 'Weak recent trend',
    topInsightType: CoachingInsightType.weakRecentTrend,
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
      recentMatchesWindow: [
        CoachingCheckpointMatchSummary(matchId: 105, heroId: 53, didWin: true),
        CoachingCheckpointMatchSummary(matchId: 104, heroId: 129, didWin: false),
        CoachingCheckpointMatchSummary(matchId: 103, heroId: 53, didWin: true),
        CoachingCheckpointMatchSummary(matchId: 102, heroId: 28, didWin: false),
        CoachingCheckpointMatchSummary(matchId: 101, heroId: 53, didWin: true),
      ],
    ),
  );
}

CoachingCheckpoint _checkpoint({
  required int accountId,
  required DateTime savedAt,
  required String focusAction,
}) {
  return CoachingCheckpoint(
    accountId: accountId,
    savedAt: savedAt,
    focusAction: focusAction,
    focusSourceLabel: 'Weak recent trend',
    topInsightType: CoachingInsightType.weakRecentTrend,
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

SessionPlan _sessionPlan({
  List<int> heroBlockHeroIds = const [],
  bool usesManualHeroBlock = false,
}) {
  return SessionPlan(
    queue: 'Carry only',
    heroBlock: heroBlockHeroIds.isEmpty ? '2 heroes max' : 'Named block',
    target: 'Stay on the block',
    reviewWindow: 'next 5 games',
    targetType: SessionPlanTargetType.heroPool,
    heroBlockHeroIds: heroBlockHeroIds,
    usesManualHeroBlock: usesManualHeroBlock,
  );
}
