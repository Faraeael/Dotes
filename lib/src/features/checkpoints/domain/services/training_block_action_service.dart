import '../models/coaching_checkpoint.dart';
import '../models/training_block_action.dart';

class TrainingBlockActionService {
  const TrainingBlockActionService();

  TrainingBlockActionControl build({
    required CoachingCheckpoint? activeCheckpoint,
    required List<CoachingCheckpoint> checkpointHistory,
  }) {
    if (activeCheckpoint != null) {
      return TrainingBlockActionControl(
        actionType: TrainingBlockActionType.restart,
        blockStateLabel:
            'Current block started on ${_formatDate(activeCheckpoint.savedAt)}',
        blockStateDetail:
            'Restart only if you want to replace that start point with the current plan.',
      );
    }

    final latestSavedCheckpoint = checkpointHistory.isEmpty
        ? null
        : checkpointHistory.first;
    return TrainingBlockActionControl(
      actionType: TrainingBlockActionType.start,
      blockStateLabel: 'No active block yet',
      blockStateDetail: latestSavedCheckpoint == null
          ? 'Start the current session plan before you queue the next 5 games.'
          : 'Latest coaching state saved on ${_formatDate(latestSavedCheckpoint.savedAt)}. Start a fresh 5-game block when you are ready to judge the next run.',
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = _monthLabels[local.month - 1];
    return '$month ${local.day}, ${local.year}';
  }
}

const _monthLabels = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
