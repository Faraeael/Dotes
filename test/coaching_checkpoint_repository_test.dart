import 'package:dotes/src/features/checkpoints/data/local/checkpoint_local_store.dart';
import 'package:dotes/src/features/checkpoints/data/repositories/local_coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/checkpoints/domain/repositories/coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalCoachingCheckpointRepository', () {
    late InMemoryCheckpointLocalStore store;
    late CoachingCheckpointRepository repository;

    setUp(() {
      store = InMemoryCheckpointLocalStore();
      repository = LocalCoachingCheckpointRepository(store);
    });

    test('returns null when no checkpoint exists for an account', () async {
      final checkpoint = await repository.loadForAccount(86745912);

      expect(checkpoint, isNull);
    });

    test('saves and loads a checkpoint for the same account', () async {
      final draft = _draft(accountId: 86745912);

      await repository.saveDraft(draft);
      final loadedCheckpoint = await repository.loadForAccount(86745912);
      final history = await repository.loadHistoryForAccount(86745912);

      expect(loadedCheckpoint, isNotNull);
      expect(loadedCheckpoint!.accountId, 86745912);
      expect(loadedCheckpoint.focusAction, draft.focusAction);
      expect(
        loadedCheckpoint.topInsightType,
        CoachingInsightType.earlyDeathRisk,
      );
      expect(loadedCheckpoint.focusHeroBlock, isNotNull);
      expect(loadedCheckpoint.focusHeroBlock!.heroIds, [28, 129]);
      expect(loadedCheckpoint.focusHeroBlock!.heroLabels, ['Slardar', 'Mars']);
      expect(loadedCheckpoint.savedSessionPlan, isNotNull);
      expect(loadedCheckpoint.savedSessionPlan!.heroBlockHeroIds, [28, 129]);
      expect(
        loadedCheckpoint.savedTrainingPreferences?.coachingMode,
        TrainingCoachingMode.preferManualSetup,
      );
      expect(loadedCheckpoint.sample.averageDeaths, 7.2);
      expect(loadedCheckpoint.sample.recentMatchesWindow, hasLength(5));
      expect(loadedCheckpoint.blockFingerprint, draft.blockFingerprint);
      expect(history, hasLength(1));
    });

    test('does not reuse another account checkpoint', () async {
      await repository.saveDraft(_draft(accountId: 86745912));

      final otherCheckpoint = await repository.loadForAccount(2222);
      final otherHistory = await repository.loadHistoryForAccount(2222);

      expect(otherCheckpoint, isNull);
      expect(otherHistory, isEmpty);
    });

    test(
      'stores multiple checkpoints for the same account in recency order',
      () async {
        await repository.saveDraft(
          _draft(accountId: 86745912, focusAction: 'Old focus'),
        );
        await repository.saveDraft(
          _draft(accountId: 86745912, focusAction: 'New focus'),
        );

        final history = await repository.loadHistoryForAccount(86745912);

        expect(history, hasLength(2));
        expect(history.first.focusAction, 'New focus');
        expect(history.last.focusAction, 'Old focus');
      },
    );

    test('keeps histories separate for different accounts', () async {
      await repository.saveDraft(
        _draft(accountId: 86745912, focusAction: 'Account one'),
      );
      await repository.saveDraft(
        _draft(accountId: 2222, focusAction: 'Account two'),
      );

      final firstHistory = await repository.loadHistoryForAccount(86745912);
      final secondHistory = await repository.loadHistoryForAccount(2222);

      expect(firstHistory, hasLength(1));
      expect(firstHistory.first.focusAction, 'Account one');
      expect(secondHistory, hasLength(1));
      expect(secondHistory.first.focusAction, 'Account two');
    });
  });
}

class InMemoryCheckpointLocalStore implements CheckpointLocalStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> getString(String key) async {
    return _values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}

CoachingCheckpointDraft _draft({
  required int accountId,
  String focusAction = 'Keep deaths to 6 or fewer in each of the next 5 games.',
}) {
  return CoachingCheckpointDraft(
    accountId: accountId,
    focusAction: focusAction,
    focusSourceLabel: 'Early death risk',
    topInsightType: CoachingInsightType.earlyDeathRisk,
    focusHeroBlock: const CoachingCheckpointHeroBlock(
      heroIds: [28, 129],
      heroLabels: ['Slardar', 'Mars'],
      wins: 4,
      losses: 1,
    ),
    savedSessionPlan: const CoachingCheckpointSessionPlan(
      queue: 'Carry only',
      heroBlock: 'Slardar + Mars',
      target: 'Stay on the block',
      reviewWindow: 'next 5 games',
      targetType: SessionPlanTargetType.comfortBlock,
      heroBlockHeroIds: [28, 129],
      heroBlockHeroLabels: ['Slardar', 'Mars'],
      roleBlockKey: 'carry',
      usesManualRoleSetup: true,
      usesManualHeroBlock: true,
    ),
    savedTrainingPreferences: const TrainingPreferences(
      coachingMode: TrainingCoachingMode.preferManualSetup,
      preferredRole: TrainingRolePreference.carry,
      lockedHeroIds: [28, 129],
    ),
    sample: const CoachingCheckpointSample(
      matchesAnalyzed: 10,
      wins: 4,
      losses: 6,
      winRate: 0.4,
      uniqueHeroesPlayed: 5,
      averageDeaths: 7.2,
      likelyRoleSummaryLabel: 'Core role leaning',
      roleEstimateStrengthLabel: 'Moderate estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'carry',
      recentMatchesWindow: [
        CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
        CoachingCheckpointMatchSummary(heroId: 129, didWin: true),
        CoachingCheckpointMatchSummary(heroId: 28, didWin: false),
        CoachingCheckpointMatchSummary(heroId: 53, didWin: false),
        CoachingCheckpointMatchSummary(heroId: 129, didWin: true),
      ],
    ),
  );
}
