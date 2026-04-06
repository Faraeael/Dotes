import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import '../../../training_preferences/domain/models/training_preferences.dart';
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
    String? practiceNote,
  }) {
    if (completedSummary == null || activeStartedCheckpoint == null) {
      return null;
    }

    final playerLabel = _playerLabelFor(
      importedPlayer,
      activeStartedCheckpoint,
    );
    final completionDateLabel = _completionDateLabelFor(
      checkpoint: activeStartedCheckpoint,
      importedPlayer: importedPlayer,
    );
    final savedPlan = activeStartedCheckpoint.savedSessionPlan;
    final trimmedPracticeNote = _trimmedPracticeNote(practiceNote);

    final focusLabel = activeStartedCheckpoint.focusAction;
    final queueLabel = savedPlan?.queue ?? 'Queue not saved';
    final heroBlockLabel =
        savedPlan?.heroBlock ??
        activeStartedCheckpoint.focusHeroBlock?.label ??
        'No fixed hero block';
    final targetLabel = savedPlan?.target ?? 'Review the next block cleanly';
    final reviewWindowLabel = savedPlan?.reviewWindow ?? 'next 5 games';
    final outcome = completedSummary.outcome.label;
    final mainTargetResult = completedSummary.mainTargetResult;
    final adherenceResult = completedSummary.adherenceResult;
    final takeaway = completedSummary.takeaway;
    final nextStep = _styledNextStep(
      completedSummary.nextStepSuggestion,
      activeStartedCheckpoint.savedTrainingPreferences?.coachingStyle ??
          TrainingCoachingStyle.auto,
    );

    return BlockSummaryExport(
      playerLabel: playerLabel,
      completionDateLabel: completionDateLabel,
      focusLabel: focusLabel,
      queueLabel: queueLabel,
      heroBlockLabel: heroBlockLabel,
      targetLabel: targetLabel,
      reviewWindowLabel: reviewWindowLabel,
      outcome: outcome,
      mainTargetResult: mainTargetResult,
      adherenceResult: adherenceResult,
      takeaway: takeaway,
      nextStep: nextStep,
      practiceNote: trimmedPracticeNote,
      shareText: _shareText(
        playerLabel: playerLabel,
        completionDateLabel: completionDateLabel,
        focusLabel: focusLabel,
        queueLabel: queueLabel,
        heroBlockLabel: heroBlockLabel,
        targetLabel: targetLabel,
        reviewWindowLabel: reviewWindowLabel,
        outcome: outcome,
        mainTargetResult: mainTargetResult,
        adherenceResult: adherenceResult,
        takeaway: takeaway,
        nextStep: nextStep,
        practiceNote: trimmedPracticeNote,
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
    required String focusLabel,
    required String queueLabel,
    required String heroBlockLabel,
    required String targetLabel,
    required String reviewWindowLabel,
    required String outcome,
    required String mainTargetResult,
    required String adherenceResult,
    required String takeaway,
    required String nextStep,
    required String? practiceNote,
  }) {
    return [
      'Dotes coaching handoff',
      'Player: $playerLabel',
      'Completed: $completionDateLabel',
      '',
      'Block setup',
      if (practiceNote != null) 'Practice note: $practiceNote',
      'Focus: $focusLabel',
      'Queue: $queueLabel',
      'Hero block: $heroBlockLabel',
      'Target: $targetLabel',
      'Review window: $reviewWindowLabel',
      '',
      'Result',
      'Outcome: $outcome',
      'Target result: $mainTargetResult',
      'Adherence: $adherenceResult',
      'Takeaway: $takeaway',
      'Next step: $nextStep',
    ].join('\n');
  }

  String? _trimmedPracticeNote(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  String _formatDate(DateTime value) {
    final month = _monthLabels[value.month - 1];
    return '$month ${value.day}, ${value.year}';
  }

  String _styledNextStep(
    String nextStep,
    TrainingCoachingStyle coachingStyle,
  ) {
    return switch (coachingStyle) {
      TrainingCoachingStyle.auto => nextStep,
      TrainingCoachingStyle.steady => _steadyNextStep(nextStep),
      TrainingCoachingStyle.direct => _directNextStep(nextStep),
    };
  }

  String _steadyNextStep(String nextStep) {
    return nextStep
        .replaceFirst(
          'Run the same block again.',
          'Run the same block again and keep it steady.',
        )
        .replaceFirst(
          'Keep the role, change the hero pair.',
          'Keep the role and make one steady hero-pair change.',
        );
  }

  String _directNextStep(String nextStep) {
    return nextStep
        .replaceFirst('Run the same block again.', 'Repeat the block.')
        .replaceFirst(
          'Keep the role, change the hero pair.',
          'Keep the role. Change the hero pair.',
        );
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
