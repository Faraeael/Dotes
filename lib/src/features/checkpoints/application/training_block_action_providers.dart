import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/application/session_plan_provider.dart';
import '../../dashboard/domain/models/session_plan.dart';
import '../../matches/presentation/utils/hero_labels.dart';
import '../../training_preferences/application/training_preferences_providers.dart';
import '../../training_preferences/domain/models/training_preferences.dart';
import '../domain/models/coaching_checkpoint.dart';
import '../domain/models/training_block_action.dart';
import '../domain/services/training_block_action_service.dart';
import 'coaching_checkpoint_providers.dart';

final trainingBlockActionServiceProvider =
    Provider<TrainingBlockActionService>((ref) {
      return const TrainingBlockActionService();
    });

final trainingBlockActionControlProvider =
    Provider<TrainingBlockActionControl?>((ref) {
      final draft = ref.watch(currentCoachingCheckpointDraftProvider);
      if (draft == null) {
        return null;
      }

      return ref.watch(trainingBlockActionServiceProvider).build(
        activeCheckpoint: ref.watch(previousCoachingCheckpointProvider),
        checkpointHistory: ref.watch(coachingCheckpointHistoryProvider),
      );
    });

final trainingBlockActionBusyProvider = StateProvider<bool>((ref) => false);

final trainingBlockActionControllerProvider =
    Provider<TrainingBlockActionController>((ref) {
      return TrainingBlockActionController(
        ref,
        ref.watch(checkpointPersistenceControllerProvider),
      );
    });

class TrainingBlockActionController {
  TrainingBlockActionController(this._ref, this._checkpointController);

  final Ref _ref;
  final CheckpointPersistenceController _checkpointController;

  Future<void> startOrRestartCurrentBlock() async {
    if (_ref.read(trainingBlockActionBusyProvider)) {
      return;
    }

    final draft = _ref.read(currentCoachingCheckpointDraftProvider);
    if (draft == null) {
      return;
    }

    _ref.read(trainingBlockActionBusyProvider.notifier).state = true;
    try {
      await _checkpointController.startOrRestartBlock(
        _startedDraft(
          draft,
          sessionPlan: _ref.read(sessionPlanProvider),
          trainingPreferences: _ref.read(currentTrainingPreferencesProvider),
        ),
      );
    } finally {
      _ref.read(trainingBlockActionBusyProvider.notifier).state = false;
    }
  }

  CoachingCheckpointDraft _startedDraft(
    CoachingCheckpointDraft draft, {
    required TrainingPreferences trainingPreferences,
    required SessionPlan? sessionPlan,
  }) {
    return draft.withSavedContext(
      savedSessionPlan: sessionPlan == null
          ? null
          : CoachingCheckpointSessionPlan.fromSessionPlan(
              sessionPlan,
              heroBlockHeroLabels: sessionPlan.heroBlockHeroIds
                  .map(heroDisplayName)
                  .toList(growable: false),
            ),
      savedTrainingPreferences: trainingPreferences,
    );
  }
}
