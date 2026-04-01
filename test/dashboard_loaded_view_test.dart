import 'package:dotes/src/features/checkpoints/domain/models/checkpoint_save_status_summary.dart';
import 'package:dotes/src/features/checkpoints/domain/models/training_block_action.dart';
import 'package:dotes/src/features/dashboard/domain/models/block_review.dart';
import 'package:dotes/src/features/dashboard/domain/models/comfort_core_summary.dart';
import 'package:dotes/src/features/dashboard/domain/models/dashboard_verdict.dart';
import 'package:dotes/src/features/dashboard/domain/models/dashboard_onboarding_guide.dart';
import 'package:dotes/src/features/dashboard/domain/models/end_block_summary.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/dashboard/domain/models/training_history.dart';
import 'package:dotes/src/features/dashboard/presentation/utils/imported_sample_summary.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/block_review_card.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/comfort_core_card.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/imported_sample_card.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/dashboard_loaded_view.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/end_block_summary_card.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/session_plan_card.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/training_history_card.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/verdict_card.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/insights/domain/models/next_games_focus.dart';
import 'package:dotes/src/features/matches/presentation/widgets/matches_overview_card.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/progress/domain/models/focus_follow_through_check.dart';
import 'package:dotes/src/features/progress/domain/models/progress_check.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback.dart';
import 'package:dotes/src/features/training_preferences/domain/models/coaching_source_summary.dart';
import 'package:dotes/src/features/training_preferences/presentation/widgets/training_setup_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardLoadedView', () {
    testWidgets('first-run explainer shown', (tester) async {
      await tester.pumpWidget(_DashboardLoadedViewHarness());

      expect(find.text('How coaching works'), findsOneWidget);
      expect(find.text('Step 1: Import recent matches'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });

    testWidgets('core section is always visible', (tester) async {
      await tester.pumpWidget(
        _DashboardLoadedViewHarness(
          key: const ValueKey('dashboard-harness'),
          dashboardVerdict: const DashboardVerdict(
            biggestLeak: DashboardVerdictLine(
              message: 'Deaths are the current leak.',
            ),
            biggestEdge: DashboardVerdictLine(
              message: 'Your hero pool is narrowing.',
            ),
          ),
          blockReview: const BlockReview(
            blockStatus: BlockReviewStatus.completed,
            gamesLogged: 5,
            blockSize: 5,
            adherence: BlockReviewAdherence.stayedInsideBlock,
            targetResult: BlockReviewTargetResult.improved,
            overallOutcome: BlockReviewOutcome.onTrack,
          ),
          sessionPlan: const SessionPlan(
            queue: 'Carry only',
            heroBlock: 'Slardar + Mars',
            target: 'stay inside the block',
            reviewWindow: 'next 5 games',
            targetType: SessionPlanTargetType.heroPool,
          ),
          nextGamesFocus: const NextGamesFocus(
            title: 'Next 5 games focus',
            action: 'Stay on one role and two heroes for the next block.',
            sourceLabel: 'Limited confidence',
          ),
          coachingSourceSummary: const CoachingSourceSummary(
            headline: 'Coaching source: App read',
            detail: 'Using the app read for role and hero block.',
          ),
          checkpointSaveStatusSummary: const CheckpointSaveStatusSummary(
            headline: 'No new matches since the last checkpoint.',
          ),
          focusFollowThrough: const FocusFollowThroughCheck.waiting(
            fallbackMessage: 'No previous coaching checkpoint yet.',
          ),
        ),
      );

      expect(find.text('Core coaching'), findsOneWidget);
      expect(find.byType(VerdictCard), findsOneWidget);
      expect(find.byType(BlockReviewCard), findsOneWidget);
      expect(find.byType(SessionPlanCard), findsOneWidget);
      expect(find.byType(TrainingSetupCard), findsOneWidget);
    });

    testWidgets('session plan shows the training block action panel', (
      tester,
    ) async {
      await tester.pumpWidget(
        const _DashboardLoadedViewHarness(
          trainingBlockActionControl: TrainingBlockActionControl(
            actionType: TrainingBlockActionType.start,
            blockStateLabel: 'No active block yet',
            blockStateDetail:
                'Start the current session plan before you queue the next 5 games.',
          ),
        ),
      );

      expect(find.text('Training block'), findsOneWidget);
      expect(find.text('No active block yet'), findsOneWidget);
      expect(find.text('Start this 5-game block'), findsOneWidget);
      expect(
        find.text(
          'This saves the current plan as the block you will review after 5 newer games.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders end block summary card when provided', (tester) async {
      await tester.pumpWidget(
        _DashboardLoadedViewHarness(
          endBlockSummary: EndBlockSummary(
            outcome: BlockReviewOutcome.onTrack,
            mainTargetResult: 'Improved',
            adherenceResult: 'Stayed in block',
            takeaway: 'You stayed inside the block and deaths improved.',
            nextStepSuggestion: 'Run the same block again.',
          ),
          onSaveEndBlockSummary: () {},
        ),
      );

      expect(find.byType(EndBlockSummaryCard), findsOneWidget);
      expect(find.text('End block summary'), findsOneWidget);
      expect(find.text('Takeaway: You stayed inside the block and deaths improved.'), findsOneWidget);
      expect(find.text('Next: Run the same block again.'), findsOneWidget);
      expect(find.text('Save summary'), findsOneWidget);
    });

    testWidgets('save summary action is hidden when summary is not completed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _DashboardLoadedViewHarness(onSaveEndBlockSummary: () {}),
      );

      expect(find.byType(EndBlockSummaryCard), findsNothing);
      expect(find.text('Save summary'), findsNothing);
    });

    testWidgets('uses the loaded player name in the app bar', (tester) async {
      await tester.pumpWidget(_DashboardLoadedViewHarness());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect((appBar.title as Text).data, 'Player');
    });

    testWidgets('details section collapses and expands', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_DashboardLoadedViewHarness());

      await tester.scrollUntilVisible(
        find.text('Details'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Current sample'), findsOneWidget);

      await tester.dragUntilVisible(
        find.text('Collapse details'),
        find.byType(ListView),
        const Offset(0, -120),
      );
      await tester.tap(find.text('Collapse details'));
      await tester.pumpAndSettle();

      expect(find.text('Current sample'), findsNothing);
      expect(
        find.text('Supporting cards are collapsed for now.'),
        findsOneWidget,
      );
      expect(find.byType(SessionPlanCard), findsOneWidget);
      expect(find.text('Import another account'), findsOneWidget);

      await tester.tap(find.text('Expand details'));
      await tester.pumpAndSettle();

      expect(find.text('Current sample'), findsOneWidget);
      expect(find.text('Training history'), findsOneWidget);
    });

    testWidgets('recent matches hide the raw match id line', (tester) async {
      await tester.pumpWidget(_DashboardLoadedViewHarness());

      await tester.scrollUntilVisible(
        find.text('Recent matches'),
        300,
        scrollable: find.byType(Scrollable),
      );

      expect(find.textContaining('Match #'), findsNothing);
    });

    testWidgets('cards render in the correct section order', (tester) async {
      await tester.pumpWidget(_DashboardLoadedViewHarness());

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('details-section')),
        300,
        scrollable: find.byType(Scrollable),
      );

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('core-coaching-section')),
          matching: find.byType(VerdictCard),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('core-coaching-section')),
          matching: find.byType(TrainingSetupCard),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('details-section')),
          matching: find.byType(ImportedSampleCard),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('details-section')),
          matching: find.byType(TrainingHistoryCard),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('details-section')),
          matching: find.text('Playtest feedback'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('feedback card shows the saved tester note', (tester) async {
      await tester.pumpWidget(
        const _DashboardLoadedViewHarness(
          testerFeedback: TesterFeedback(
            rating: TesterFeedbackRating.somewhatClear,
            note:
                'I would follow the session plan, but the verdict needed a reread.',
          ),
        ),
      );

      await tester.scrollUntilVisible(
        find.text(
          'I would follow the session plan, but the verdict needed a reread.',
        ),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Clarity: Somewhat clear'), findsOneWidget);
      expect(
        find.text(
          'I would follow the session plan, but the verdict needed a reread.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('fallback detail states still render cleanly', (tester) async {
      await tester.pumpWidget(
        _DashboardLoadedViewHarness(
          importedPlayer: _importedPlayer(matches: const []),
          sampleSummary: const ImportedSampleSummary(
            matchesAnalyzed: 0,
            wins: 0,
            losses: 0,
            winRateLabel: '0%',
            uniqueHeroesPlayed: 0,
            mostPlayedHeroLabel: null,
            primaryRoleLabel: 'Mixed / still estimating',
            roleReasonLabel: 'Need more games for a stable read.',
            roleMixDetailsLabel: null,
            roleReadLabel: 'Low-confidence estimate',
          ),
          trainingHistory: const TrainingHistory(
            entries: [],
            fallbackMessage:
                'No completed cycles yet \u2014 finish your first 5-game block to see history here.',
          ),
          progressCheck: const ProgressCheck.tooSmall(
            fallbackMessage: 'Need at least 5 matches to compare progress.',
          ),
          comfortCore: const ComfortCoreSummary(
            conclusionType: ComfortCoreConclusionType.tinySample,
            conclusion:
                'Need at least 6 matches before judging a comfort core.',
            totalMatches: 3,
            minimumMatches: 6,
            topHeroes: [],
            topHeroWins: 0,
            topHeroLosses: 0,
            otherHeroWins: 0,
            otherHeroLosses: 0,
          ),
          coachingInsights: const [],
        ),
      );

      await tester.scrollUntilVisible(
        find.text(
          'No completed cycles yet \u2014 finish your first 5-game block to see history here.',
        ),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(
        find.text(
          'No completed cycles yet \u2014 finish your first 5-game block to see history here.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Need at least 5 matches to compare progress.'),
        findsOneWidget,
      );
      expect(
        find.text('Need at least 6 matches before judging a comfort core.'),
        findsOneWidget,
      );
      expect(
        find.text('No strong coaching signals stand out in this sample.'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('No recent matches from OpenDota yet.'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('No recent matches from OpenDota yet.'), findsOneWidget);
    });

    testWidgets('comfort core hero chip can open a hero detail route', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 4200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _DashboardLoadedViewHarness(
          onOpenHeroDetail: (context, heroId) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(body: Text('Hero detail $heroId')),
              ),
            );
          },
        ),
      );

      await tester.scrollUntilVisible(
        find.byType(ComfortCoreCard),
        300,
        scrollable: find.byType(Scrollable),
      );
      final comfortHeroChip = find.descendant(
        of: find.byType(ComfortCoreCard),
        matching: find.text('Slardar (3 matches)'),
      );
      await tester.dragUntilVisible(
        comfortHeroChip,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(comfortHeroChip);
      await tester.pumpAndSettle();

      expect(find.text('Hero detail 28'), findsOneWidget);
    });

    testWidgets('recent match row can open a hero detail route', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 5200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _DashboardLoadedViewHarness(
          onOpenHeroDetail: (context, heroId) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(body: Text('Hero detail $heroId')),
              ),
            );
          },
        ),
      );

      await tester.scrollUntilVisible(
        find.byType(MatchesOverviewCard),
        300,
        scrollable: find.byType(Scrollable),
      );
      final recentMatchHero = find.descendant(
        of: find.byType(MatchesOverviewCard),
        matching: find.text('Slardar'),
      );
      await tester.dragUntilVisible(
        recentMatchHero,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(recentMatchHero);
      await tester.pumpAndSettle();

      expect(find.text('Hero detail 28'), findsOneWidget);
    });
  });
}

class _DashboardLoadedViewHarness extends StatefulWidget {
  const _DashboardLoadedViewHarness({
    this.importedPlayer,
    this.sampleSummary,
    this.coachingInsights = const [
      CoachingInsight(
        type: CoachingInsightType.earlyDeathRisk,
        title: 'Early death risk',
        explanation: 'Deaths are spiking before your midgame items.',
        severity: CoachingInsightSeverity.high,
        confidence: CoachingInsightConfidence.medium,
      ),
    ],
    this.dashboardVerdict = const DashboardVerdict(
      biggestLeak: DashboardVerdictLine(
        message: 'Deaths are the current leak.',
      ),
      biggestEdge: DashboardVerdictLine(
        message: 'Your hero pool is narrowing.',
      ),
    ),
    this.blockReview = const BlockReview(
      blockStatus: BlockReviewStatus.completed,
      gamesLogged: 5,
      blockSize: 5,
      adherence: BlockReviewAdherence.stayedInsideBlock,
      targetResult: BlockReviewTargetResult.improved,
      overallOutcome: BlockReviewOutcome.onTrack,
    ),
    this.endBlockSummary,
    this.onSaveEndBlockSummary,
    this.sessionPlan = const SessionPlan(
      queue: 'Carry only',
      heroBlock: 'Slardar + Mars',
      target: 'stay inside the block',
      reviewWindow: 'next 5 games',
      targetType: SessionPlanTargetType.heroPool,
    ),
    this.nextGamesFocus = const NextGamesFocus(
      title: 'Next 5 games focus',
      action: 'Stay on one role and two heroes for the next block.',
      sourceLabel: 'Limited confidence',
    ),
    this.coachingSourceSummary = const CoachingSourceSummary(
      headline: 'Coaching source: App read',
      detail: 'Using the app read for role and hero block.',
    ),
    this.trainingHistory = const TrainingHistory(
      entries: [],
      fallbackMessage:
          'No completed cycles yet \u2014 finish your first 5-game block to see history here.',
    ),
    this.checkpointSaveStatusSummary,
    this.progressCheck = const ProgressCheck.ready(
      blockSize: 5,
      comparisons: [
        ProgressMetricComparison(
          label: 'Deaths',
          direction: ProgressDirection.down,
          currentValueLabel: '5.4',
          previousValueLabel: '7.2',
        ),
      ],
    ),
    this.focusFollowThrough = const FocusFollowThroughCheck.waiting(
      fallbackMessage: 'No previous coaching checkpoint yet.',
    ),
    this.testerFeedback,
    this.comfortCore = const ComfortCoreSummary(
      conclusionType: ComfortCoreConclusionType.noClearCore,
      conclusion: 'Recent wins do not stay on one stable comfort core yet.',
      totalMatches: 10,
      minimumMatches: 6,
      topHeroes: [ComfortCoreHeroUsage(heroId: 28, matches: 3)],
      topHeroWins: 2,
      topHeroLosses: 1,
      otherHeroWins: 3,
      otherHeroLosses: 4,
    ),
    this.trainingBlockActionControl,
    this.onOpenHeroDetail,
    super.key,
  });

  final ImportedPlayerData? importedPlayer;
  final ImportedSampleSummary? sampleSummary;
  final List<CoachingInsight> coachingInsights;
  final DashboardVerdict dashboardVerdict;
  final BlockReview blockReview;
  final EndBlockSummary? endBlockSummary;
  final VoidCallback? onSaveEndBlockSummary;
  final SessionPlan sessionPlan;
  final NextGamesFocus nextGamesFocus;
  final CoachingSourceSummary coachingSourceSummary;
  final TrainingHistory trainingHistory;
  final CheckpointSaveStatusSummary? checkpointSaveStatusSummary;
  final ProgressCheck progressCheck;
  final FocusFollowThroughCheck focusFollowThrough;
  final TesterFeedback? testerFeedback;
  final ComfortCoreSummary comfortCore;
  final TrainingBlockActionControl? trainingBlockActionControl;
  final void Function(BuildContext context, int heroId)? onOpenHeroDetail;

  @override
  State<_DashboardLoadedViewHarness> createState() =>
      _DashboardLoadedViewHarnessState();
}

class _DashboardLoadedViewHarnessState
    extends State<_DashboardLoadedViewHarness> {
  bool _detailsExpanded = true;
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (navigatorContext) => DashboardLoadedView(
          importedPlayer: widget.importedPlayer ?? _importedPlayer(),
          sampleSummary: widget.sampleSummary ?? _sampleSummary(),
          coachingInsights: widget.coachingInsights,
          dashboardVerdict: widget.dashboardVerdict,
          blockReview: widget.blockReview,
          endBlockSummary: widget.endBlockSummary,
          sessionPlan: widget.sessionPlan,
          nextGamesFocus: widget.nextGamesFocus,
          onboardingGuide: _showOnboarding ? _onboardingGuide : null,
          coachingSourceSummary: widget.coachingSourceSummary,
          trainingHistory: widget.trainingHistory,
          checkpointSaveStatusSummary: widget.checkpointSaveStatusSummary,
          trainingBlockActionControl: widget.trainingBlockActionControl,
          isStartingTrainingBlock: false,
          progressCheck: widget.progressCheck,
          focusFollowThrough: widget.focusFollowThrough,
          testerFeedback: widget.testerFeedback,
          comfortCore: widget.comfortCore,
          detailsExpanded: _detailsExpanded,
          onToggleDetails: () {
            setState(() => _detailsExpanded = !_detailsExpanded);
          },
          onOpenHeroDetail: (heroId) {
            widget.onOpenHeroDetail?.call(navigatorContext, heroId);
          },
          onDismissOnboarding: () {
            setState(() => _showOnboarding = false);
          },
          onShowHowItWorks: () {
            setState(() => _showOnboarding = true);
          },
          onStartTrainingBlock: () {},
          onEditTrainingPreferences: () {},
          onEditTesterFeedback: () {},
          onShowPlaytestSummary: () {},
          onSaveEndBlockSummary: widget.onSaveEndBlockSummary,
          onGoToImport: () {},
        ),
      ),
    );
  }
}

ImportedPlayerData _importedPlayer({List<RecentMatch>? matches}) {
  return ImportedPlayerData(
    profile: const PlayerProfileSummary(
      accountId: 86745912,
      personaName: 'Player',
      avatarUrl: '',
      leaderboardRank: null,
    ),
    recentMatches:
        matches ??
        [
          RecentMatch(
            matchId: 9001,
            heroId: 28,
            startedAt: DateTime.utc(2025, 3, 20),
            duration: Duration(minutes: 30),
            kills: 8,
            deaths: 4,
            assists: 10,
            didWin: true,
            partySize: 1,
          ),
        ],
  );
}

ImportedSampleSummary _sampleSummary() {
  return const ImportedSampleSummary(
    matchesAnalyzed: 10,
    wins: 6,
    losses: 4,
    winRateLabel: '60%',
    uniqueHeroesPlayed: 3,
    mostPlayedHeroLabel: 'Slardar',
    primaryRoleLabel: 'Carry',
    roleReasonLabel: 'Recent matches lean toward one core role.',
    roleMixDetailsLabel: null,
    roleReadLabel: 'Strong estimate',
  );
}

const _onboardingGuide = DashboardOnboardingGuide(
  title: 'How coaching works',
  subtitle:
      'Import a sample, play one focused 5-game block, then re-import to review it.',
  steps: [
    DashboardOnboardingStep(
      title: 'Step 1: Import recent matches',
      description:
          'Load the latest sample so the app can read your role, hero pool, and trends.',
    ),
    DashboardOnboardingStep(
      title: 'Step 2: Follow the 5-game session plan',
      description:
          'Stick to the queue, hero block, and target so the block stays easy to judge.',
    ),
    DashboardOnboardingStep(
      title: 'Step 3: Re-import later to review the block',
      description:
          'Import newer matches so Block review and History can score the cycle.',
    ),
  ],
  cardHints: [
    DashboardOnboardingCardHint(
      title: 'Verdict',
      description: 'Quick read on the biggest leak or edge right now.',
    ),
    DashboardOnboardingCardHint(
      title: 'Block review',
      description:
          'Checks whether the last 5-game block stayed on plan and moved the target.',
    ),
    DashboardOnboardingCardHint(
      title: 'Session plan',
      description: 'Your next 5-game block: queue, hero block, and focus.',
    ),
    DashboardOnboardingCardHint(
      title: 'Training setup',
      description: 'Choose app read or lock a manual role and hero block.',
    ),
  ],
);
