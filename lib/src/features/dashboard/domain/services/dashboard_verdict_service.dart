import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../insights/domain/models/coaching_insight.dart';
import '../../../insights/domain/models/next_games_focus.dart';
import '../../../progress/domain/models/focus_follow_through_check.dart';
import '../../../progress/domain/models/progress_check.dart';
import '../models/comfort_core_summary.dart';
import '../models/dashboard_verdict.dart';

class DashboardVerdictService {
  const DashboardVerdictService();

  DashboardVerdict build({
    required List<CoachingInsight> insights,
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
    required ProgressCheck? progressCheck,
    required FocusFollowThroughCheck? followThroughCheck,
    required CoachingCheckpoint? previousCheckpoint,
  }) {
    final leakCandidates = <_VerdictCandidate>[
      ..._followThroughLeakCandidates(followThroughCheck, previousCheckpoint),
      ..._insightLeakCandidates(insights),
      ..._progressLeakCandidates(progressCheck),
    ];
    final edgeCandidates = <_VerdictCandidate>[
      ..._followThroughEdgeCandidates(followThroughCheck, previousCheckpoint),
      ..._comfortCoreEdgeCandidates(comfortCore),
      ..._progressEdgeCandidates(progressCheck),
      ..._focusEdgeCandidates(nextGamesFocus),
    ];

    final biggestLeak = _pickStrongest(leakCandidates);
    final biggestEdge = _pickStrongest(edgeCandidates);
    final confidenceLabel = _confidenceLabel(
      nextGamesFocus: nextGamesFocus,
      previousCheckpoint: previousCheckpoint,
      progressCheck: progressCheck,
    );
    final reasonLabel = _reasonLabel(
      insights: insights,
      nextGamesFocus: nextGamesFocus,
      previousCheckpoint: previousCheckpoint,
      progressCheck: progressCheck,
    );

    return DashboardVerdict(
      biggestLeak: biggestLeak == null
          ? null
          : DashboardVerdictLine(message: biggestLeak.message),
      biggestEdge: biggestEdge == null
          ? null
          : DashboardVerdictLine(message: biggestEdge.message),
      fallbackMessage: biggestLeak == null && biggestEdge == null
          ? 'Current sample is still too noisy for a strong verdict.'
          : null,
      confidenceLabel: confidenceLabel,
      reasonLabel: reasonLabel,
    );
  }

  String _confidenceLabel({
    required NextGamesFocus? nextGamesFocus,
    required CoachingCheckpoint? previousCheckpoint,
    required ProgressCheck? progressCheck,
  }) {
    if (nextGamesFocus?.sourceType == CoachingInsightType.limitedConfidence) {
      return 'Limited confidence';
    }

    if (previousCheckpoint != null && progressCheck?.isReady == true) {
      return 'Stronger read';
    }

    if (previousCheckpoint != null) {
      return 'Sample-backed read';
    }

    return 'Conservative read';
  }

  String _reasonLabel({
    required List<CoachingInsight> insights,
    required NextGamesFocus? nextGamesFocus,
    required CoachingCheckpoint? previousCheckpoint,
    required ProgressCheck? progressCheck,
  }) {
    if (nextGamesFocus?.sourceType == CoachingInsightType.limitedConfidence) {
      return 'Current sample is still noisy, so the verdict is directional rather than final.';
    }

    if (previousCheckpoint != null && progressCheck?.isReady == true) {
      return 'This verdict can compare the current sample against your last started block and recent trend changes.';
    }

    if (previousCheckpoint != null) {
      return 'This verdict can compare the current sample against your last started block, but the read still stays conservative.';
    }

    if (insights.isNotEmpty) {
      return 'This verdict is based on your strongest recent-match signal and stays conservative when the sample is broad.';
    }

    return 'There is only a light signal right now, so the app avoids stronger claims.';
  }

  List<_VerdictCandidate> _followThroughLeakCandidates(
    FocusFollowThroughCheck? followThroughCheck,
    CoachingCheckpoint? previousCheckpoint,
  ) {
    if (followThroughCheck == null ||
        !followThroughCheck.isReady ||
        previousCheckpoint == null) {
      return const [];
    }

    if (previousCheckpoint.focusHeroBlock != null) {
      return switch (followThroughCheck.status!) {
        FocusFollowThroughStatus.onTrack => const [],
        FocusFollowThroughStatus.mixed => const [
          _VerdictCandidate(
            message:
                'You only partly stayed inside the last recommended hero block.',
            priority: 85,
            order: 0,
          ),
        ],
        FocusFollowThroughStatus.offTrack => const [
          _VerdictCandidate(
            message: 'You drifted outside the last recommended hero block.',
            priority: 100,
            order: 0,
          ),
        ],
      };
    }

    return switch (previousCheckpoint.topInsightType) {
      CoachingInsightType.earlyDeathRisk =>
        followThroughCheck.status == FocusFollowThroughStatus.onTrack
            ? const []
            : const [
                _VerdictCandidate(
                  message: 'Deaths are still above the current focus target.',
                  priority: 95,
                  order: 1,
                ),
              ],
      CoachingInsightType.heroPoolSpread =>
        followThroughCheck.status == FocusFollowThroughStatus.offTrack
            ? const [
                _VerdictCandidate(
                  message: 'Your recent pool widened again.',
                  priority: 85,
                  order: 2,
                ),
              ]
            : const [],
      CoachingInsightType.weakRecentTrend ||
      CoachingInsightType.specializationRecommendation =>
        followThroughCheck.status == FocusFollowThroughStatus.offTrack
            ? const [
                _VerdictCandidate(
                  message: 'The recent block is still too unstable.',
                  priority: 80,
                  order: 3,
                ),
              ]
            : const [],
      CoachingInsightType.comfortHeroDependence ||
      CoachingInsightType.limitedConfidence ||
      null => const [],
    };
  }

  List<_VerdictCandidate> _followThroughEdgeCandidates(
    FocusFollowThroughCheck? followThroughCheck,
    CoachingCheckpoint? previousCheckpoint,
  ) {
    if (followThroughCheck == null ||
        !followThroughCheck.isReady ||
        previousCheckpoint == null ||
        followThroughCheck.status != FocusFollowThroughStatus.onTrack) {
      return const [];
    }

    if (previousCheckpoint.focusHeroBlock != null) {
      return const [
        _VerdictCandidate(
          message: 'You stayed inside the last recommended hero block.',
          priority: 100,
          order: 0,
        ),
      ];
    }

    return switch (previousCheckpoint.topInsightType) {
      CoachingInsightType.earlyDeathRisk => const [
        _VerdictCandidate(
          message: 'Deaths are moving closer to the current focus target.',
          priority: 90,
          order: 1,
        ),
      ],
      CoachingInsightType.heroPoolSpread => const [
        _VerdictCandidate(
          message: 'You kept the recent hero pool tighter.',
          priority: 85,
          order: 2,
        ),
      ],
      CoachingInsightType.weakRecentTrend ||
      CoachingInsightType.specializationRecommendation => const [
        _VerdictCandidate(
          message: 'You held a cleaner coaching block.',
          priority: 80,
          order: 3,
        ),
      ],
      CoachingInsightType.comfortHeroDependence ||
      CoachingInsightType.limitedConfidence ||
      null => const [],
    };
  }

  List<_VerdictCandidate> _insightLeakCandidates(
    List<CoachingInsight> insights,
  ) {
    final topInsight = insights.isEmpty ? null : insights.first;
    if (topInsight == null) {
      return const [];
    }

    final priority = 60 + (topInsight.severity.sortWeight * 10);

    return switch (topInsight.type) {
      CoachingInsightType.earlyDeathRisk => [
        _VerdictCandidate(
          message: 'Deaths are still too high.',
          priority: priority,
          order: 10,
        ),
      ],
      CoachingInsightType.heroPoolSpread => [
        _VerdictCandidate(
          message: 'Your recent pool is still too wide.',
          priority: priority,
          order: 11,
        ),
      ],
      CoachingInsightType.weakRecentTrend => [
        _VerdictCandidate(
          message: 'Recent results are still below break-even.',
          priority: priority,
          order: 12,
        ),
      ],
      CoachingInsightType.specializationRecommendation => [
        _VerdictCandidate(
          message: 'Your sample is still too broad to read cleanly.',
          priority: priority,
          order: 13,
        ),
      ],
      CoachingInsightType.comfortHeroDependence ||
      CoachingInsightType.limitedConfidence => const [],
    };
  }

  List<_VerdictCandidate> _comfortCoreEdgeCandidates(
    ComfortCoreSummary? comfortCore,
  ) {
    if (comfortCore == null || !comfortCore.isReady) {
      return const [];
    }

    if (comfortCore.conclusionType ==
            ComfortCoreConclusionType.successInsideCore ||
        comfortCore.conclusionType == ComfortCoreConclusionType.outsideWeaker) {
      return const [
        _VerdictCandidate(
          message: 'Your best results are inside a small comfort core.',
          priority: 75,
          order: 20,
        ),
      ];
    }

    return const [];
  }

  List<_VerdictCandidate> _progressLeakCandidates(
    ProgressCheck? progressCheck,
  ) {
    if (progressCheck == null || !progressCheck.isReady) {
      return const [];
    }

    return [
      for (final comparison in progressCheck.comparisons)
        if (comparison.label == 'Win rate' &&
            comparison.direction == ProgressDirection.down)
          const _VerdictCandidate(
            message: 'Recent results are trending down.',
            priority: 50,
            order: 30,
          )
        else if (comparison.label == 'Deaths' &&
            comparison.direction == ProgressDirection.up)
          const _VerdictCandidate(
            message: 'Deaths are trending the wrong way.',
            priority: 55,
            order: 31,
          )
        else if (comparison.label == 'Hero pool' &&
            comparison.direction == ProgressDirection.wider)
          const _VerdictCandidate(
            message: 'Your recent pool is getting wider again.',
            priority: 50,
            order: 32,
          ),
    ];
  }

  List<_VerdictCandidate> _progressEdgeCandidates(
    ProgressCheck? progressCheck,
  ) {
    if (progressCheck == null || !progressCheck.isReady) {
      return const [];
    }

    return [
      for (final comparison in progressCheck.comparisons)
        if (comparison.label == 'Win rate' &&
            comparison.direction == ProgressDirection.up)
          const _VerdictCandidate(
            message: 'Your win rate is moving up.',
            priority: 50,
            order: 40,
          )
        else if (comparison.label == 'Deaths' &&
            comparison.direction == ProgressDirection.down)
          const _VerdictCandidate(
            message: 'Deaths are moving in the right direction.',
            priority: 55,
            order: 41,
          )
        else if (comparison.label == 'Hero pool' &&
            comparison.direction == ProgressDirection.narrower)
          const _VerdictCandidate(
            message: 'Your recent pool is getting tighter.',
            priority: 50,
            order: 42,
          ),
    ];
  }

  List<_VerdictCandidate> _focusEdgeCandidates(NextGamesFocus? nextGamesFocus) {
    if (nextGamesFocus?.heroBlock == null) {
      return const [];
    }

    return const [
      _VerdictCandidate(
        message: 'You have a clear hero block to lean on.',
        priority: 20,
        order: 50,
      ),
    ];
  }

  _VerdictCandidate? _pickStrongest(List<_VerdictCandidate> candidates) {
    return candidates.fold<_VerdictCandidate?>(null, (best, candidate) {
      if (best == null) {
        return candidate;
      }

      if (candidate.priority > best.priority) {
        return candidate;
      }

      if (candidate.priority == best.priority && candidate.order < best.order) {
        return candidate;
      }

      return best;
    });
  }
}

class _VerdictCandidate {
  const _VerdictCandidate({
    required this.message,
    required this.priority,
    required this.order,
  });

  final String message;
  final int priority;
  final int order;
}
