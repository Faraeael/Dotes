import 'package:dotes/src/features/checkpoints/data/local/checkpoint_local_store.dart';
import 'package:dotes/src/features/checkpoints/data/repositories/local_coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/checkpoints/domain/repositories/coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
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

      expect(loadedCheckpoint, isNotNull);
      expect(loadedCheckpoint!.accountId, 86745912);
      expect(loadedCheckpoint.focusAction, draft.focusAction);
      expect(loadedCheckpoint.topInsightType, CoachingInsightType.earlyDeathRisk);
      expect(loadedCheckpoint.sample.averageDeaths, 7.2);
    });

    test('does not reuse another account checkpoint', () async {
      await repository.saveDraft(_draft(accountId: 86745912));

      final otherCheckpoint = await repository.loadForAccount(2222);

      expect(otherCheckpoint, isNull);
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

CoachingCheckpointDraft _draft({required int accountId}) {
  return CoachingCheckpointDraft(
    accountId: accountId,
    focusAction: 'Keep deaths to 6 or fewer in each of the next 5 games.',
    focusSourceLabel: 'Early death risk',
    topInsightType: CoachingInsightType.earlyDeathRisk,
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
    ),
  );
}
