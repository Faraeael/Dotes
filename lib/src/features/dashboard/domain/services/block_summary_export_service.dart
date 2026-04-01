import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import '../models/block_summary_export.dart';
import '../models/end_block_summary.dart';
import 'reviewed_block_window_service.dart';

class BlockSummaryExportService {
  const BlockSummaryExportService({
    ReviewedBlockWindowService reviewedBlockWindowService =
        const ReviewedBlockWindowService(),
  }) : _reviewedBlockWindowService = reviewedBlockWindowService;

  final ReviewedBlockWindowService _reviewedBlockWindowService;

  BlockSummaryExport? build({
    required EndBlockSummary? completedSummary,
    required CoachingCheckpoint? activeStartedCheckpoint,
    required ImportedPlayerData? importedPlayer,
  }) {
    if (completedSummary == null || activeStartedCheckpoint == null) {
      return null;
    }

    final playerLabel = _playerLabelFor(importedPlayer, activeStartedCheckpoint);
    final completionDateLabel = _completionDateLabelFor(
      checkpoint: activeStartedCheckpoint,
      importedPlayer: importedPlayer,
    );

    final outcome = completedSummary.outcome.label;
    final mainTargetResult = completedSummary.mainTargetResult;
    final adherenceResult = completedSummary.adherenceResult;
    final takeaway = completedSummary.takeaway;
    final nextStep = completedSummary.nextStepSuggestion;

    return BlockSummaryExport(
      playerLabel: playerLabel,
      completionDateLabel: completionDateLabel,
      outcome: outcome,
      mainTargetResult: mainTargetResult,
      adherenceResult: adherenceResult,
      takeaway: takeaway,
      nextStep: nextStep,
      shareText: _shareText(
        playerLabel: playerLabel,
        completionDateLabel: completionDateLabel,
        outcome: outcome,
        mainTargetResult: mainTargetResult,
        adherenceResult: adherenceResult,
        takeaway: takeaway,
        nextStep: nextStep,
      ),
    );
  }

  String _playerLabelFor(
    ImportedPlayerData? importedPlayer,
    CoachingCheckpoint checkpoint,
  ) {
    final profile = importedPlayer?.profile;
    if (profile != null && profile.displayName != 'Unknown player') {
      return '${profile.displayName} (Account ${profile.accountId})';
    }

    return 'Account ${checkpoint.accountId}';
  }

  String _completionDateLabelFor({
    required CoachingCheckpoint checkpoint,
    required ImportedPlayerData? importedPlayer,
  }) {
    final matches = importedPlayer == null
        ? const []
        : _reviewedBlockWindowService.build(
            previousCheckpoint: checkpoint,
            currentMatches: importedPlayer.recentMatches,
          );
    if (matches.isNotEmpty) {
      final completionDate = matches.last.startedAt.toLocal();
      return _formatDate(completionDate);
    }

    return _formatDate(checkpoint.savedAt.toLocal());
  }

  String _shareText({
    required String playerLabel,
    required String completionDateLabel,
    required String outcome,
    required String mainTargetResult,
    required String adherenceResult,
    required String takeaway,
    required String nextStep,
  }) {
    return [
      'Training block summary',
      'Player: $playerLabel',
      'Completed: $completionDateLabel',
      'Outcome: $outcome',
      'Main target: $mainTargetResult',
      'Adherence: $adherenceResult',
      'Takeaway: $takeaway',
      'Next step: $nextStep',
    ].join('\n');
  }

  String _formatDate(DateTime value) {
    final month = _monthLabels[value.month - 1];
    return '$month ${value.day}, ${value.year}';
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
