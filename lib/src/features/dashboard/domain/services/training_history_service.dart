import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../insights/domain/models/coaching_insight.dart';
import '../../../progress/domain/models/focus_follow_through_check.dart';
import '../../../progress/domain/services/focus_follow_through_service.dart';
import '../models/training_history.dart';

class TrainingHistoryService {
  const TrainingHistoryService({
    FocusFollowThroughService followThroughService =
        const FocusFollowThroughService(),
    this.maxEntries = 4,
  }) : _followThroughService = followThroughService;

  final FocusFollowThroughService _followThroughService;
  final int maxEntries;

  TrainingHistory build(List<CoachingCheckpoint> checkpoints) {
    final sortedCheckpoints = checkpoints.toList(growable: true)
      ..sort(_compareCheckpointsBySavedAtAsc);
    if (sortedCheckpoints.length < 2) {
      return const TrainingHistory(
        entries: [],
        fallbackMessage:
            'No completed cycles yet \u2014 finish your first 5-game block to see history here.',
      );
    }

    final entries = <TrainingHistoryEntry>[
      for (var index = 0; index < sortedCheckpoints.length - 1; index++)
        _buildEntry(
          previousCheckpoint: sortedCheckpoints[index],
          currentCheckpoint: sortedCheckpoints[index + 1],
        ),
    ]..sort(_compareEntriesBySavedAtDesc);

    return TrainingHistory(
      entries: entries.take(maxEntries).toList(growable: false),
      fallbackMessage: null,
    );
  }

  TrainingHistoryEntry _buildEntry({
    required CoachingCheckpoint previousCheckpoint,
    required CoachingCheckpoint currentCheckpoint,
  }) {
    final followThroughCheck = _followThroughService.build(
      previousCheckpoint: previousCheckpoint,
      currentSample: currentCheckpoint.sample,
    );

    return TrainingHistoryEntry(
      savedAt: previousCheckpoint.savedAt,
      focusLabel:
          followThroughCheck.previousFocusLabel ??
          _fallbackFocusLabel(previousCheckpoint),
      outcome: _outcomeFromFollowThrough(followThroughCheck),
      resultSummary: _resultSummary(
        previousCheckpoint: previousCheckpoint,
        currentCheckpoint: currentCheckpoint,
        followThroughCheck: followThroughCheck,
      ),
    );
  }

  TrainingCycleOutcome _outcomeFromFollowThrough(
    FocusFollowThroughCheck followThroughCheck,
  ) {
    if (!followThroughCheck.isReady) {
      return TrainingCycleOutcome.mixed;
    }

    return switch (followThroughCheck.status!) {
      FocusFollowThroughStatus.onTrack => TrainingCycleOutcome.onTrack,
      FocusFollowThroughStatus.mixed => TrainingCycleOutcome.mixed,
      FocusFollowThroughStatus.offTrack => TrainingCycleOutcome.offTrack,
    };
  }

  String _resultSummary({
    required CoachingCheckpoint previousCheckpoint,
    required CoachingCheckpoint currentCheckpoint,
    required FocusFollowThroughCheck followThroughCheck,
  }) {
    final savedHeroBlock =
        previousCheckpoint.savedSessionPlanHeroBlock ??
        previousCheckpoint.focusHeroBlock;
    if (savedHeroBlock != null) {
      return _heroBlockSummary(
        heroBlock: savedHeroBlock,
        currentSample: currentCheckpoint.sample,
      );
    }

    return switch (previousCheckpoint.topInsightType) {
      CoachingInsightType.earlyDeathRisk => _deathsSummary(
        previousAverageDeaths: previousCheckpoint.sample.averageDeaths,
        currentAverageDeaths: currentCheckpoint.sample.averageDeaths,
      ),
      CoachingInsightType.heroPoolSpread ||
      CoachingInsightType.comfortHeroDependence ||
      CoachingInsightType.specializationRecommendation ||
      CoachingInsightType.weakRecentTrend => _heroPoolSummary(
        previousUniqueHeroes: previousCheckpoint.sample.uniqueHeroesPlayed,
        currentUniqueHeroes: currentCheckpoint.sample.uniqueHeroesPlayed,
      ),
      CoachingInsightType.limitedConfidence => _limitedConfidenceSummary(
        previousMatchesAnalyzed: previousCheckpoint.sample.matchesAnalyzed,
        currentMatchesAnalyzed: currentCheckpoint.sample.matchesAnalyzed,
      ),
      null =>
        followThroughCheck.isReady
            ? 'Block landed ${followThroughCheck.statusLabel!.toLowerCase()}.'
            : 'Sample stayed too noisy to judge cleanly.',
    };
  }

  String _heroBlockSummary({
    required CoachingCheckpointHeroBlock heroBlock,
    required CoachingCheckpointSample currentSample,
  }) {
    final recentWindow = currentSample.recentMatchesWindow
        .take(5)
        .toList(growable: false);
    if (recentWindow.isEmpty) {
      return 'Hero-block window was not saved for this cycle.';
    }

    final insideBlockCount = recentWindow
        .where((match) => heroBlock.heroIds.contains(match.heroId))
        .length;
    final label = _heroBlockLabel(heroBlock);
    if (insideBlockCount == 0) {
      return 'Drifted outside $label.';
    }

    return 'Stayed inside $label in $insideBlockCount of ${recentWindow.length} games.';
  }

  String _deathsSummary({
    required double previousAverageDeaths,
    required double currentAverageDeaths,
  }) {
    if (currentAverageDeaths <= previousAverageDeaths - 1) {
      return 'Deaths improved from ${_formatOneDecimal(previousAverageDeaths)} to ${_formatOneDecimal(currentAverageDeaths)}.';
    }

    if (currentAverageDeaths >= previousAverageDeaths + 1) {
      return 'Deaths worsened from ${_formatOneDecimal(previousAverageDeaths)} to ${_formatOneDecimal(currentAverageDeaths)}.';
    }

    return 'Deaths stayed near ${_formatOneDecimal(currentAverageDeaths)}.';
  }

  String _heroPoolSummary({
    required int previousUniqueHeroes,
    required int currentUniqueHeroes,
  }) {
    if (currentUniqueHeroes < previousUniqueHeroes) {
      return 'Hero pool narrowed from $previousUniqueHeroes to $currentUniqueHeroes.';
    }

    if (currentUniqueHeroes > previousUniqueHeroes) {
      return 'Hero pool widened instead of narrowing.';
    }

    return 'Hero pool stayed at ${_heroCount(currentUniqueHeroes)}.';
  }

  String _limitedConfidenceSummary({
    required int previousMatchesAnalyzed,
    required int currentMatchesAnalyzed,
  }) {
    if (currentMatchesAnalyzed > previousMatchesAnalyzed) {
      return 'Sample size grew from $previousMatchesAnalyzed to $currentMatchesAnalyzed matches.';
    }

    return 'Sample stayed too thin to judge cleanly.';
  }

  String _fallbackFocusLabel(CoachingCheckpoint checkpoint) {
    final savedHeroBlock =
        checkpoint.savedSessionPlanHeroBlock ?? checkpoint.focusHeroBlock;
    if (savedHeroBlock != null) {
      return savedHeroBlock.label;
    }

    final label = checkpoint.focusSourceLabel.trim();
    if (label.isNotEmpty) {
      return label;
    }

    return 'Saved coaching focus';
  }

  String _heroBlockLabel(CoachingCheckpointHeroBlock heroBlock) {
    if (heroBlock.heroLabels.isEmpty) {
      return 'your hero block';
    }

    if (heroBlock.heroLabels.length == 1) {
      return heroBlock.heroLabels.first;
    }

    return '${heroBlock.heroLabels.first} + ${heroBlock.heroLabels.last}';
  }

  String _formatOneDecimal(double value) => value.toStringAsFixed(1);

  String _heroCount(int count) => '$count ${count == 1 ? 'hero' : 'heroes'}';

  int _compareCheckpointsBySavedAtAsc(
    CoachingCheckpoint left,
    CoachingCheckpoint right,
  ) {
    final savedAtCompare = left.savedAt.compareTo(right.savedAt);
    if (savedAtCompare != 0) {
      return savedAtCompare;
    }

    return left.focusAction.compareTo(right.focusAction);
  }

  int _compareEntriesBySavedAtDesc(
    TrainingHistoryEntry left,
    TrainingHistoryEntry right,
  ) {
    final savedAtCompare = right.savedAt.compareTo(left.savedAt);
    if (savedAtCompare != 0) {
      return savedAtCompare;
    }

    return left.focusLabel.compareTo(right.focusLabel);
  }
}
