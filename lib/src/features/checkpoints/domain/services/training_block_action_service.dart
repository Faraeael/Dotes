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
            'Active block started on ${_formatDate(activeCheckpoint.savedAt)}',
      );
    }

    final latestSavedCheckpoint = checkpointHistory.isEmpty
        ? null
        : checkpointHistory.first;
    return TrainingBlockActionControl(
      actionType: TrainingBlockActionType.start,
      blockStateLabel: 'No active block yet',
      blockStateDetail: latestSavedCheckpoint == null
          ? null
          : 'Latest coaching state saved on ${_formatDate(latestSavedCheckpoint.savedAt)}.',
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
