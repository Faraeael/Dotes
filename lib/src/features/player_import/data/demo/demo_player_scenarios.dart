import '../../domain/models/demo_player_scenario.dart';
import '../../domain/models/imported_player_data.dart';
import '../../domain/models/imported_player_source.dart';
import '../../domain/models/player_profile_summary.dart';
import '../../domain/models/recent_match.dart';
import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../dashboard/domain/models/session_plan.dart';
import '../../../insights/domain/models/coaching_insight.dart';
import '../../../tester_feedback/domain/models/tester_feedback.dart';
import '../../../training_preferences/domain/models/training_preferences.dart';

final demoPlayerScenarios = <DemoPlayerScenario>[
  _strongComfortCoreScenario(),
  _wideNoisyPoolScenario(),
  _earlyDeathProblemScenario(),
  _completedOnTrackBlockScenario(),
  _completedOffTrackBlockScenario(),
  _lowSampleFallbackScenario(),
];

DemoPlayerScenario _strongComfortCoreScenario() {
  const accountId = 990001;

  return DemoPlayerScenario(
    id: 'strong_comfort_core',
    title: 'Strong comfort core',
    description:
        'A stable offlane sample anchored by Slardar and Mars with strong recent results.',
    importedPlayer: ImportedPlayerData(
      profile: _profile(
        accountId: accountId,
        name: 'Comfort Core Demo',
        rankTier: 51,
      ),
      recentMatches: [
        _offlaneMatch(91010, 28, 2026, 3, 31, kills: 9, deaths: 3, assists: 14, didWin: true),
        _offlaneMatch(91009, 129, 2026, 3, 30, kills: 7, deaths: 4, assists: 17, didWin: true),
        _offlaneMatch(91008, 28, 2026, 3, 29, kills: 10, deaths: 2, assists: 12, didWin: true),
        _offlaneMatch(91007, 129, 2026, 3, 28, kills: 6, deaths: 4, assists: 15, didWin: true),
        _offlaneMatch(91006, 28, 2026, 3, 27, kills: 8, deaths: 3, assists: 13, didWin: true),
        _offlaneMatch(91005, 129, 2026, 3, 26, kills: 5, deaths: 5, assists: 18, didWin: true),
        _offlaneMatch(91004, 28, 2026, 3, 25, kills: 7, deaths: 4, assists: 14, didWin: true),
        _offlaneMatch(91003, 96, 2026, 3, 24, kills: 3, deaths: 6, assists: 12, didWin: false),
        _offlaneMatch(91002, 135, 2026, 3, 23, kills: 4, deaths: 5, assists: 10, didWin: false),
        _offlaneMatch(91001, 29, 2026, 3, 22, kills: 5, deaths: 6, assists: 11, didWin: false),
      ],
      source: const ImportedPlayerSource.demoScenario(
        scenarioId: 'strong_comfort_core',
        scenarioLabel: 'Strong comfort core',
      ),
    ),
    trainingPreferences: const TrainingPreferences(),
    testerFeedback: TesterFeedback(
      rating: TesterFeedbackRating.clear,
      note: 'Comfort-core scenarios help validate the hero-block coaching copy.',
      playerLabel: 'Comfort Core Demo',
      savedAt: _savedAtMar31,
    ),
  );
}

DemoPlayerScenario _wideNoisyPoolScenario() {
  const accountId = 990002;

  return DemoPlayerScenario(
    id: 'wide_noisy_pool',
    title: 'Wide noisy pool',
    description:
        'A broad, mixed-role sample meant to trigger noisy-pool and specialization guidance.',
    importedPlayer: ImportedPlayerData(
      profile: _profile(
        accountId: accountId,
        name: 'Wide Pool Demo',
        rankTier: 44,
      ),
      recentMatches: [
        _carryMatch(92010, 8, 2026, 3, 31, kills: 8, deaths: 5, assists: 6, didWin: true),
        _midMatch(92009, 17, 2026, 3, 30, kills: 11, deaths: 7, assists: 9, didWin: false),
        _offlaneMatch(92008, 129, 2026, 3, 29, kills: 4, deaths: 6, assists: 15, didWin: true),
        _supportMatch(92007, 5, 2026, 3, 28, kills: 2, deaths: 7, assists: 18, didWin: false),
        _softSupportMatch(92006, 128, 2026, 3, 27, kills: 3, deaths: 8, assists: 17, didWin: false),
        _carryMatch(92005, 48, 2026, 3, 26, kills: 9, deaths: 4, assists: 7, didWin: true),
        _midMatch(92004, 74, 2026, 3, 25, kills: 10, deaths: 6, assists: 8, didWin: false),
        _offlaneMatch(92003, 96, 2026, 3, 24, kills: 5, deaths: 5, assists: 14, didWin: true),
        _supportMatch(92002, 50, 2026, 3, 23, kills: 1, deaths: 6, assists: 16, didWin: false),
        _carryMatch(92001, 67, 2026, 3, 22, kills: 7, deaths: 6, assists: 5, didWin: false),
      ],
      source: const ImportedPlayerSource.demoScenario(
        scenarioId: 'wide_noisy_pool',
        scenarioLabel: 'Wide noisy pool',
      ),
    ),
    trainingPreferences: const TrainingPreferences(
      coachingMode: TrainingCoachingMode.preferManualSetup,
      preferredRole: TrainingRolePreference.offlane,
      lockedHeroIds: [129, 96],
    ),
  );
}

DemoPlayerScenario _earlyDeathProblemScenario() {
  const accountId = 990003;

  return DemoPlayerScenario(
    id: 'early_death_problem',
    title: 'Early death problem',
    description:
        'A mid sample with repeat high-death games to exercise the deaths-focused plan and review copy.',
    importedPlayer: ImportedPlayerData(
      profile: _profile(
        accountId: accountId,
        name: 'Death Review Demo',
        rankTier: 46,
      ),
      recentMatches: [
        _midMatch(93010, 17, 2026, 3, 31, kills: 8, deaths: 10, assists: 9, didWin: false),
        _midMatch(93009, 17, 2026, 3, 30, kills: 9, deaths: 9, assists: 8, didWin: false),
        _midMatch(93008, 22, 2026, 3, 29, kills: 7, deaths: 11, assists: 10, didWin: false),
        _midMatch(93007, 17, 2026, 3, 28, kills: 10, deaths: 8, assists: 7, didWin: true),
        _midMatch(93006, 25, 2026, 3, 27, kills: 6, deaths: 9, assists: 11, didWin: false),
        _midMatch(93005, 17, 2026, 3, 26, kills: 11, deaths: 7, assists: 8, didWin: true),
        _midMatch(93004, 22, 2026, 3, 25, kills: 7, deaths: 9, assists: 12, didWin: false),
        _midMatch(93003, 25, 2026, 3, 24, kills: 8, deaths: 10, assists: 9, didWin: false),
        _midMatch(93002, 17, 2026, 3, 23, kills: 12, deaths: 8, assists: 6, didWin: true),
        _midMatch(93001, 22, 2026, 3, 22, kills: 9, deaths: 9, assists: 8, didWin: false),
      ],
      source: const ImportedPlayerSource.demoScenario(
        scenarioId: 'early_death_problem',
        scenarioLabel: 'Early death problem',
      ),
    ),
  );
}

DemoPlayerScenario _completedOnTrackBlockScenario() {
  const accountId = 990004;

  return DemoPlayerScenario(
    id: 'completed_on_track_block',
    title: 'Completed on-track block',
    description:
        'A finished offlane hero block with five newer in-block games and an on-track review.',
    importedPlayer: ImportedPlayerData(
      profile: _profile(
        accountId: accountId,
        name: 'On-Track Block Demo',
        rankTier: 49,
      ),
      recentMatches: [
        _offlaneMatch(94010, 28, 2026, 3, 31, kills: 8, deaths: 3, assists: 15, didWin: true),
        _offlaneMatch(94009, 129, 2026, 3, 30, kills: 7, deaths: 4, assists: 16, didWin: true),
        _offlaneMatch(94008, 28, 2026, 3, 29, kills: 6, deaths: 4, assists: 14, didWin: true),
        _offlaneMatch(94007, 129, 2026, 3, 28, kills: 5, deaths: 5, assists: 17, didWin: true),
        _offlaneMatch(94006, 28, 2026, 3, 27, kills: 7, deaths: 4, assists: 13, didWin: true),
        _offlaneMatch(94005, 96, 2026, 3, 21, kills: 3, deaths: 8, assists: 10, didWin: false),
        _offlaneMatch(94004, 135, 2026, 3, 20, kills: 4, deaths: 9, assists: 11, didWin: false),
        _offlaneMatch(94003, 29, 2026, 3, 19, kills: 5, deaths: 8, assists: 12, didWin: true),
        _offlaneMatch(94002, 96, 2026, 3, 18, kills: 2, deaths: 9, assists: 9, didWin: false),
        _offlaneMatch(94001, 129, 2026, 3, 17, kills: 5, deaths: 7, assists: 14, didWin: true),
      ],
      source: const ImportedPlayerSource.demoScenario(
        scenarioId: 'completed_on_track_block',
        scenarioLabel: 'Completed on-track block',
      ),
    ),
    checkpointHistory: [
      _historicalCheckpoint(
        accountId: accountId,
        savedAt: DateTime.utc(2026, 2, 20),
        averageDeaths: 7.4,
        uniqueHeroesPlayed: 4,
        recentWindow: const [
          CoachingCheckpointMatchSummary(matchId: 93995, heroId: 28, didWin: true),
          CoachingCheckpointMatchSummary(matchId: 93994, heroId: 129, didWin: false),
          CoachingCheckpointMatchSummary(matchId: 93993, heroId: 96, didWin: false),
          CoachingCheckpointMatchSummary(matchId: 93992, heroId: 29, didWin: true),
          CoachingCheckpointMatchSummary(matchId: 93991, heroId: 28, didWin: true),
        ],
      ),
      _historicalCheckpoint(
        accountId: accountId,
        savedAt: DateTime.utc(2026, 3, 26, 12),
        focusAction: 'Play the next 5 games on Slardar + Mars and keep deaths to 6 or fewer.',
        focusSourceLabel: 'Early death risk',
        topInsightType: CoachingInsightType.earlyDeathRisk,
        averageDeaths: 8.2,
        uniqueHeroesPlayed: 4,
        savedSessionPlan: const CoachingCheckpointSessionPlan(
          queue: 'Offlane only',
          heroBlock: 'Slardar + Mars',
          target: 'keep deaths to 6 or fewer',
          reviewWindow: 'next 5 games',
          targetType: SessionPlanTargetType.deaths,
          heroBlockHeroIds: [28, 129],
          heroBlockHeroLabels: ['Slardar', 'Mars'],
          roleBlockKey: 'offlane',
          usesManualRoleSetup: true,
          usesManualHeroBlock: true,
        ),
        savedTrainingPreferences: const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          preferredRole: TrainingRolePreference.offlane,
          lockedHeroIds: [28, 129],
        ),
        recentWindow: const [
          CoachingCheckpointMatchSummary(matchId: 94005, heroId: 96, didWin: false),
          CoachingCheckpointMatchSummary(matchId: 94004, heroId: 135, didWin: false),
          CoachingCheckpointMatchSummary(matchId: 94003, heroId: 29, didWin: true),
          CoachingCheckpointMatchSummary(matchId: 94002, heroId: 96, didWin: false),
          CoachingCheckpointMatchSummary(matchId: 94001, heroId: 129, didWin: true),
        ],
      ),
    ],
    trainingPreferences: const TrainingPreferences(
      coachingMode: TrainingCoachingMode.preferManualSetup,
      preferredRole: TrainingRolePreference.offlane,
      lockedHeroIds: [28, 129],
    ),
    testerFeedback: TesterFeedback(
      rating: TesterFeedbackRating.clear,
      note: 'This scenario should finish with an on-track review and a reusable end-block summary.',
      playerLabel: 'On-Track Block Demo',
      savedAt: _savedAtMar31,
    ),
  );
}

DemoPlayerScenario _completedOffTrackBlockScenario() {
  const accountId = 990005;

  return DemoPlayerScenario(
    id: 'completed_off_track_block',
    title: 'Completed off-track block',
    description:
        'A finished block where the player drifted outside the planned hero pair and the review lands off track.',
    importedPlayer: ImportedPlayerData(
      profile: _profile(
        accountId: accountId,
        name: 'Off-Track Block Demo',
        rankTier: 47,
      ),
      recentMatches: [
        _offlaneMatch(95010, 96, 2026, 3, 31, kills: 3, deaths: 9, assists: 10, didWin: false),
        _offlaneMatch(95009, 135, 2026, 3, 30, kills: 4, deaths: 10, assists: 9, didWin: false),
        _offlaneMatch(95008, 29, 2026, 3, 29, kills: 2, deaths: 8, assists: 11, didWin: false),
        _offlaneMatch(95007, 96, 2026, 3, 28, kills: 5, deaths: 9, assists: 12, didWin: true),
        _offlaneMatch(95006, 135, 2026, 3, 27, kills: 3, deaths: 8, assists: 10, didWin: false),
        _offlaneMatch(95005, 28, 2026, 3, 21, kills: 7, deaths: 5, assists: 15, didWin: true),
        _offlaneMatch(95004, 129, 2026, 3, 20, kills: 6, deaths: 6, assists: 14, didWin: true),
        _offlaneMatch(95003, 28, 2026, 3, 19, kills: 8, deaths: 5, assists: 13, didWin: true),
        _offlaneMatch(95002, 129, 2026, 3, 18, kills: 5, deaths: 6, assists: 16, didWin: true),
        _offlaneMatch(95001, 28, 2026, 3, 17, kills: 6, deaths: 5, assists: 12, didWin: true),
      ],
      source: const ImportedPlayerSource.demoScenario(
        scenarioId: 'completed_off_track_block',
        scenarioLabel: 'Completed off-track block',
      ),
    ),
    checkpointHistory: [
      _historicalCheckpoint(
        accountId: accountId,
        savedAt: DateTime.utc(2026, 2, 22),
        averageDeaths: 6.9,
        uniqueHeroesPlayed: 4,
        recentWindow: const [
          CoachingCheckpointMatchSummary(matchId: 94995, heroId: 28, didWin: true),
          CoachingCheckpointMatchSummary(matchId: 94994, heroId: 129, didWin: true),
          CoachingCheckpointMatchSummary(matchId: 94993, heroId: 96, didWin: false),
          CoachingCheckpointMatchSummary(matchId: 94992, heroId: 29, didWin: false),
          CoachingCheckpointMatchSummary(matchId: 94991, heroId: 28, didWin: true),
        ],
      ),
      _historicalCheckpoint(
        accountId: accountId,
        savedAt: DateTime.utc(2026, 3, 26, 12),
        focusAction: 'Stay on Slardar + Mars for five games and keep the block easy to review.',
        focusSourceLabel: 'Comfort hero dependence',
        topInsightType: CoachingInsightType.comfortHeroDependence,
        averageDeaths: 5.4,
        uniqueHeroesPlayed: 2,
        savedSessionPlan: const CoachingCheckpointSessionPlan(
          queue: 'Offlane only',
          heroBlock: 'Slardar + Mars',
          target: 'stay inside the block',
          reviewWindow: 'next 5 games',
          targetType: SessionPlanTargetType.comfortBlock,
          heroBlockHeroIds: [28, 129],
          heroBlockHeroLabels: ['Slardar', 'Mars'],
          roleBlockKey: 'offlane',
          usesManualRoleSetup: true,
          usesManualHeroBlock: true,
        ),
        savedTrainingPreferences: const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          preferredRole: TrainingRolePreference.offlane,
          lockedHeroIds: [28, 129],
        ),
        recentWindow: const [
          CoachingCheckpointMatchSummary(matchId: 95005, heroId: 28, didWin: true),
          CoachingCheckpointMatchSummary(matchId: 95004, heroId: 129, didWin: true),
          CoachingCheckpointMatchSummary(matchId: 95003, heroId: 28, didWin: true),
          CoachingCheckpointMatchSummary(matchId: 95002, heroId: 129, didWin: true),
          CoachingCheckpointMatchSummary(matchId: 95001, heroId: 28, didWin: true),
        ],
      ),
    ],
    trainingPreferences: const TrainingPreferences(
      coachingMode: TrainingCoachingMode.preferManualSetup,
      preferredRole: TrainingRolePreference.offlane,
      lockedHeroIds: [28, 129],
    ),
    testerFeedback: TesterFeedback(
      rating: TesterFeedbackRating.somewhatClear,
      note: 'Useful for checking that drift outside the block is called out clearly.',
      playerLabel: 'Off-Track Block Demo',
      savedAt: _savedAtMar31,
    ),
  );
}

DemoPlayerScenario _lowSampleFallbackScenario() {
  const accountId = 990006;

  return DemoPlayerScenario(
    id: 'low_sample_fallback',
    title: 'Low-sample fallback',
    description:
        'A tiny sample that should stay conservative and fall back to low-confidence messaging.',
    importedPlayer: ImportedPlayerData(
      profile: _profile(
        accountId: accountId,
        name: 'Low Sample Demo',
        rankTier: 37,
      ),
      recentMatches: [
        _carryMatch(96004, 48, 2026, 3, 31, kills: 7, deaths: 4, assists: 6, didWin: true),
        _carryMatch(96003, 67, 2026, 3, 30, kills: 5, deaths: 5, assists: 5, didWin: false),
        _carryMatch(96002, 8, 2026, 3, 29, kills: 9, deaths: 6, assists: 4, didWin: true),
        _carryMatch(96001, 54, 2026, 3, 28, kills: 6, deaths: 5, assists: 7, didWin: false),
      ],
      source: const ImportedPlayerSource.demoScenario(
        scenarioId: 'low_sample_fallback',
        scenarioLabel: 'Low-sample fallback',
      ),
    ),
  );
}

PlayerProfileSummary _profile({
  required int accountId,
  required String name,
  required int rankTier,
}) {
  return PlayerProfileSummary(
    accountId: accountId,
    personaName: name,
    avatarUrl: '',
    realName: 'Local demo scenario',
    rankTier: rankTier,
    leaderboardRank: null,
  );
}

CoachingCheckpoint _historicalCheckpoint({
  required int accountId,
  required DateTime savedAt,
  double averageDeaths = 6.2,
  int uniqueHeroesPlayed = 3,
  String focusAction = 'Stay on one role and no more than two heroes.',
  String focusSourceLabel = 'Weak recent trend',
  CoachingInsightType? topInsightType,
  CoachingCheckpointSessionPlan? savedSessionPlan,
  TrainingPreferences? savedTrainingPreferences,
  required List<CoachingCheckpointMatchSummary> recentWindow,
}) {
  return CoachingCheckpoint(
    accountId: accountId,
    savedAt: savedAt,
    focusAction: focusAction,
    focusSourceLabel: focusSourceLabel,
    topInsightType: topInsightType,
    sample: CoachingCheckpointSample(
      matchesAnalyzed: 10,
      wins: recentWindow.where((match) => match.didWin).length,
      losses: recentWindow.where((match) => !match.didWin).length,
      winRate: recentWindow.where((match) => match.didWin).length / recentWindow.length,
      uniqueHeroesPlayed: uniqueHeroesPlayed,
      averageDeaths: averageDeaths,
      likelyRoleSummaryLabel: 'Offlane',
      roleEstimateStrengthLabel: 'Strong estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'offlane',
      recentMatchesWindow: recentWindow,
    ),
    savedSessionPlan: savedSessionPlan,
    savedTrainingPreferences: savedTrainingPreferences,
  );
}

RecentMatch _carryMatch(
  int matchId,
  int heroId,
  int year,
  int month,
  int day, {
  required int kills,
  required int deaths,
  required int assists,
  required bool didWin,
}) {
  return _match(
    matchId,
    heroId,
    year,
    month,
    day,
    kills: kills,
    deaths: deaths,
    assists: assists,
    didWin: didWin,
    laneRole: 1,
    goldPerMin: 560,
    xpPerMin: 545,
    lastHits: 190,
  );
}

RecentMatch _midMatch(
  int matchId,
  int heroId,
  int year,
  int month,
  int day, {
  required int kills,
  required int deaths,
  required int assists,
  required bool didWin,
}) {
  return _match(
    matchId,
    heroId,
    year,
    month,
    day,
    kills: kills,
    deaths: deaths,
    assists: assists,
    didWin: didWin,
    laneRole: 2,
    goldPerMin: 505,
    xpPerMin: 575,
    lastHits: 132,
  );
}

RecentMatch _offlaneMatch(
  int matchId,
  int heroId,
  int year,
  int month,
  int day, {
  required int kills,
  required int deaths,
  required int assists,
  required bool didWin,
}) {
  return _match(
    matchId,
    heroId,
    year,
    month,
    day,
    kills: kills,
    deaths: deaths,
    assists: assists,
    didWin: didWin,
    laneRole: 3,
    goldPerMin: 435,
    xpPerMin: 515,
    lastHits: 124,
  );
}

RecentMatch _supportMatch(
  int matchId,
  int heroId,
  int year,
  int month,
  int day, {
  required int kills,
  required int deaths,
  required int assists,
  required bool didWin,
}) {
  return _match(
    matchId,
    heroId,
    year,
    month,
    day,
    kills: kills,
    deaths: deaths,
    assists: assists,
    didWin: didWin,
    laneRole: 1,
    goldPerMin: 340,
    xpPerMin: 410,
    lastHits: 32,
  );
}

RecentMatch _softSupportMatch(
  int matchId,
  int heroId,
  int year,
  int month,
  int day, {
  required int kills,
  required int deaths,
  required int assists,
  required bool didWin,
}) {
  return _match(
    matchId,
    heroId,
    year,
    month,
    day,
    kills: kills,
    deaths: deaths,
    assists: assists,
    didWin: didWin,
    laneRole: 3,
    goldPerMin: 360,
    xpPerMin: 420,
    lastHits: 44,
    isRoaming: true,
  );
}

RecentMatch _match(
  int matchId,
  int heroId,
  int year,
  int month,
  int day, {
  required int kills,
  required int deaths,
  required int assists,
  required bool didWin,
  required int laneRole,
  required int goldPerMin,
  required int xpPerMin,
  required int lastHits,
  bool isRoaming = false,
}) {
  return RecentMatch(
    matchId: matchId,
    heroId: heroId,
    startedAt: DateTime.utc(year, month, day, 12),
    duration: const Duration(minutes: 35),
    kills: kills,
    deaths: deaths,
    assists: assists,
    didWin: didWin,
    goldPerMin: goldPerMin,
    xpPerMin: xpPerMin,
    lastHits: lastHits,
    lane: laneRole == 2 ? 2 : 1,
    laneRole: laneRole,
    isRoaming: isRoaming,
    partySize: 1,
  );
}

final _savedAtMar31 = DateTime.utc(2026, 3, 31, 12);
