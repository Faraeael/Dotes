import 'dart:convert';

import '../../../dashboard/domain/models/session_plan.dart';
import '../../../insights/domain/models/coaching_insight.dart';
import '../../../insights/domain/models/next_games_focus.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import '../../../roles/domain/models/sample_role_summary.dart';
import '../../../training_preferences/domain/models/training_preferences.dart';

class CoachingCheckpointDraft {
  const CoachingCheckpointDraft({
    required this.accountId,
    required this.focusAction,
    required this.focusSourceLabel,
    required this.topInsightType,
    required this.sample,
    this.focusHeroBlock,
    this.savedSessionPlan,
    this.savedTrainingPreferences,
  });

  final int accountId;
  final String focusAction;
  final String focusSourceLabel;
  final CoachingInsightType? topInsightType;
  final CoachingCheckpointSample sample;
  final CoachingCheckpointHeroBlock? focusHeroBlock;
  final CoachingCheckpointSessionPlan? savedSessionPlan;
  final TrainingPreferences? savedTrainingPreferences;

  String get blockFingerprint => sample.reviewedBlockFingerprint;

  String get fingerprint => jsonEncode({
    'accountId': accountId,
    'focusAction': focusAction,
    'focusSourceLabel': focusSourceLabel,
    'topInsightType': topInsightType?.name,
    'focusHeroBlock': focusHeroBlock?.toJson(),
    'savedSessionPlan': savedSessionPlan?.toJson(),
    'savedTrainingPreferences': savedTrainingPreferences?.toJson(),
    'blockFingerprint': blockFingerprint,
    'sample': sample.toJson(),
  });

  CoachingCheckpointDraft withSavedContext({
    CoachingCheckpointSessionPlan? savedSessionPlan,
    TrainingPreferences? savedTrainingPreferences,
  }) {
    return CoachingCheckpointDraft(
      accountId: accountId,
      focusAction: focusAction,
      focusSourceLabel: focusSourceLabel,
      topInsightType: topInsightType,
      sample: sample,
      focusHeroBlock: focusHeroBlock,
      savedSessionPlan: savedSessionPlan ?? this.savedSessionPlan,
      savedTrainingPreferences:
          savedTrainingPreferences ?? this.savedTrainingPreferences,
    );
  }

  CoachingCheckpoint toCheckpoint(DateTime savedAt) {
    return CoachingCheckpoint(
      accountId: accountId,
      savedAt: savedAt,
      focusAction: focusAction,
      focusSourceLabel: focusSourceLabel,
      topInsightType: topInsightType,
      focusHeroBlock: focusHeroBlock,
      savedSessionPlan: savedSessionPlan,
      savedTrainingPreferences: savedTrainingPreferences,
      savedBlockFingerprint: blockFingerprint,
      sample: sample,
    );
  }
}

class CoachingCheckpoint {
  const CoachingCheckpoint({
    required this.accountId,
    required this.savedAt,
    required this.focusAction,
    required this.focusSourceLabel,
    required this.topInsightType,
    required this.sample,
    this.focusHeroBlock,
    this.savedSessionPlan,
    this.savedTrainingPreferences,
    this.savedBlockFingerprint,
  });

  final int accountId;
  final DateTime savedAt;
  final String focusAction;
  final String focusSourceLabel;
  final CoachingInsightType? topInsightType;
  final CoachingCheckpointSample sample;
  final CoachingCheckpointHeroBlock? focusHeroBlock;
  final CoachingCheckpointSessionPlan? savedSessionPlan;
  final TrainingPreferences? savedTrainingPreferences;
  final String? savedBlockFingerprint;

  String get blockFingerprint {
    final storedValue = savedBlockFingerprint?.trim();
    if (storedValue != null && storedValue.isNotEmpty) {
      return storedValue;
    }

    return sample.reviewedBlockFingerprint;
  }

  CoachingCheckpointHeroBlock? get savedSessionPlanHeroBlock {
    final sessionPlan = savedSessionPlan;
    if (sessionPlan == null || sessionPlan.heroBlockHeroIds.isEmpty) {
      return null;
    }

    final matches = sample.recentMatchesWindow
        .where((match) => sessionPlan.heroBlockHeroIds.contains(match.heroId))
        .toList(growable: false);
    final wins = matches.where((match) => match.didWin).length;
    return CoachingCheckpointHeroBlock(
      heroIds: sessionPlan.heroBlockHeroIds,
      heroLabels: sessionPlan.heroBlockHeroLabels,
      wins: wins,
      losses: matches.length - wins,
    );
  }

  String get fingerprint => jsonEncode({
    'accountId': accountId,
    'focusAction': focusAction,
    'focusSourceLabel': focusSourceLabel,
    'topInsightType': topInsightType?.name,
    'focusHeroBlock': focusHeroBlock?.toJson(),
    'savedSessionPlan': savedSessionPlan?.toJson(),
    'savedTrainingPreferences': savedTrainingPreferences?.toJson(),
    'blockFingerprint': blockFingerprint,
    'sample': sample.toJson(),
  });

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'savedAt': savedAt.toUtc().toIso8601String(),
      'focusAction': focusAction,
      'focusSourceLabel': focusSourceLabel,
      'topInsightType': topInsightType?.name,
      'focusHeroBlock': focusHeroBlock?.toJson(),
      'savedSessionPlan': savedSessionPlan?.toJson(),
      'savedTrainingPreferences': savedTrainingPreferences?.toJson(),
      'savedBlockFingerprint': blockFingerprint,
      'sample': sample.toJson(),
    };
  }

  factory CoachingCheckpoint.fromJson(Map<String, dynamic> json) {
    return CoachingCheckpoint(
      accountId: json['accountId'] as int? ?? 0,
      savedAt: DateTime.parse(
        json['savedAt'] as String? ??
            DateTime.fromMillisecondsSinceEpoch(0).toUtc().toIso8601String(),
      ).toUtc(),
      focusAction: json['focusAction'] as String? ?? '',
      focusSourceLabel: json['focusSourceLabel'] as String? ?? '',
      topInsightType: _readInsightType(json['topInsightType'] as String?),
      focusHeroBlock: CoachingCheckpointHeroBlock.fromJsonOrNull(
        json['focusHeroBlock'],
      ),
      savedSessionPlan: CoachingCheckpointSessionPlan.fromJsonOrNull(
        json['savedSessionPlan'],
      ),
      savedTrainingPreferences: _readTrainingPreferences(
        json['savedTrainingPreferences'],
      ),
      savedBlockFingerprint: json['savedBlockFingerprint'] as String?,
      sample: CoachingCheckpointSample.fromJson(
        Map<String, dynamic>.from(
          json['sample'] as Map<dynamic, dynamic>? ?? const {},
        ),
      ),
    );
  }

  static CoachingInsightType? _readInsightType(String? value) {
    if (value == null) {
      return null;
    }

    for (final type in CoachingInsightType.values) {
      if (type.name == value) {
        return type;
      }
    }

    return null;
  }

  static TrainingPreferences? _readTrainingPreferences(dynamic value) {
    if (value is! Map<dynamic, dynamic>) {
      return null;
    }

    return TrainingPreferences.fromJson(Map<String, dynamic>.from(value));
  }
}

class CoachingCheckpointSessionPlan {
  const CoachingCheckpointSessionPlan({
    required this.queue,
    required this.heroBlock,
    required this.target,
    required this.reviewWindow,
    required this.targetType,
    required this.heroBlockHeroIds,
    required this.heroBlockHeroLabels,
    required this.usesManualRoleSetup,
    required this.usesManualHeroBlock,
    this.roleBlockKey,
  });

  final String queue;
  final String heroBlock;
  final String target;
  final String reviewWindow;
  final SessionPlanTargetType targetType;
  final List<int> heroBlockHeroIds;
  final List<String> heroBlockHeroLabels;
  final String? roleBlockKey;
  final bool usesManualRoleSetup;
  final bool usesManualHeroBlock;

  factory CoachingCheckpointSessionPlan.fromSessionPlan(
    SessionPlan sessionPlan, {
    required List<String> heroBlockHeroLabels,
  }) {
    return CoachingCheckpointSessionPlan(
      queue: sessionPlan.queue,
      heroBlock: sessionPlan.heroBlock,
      target: sessionPlan.target,
      reviewWindow: sessionPlan.reviewWindow,
      targetType: sessionPlan.targetType,
      heroBlockHeroIds: sessionPlan.heroBlockHeroIds,
      heroBlockHeroLabels: heroBlockHeroLabels,
      roleBlockKey: sessionPlan.roleBlockKey,
      usesManualRoleSetup: sessionPlan.usesManualRoleSetup,
      usesManualHeroBlock: sessionPlan.usesManualHeroBlock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'queue': queue,
      'heroBlock': heroBlock,
      'target': target,
      'reviewWindow': reviewWindow,
      'targetType': targetType.name,
      'heroBlockHeroIds': heroBlockHeroIds,
      'heroBlockHeroLabels': heroBlockHeroLabels,
      'roleBlockKey': roleBlockKey,
      'usesManualRoleSetup': usesManualRoleSetup,
      'usesManualHeroBlock': usesManualHeroBlock,
    };
  }

  static CoachingCheckpointSessionPlan? fromJsonOrNull(dynamic value) {
    if (value is! Map<dynamic, dynamic>) {
      return null;
    }

    final json = Map<String, dynamic>.from(value);
    final heroBlockHeroIds = (json['heroBlockHeroIds'] as List<dynamic>? ??
            const [])
        .whereType<num>()
        .map((heroId) => heroId.toInt())
        .toList(growable: false);
    final rawLabels = (json['heroBlockHeroLabels'] as List<dynamic>? ??
            const [])
        .whereType<String>()
        .map((label) => label.trim())
        .toList(growable: false);
    final heroBlockHeroLabels = [
      for (var index = 0; index < heroBlockHeroIds.length; index++)
        index < rawLabels.length && rawLabels[index].isNotEmpty
            ? rawLabels[index]
            : 'Hero ${heroBlockHeroIds[index]}',
    ];

    return CoachingCheckpointSessionPlan(
      queue: json['queue'] as String? ?? '',
      heroBlock: json['heroBlock'] as String? ?? '',
      target: json['target'] as String? ?? '',
      reviewWindow: json['reviewWindow'] as String? ?? '',
      targetType: _readTargetType(json['targetType'] as String?),
      heroBlockHeroIds: heroBlockHeroIds,
      heroBlockHeroLabels: heroBlockHeroLabels,
      roleBlockKey: json['roleBlockKey'] as String?,
      usesManualRoleSetup: json['usesManualRoleSetup'] as bool? ?? false,
      usesManualHeroBlock: json['usesManualHeroBlock'] as bool? ?? false,
    );
  }

  static SessionPlanTargetType _readTargetType(String? value) {
    for (final targetType in SessionPlanTargetType.values) {
      if (targetType.name == value) {
        return targetType;
      }
    }

    return SessionPlanTargetType.heroPool;
  }
}

class CoachingCheckpointSample {
  const CoachingCheckpointSample({
    required this.matchesAnalyzed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.uniqueHeroesPlayed,
    required this.averageDeaths,
    required this.likelyRoleSummaryLabel,
    required this.roleEstimateStrengthLabel,
    required this.hasClearRoleEstimate,
    required this.primaryRoleKey,
    this.recentMatchesWindow = const [],
  });

  final int matchesAnalyzed;
  final int wins;
  final int losses;
  final double winRate;
  final int uniqueHeroesPlayed;
  final double averageDeaths;
  final String likelyRoleSummaryLabel;
  final String roleEstimateStrengthLabel;
  final bool hasClearRoleEstimate;
  final String? primaryRoleKey;
  final List<CoachingCheckpointMatchSummary> recentMatchesWindow;

  int? get latestMatchId {
    var latestMatchId = 0;
    for (final match in recentMatchesWindow) {
      if (match.matchId > 0) {
        latestMatchId = latestMatchId < match.matchId
            ? match.matchId
            : latestMatchId;
      }
    }

    return latestMatchId > 0 ? latestMatchId : null;
  }

  List<String> get recentWindowTokens => recentMatchesWindow
      .map((match) => match.windowToken)
      .toList(growable: false);

  String get reviewedBlockFingerprint => recentWindowTokens.join('|');

  String get reviewedBlockSignature => reviewedBlockFingerprint;

  factory CoachingCheckpointSample.fromImportedPlayer(
    ImportedPlayerData importedPlayer,
    SampleRoleSummary roleSummary,
  ) {
    final matches = [...importedPlayer.recentMatches]
      ..sort((left, right) {
        final startedAtCompare = right.startedAt.compareTo(left.startedAt);
        if (startedAtCompare != 0) {
          return startedAtCompare;
        }

        return right.matchId.compareTo(left.matchId);
      });
    final wins = matches.where((match) => match.didWin).length;
    final losses = matches.length - wins;
    final totalDeaths = matches.fold<int>(
      0,
      (sum, match) => sum + match.deaths,
    );

    return CoachingCheckpointSample(
      matchesAnalyzed: matches.length,
      wins: wins,
      losses: losses,
      winRate: matches.isEmpty ? 0 : wins / matches.length,
      uniqueHeroesPlayed: matches.map((match) => match.heroId).toSet().length,
      averageDeaths: matches.isEmpty ? 0 : totalDeaths / matches.length,
      likelyRoleSummaryLabel: roleSummary.primaryRoleLabel,
      roleEstimateStrengthLabel: roleSummary.estimateStrengthLabel,
      hasClearRoleEstimate: roleSummary.hasClearPrimaryRole,
      primaryRoleKey: roleSummary.hasClearPrimaryRole
          ? roleSummary.primaryRole.name
          : null,
      recentMatchesWindow: matches
          .take(5)
          .map(
            (match) => CoachingCheckpointMatchSummary(
              matchId: match.matchId,
              heroId: match.heroId,
              didWin: match.didWin,
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchesAnalyzed': matchesAnalyzed,
      'wins': wins,
      'losses': losses,
      'winRate': winRate,
      'uniqueHeroesPlayed': uniqueHeroesPlayed,
      'averageDeaths': averageDeaths,
      'likelyRoleSummaryLabel': likelyRoleSummaryLabel,
      'roleEstimateStrengthLabel': roleEstimateStrengthLabel,
      'hasClearRoleEstimate': hasClearRoleEstimate,
      'primaryRoleKey': primaryRoleKey,
      'recentMatchesWindow': [
        for (final match in recentMatchesWindow) match.toJson(),
      ],
    };
  }

  factory CoachingCheckpointSample.fromJson(Map<String, dynamic> json) {
    return CoachingCheckpointSample(
      matchesAnalyzed: _readInt(json['matchesAnalyzed']),
      wins: _readInt(json['wins']),
      losses: _readInt(json['losses']),
      winRate: _readDouble(json['winRate']),
      uniqueHeroesPlayed: _readInt(json['uniqueHeroesPlayed']),
      averageDeaths: _readDouble(json['averageDeaths']),
      likelyRoleSummaryLabel: json['likelyRoleSummaryLabel'] as String? ?? '',
      roleEstimateStrengthLabel:
          json['roleEstimateStrengthLabel'] as String? ?? '',
      hasClearRoleEstimate: json['hasClearRoleEstimate'] as bool? ?? false,
      primaryRoleKey: json['primaryRoleKey'] as String?,
      recentMatchesWindow:
          (json['recentMatchesWindow'] as List<dynamic>? ?? const [])
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (match) => CoachingCheckpointMatchSummary.fromJson(
                  Map<String, dynamic>.from(match),
                ),
              )
              .toList(growable: false),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }
}

class CoachingCheckpointHeroBlock {
  const CoachingCheckpointHeroBlock({
    required this.heroIds,
    required this.heroLabels,
    required this.wins,
    required this.losses,
  });

  final List<int> heroIds;
  final List<String> heroLabels;
  final int wins;
  final int losses;

  int get matches => wins + losses;

  double get winRate => matches == 0 ? 0 : wins / matches;

  String get label {
    if (heroLabels.isEmpty) {
      return 'hero block';
    }

    if (heroLabels.length == 1) {
      return '${heroLabels.first} block';
    }

    return '${heroLabels.first} + ${heroLabels.last} block';
  }

  Map<String, dynamic> toJson() {
    return {
      'heroIds': heroIds,
      'heroLabels': heroLabels,
      'wins': wins,
      'losses': losses,
    };
  }

  factory CoachingCheckpointHeroBlock.fromNextGamesFocusHeroBlock(
    NextGamesFocusHeroBlock heroBlock,
  ) {
    return CoachingCheckpointHeroBlock(
      heroIds: heroBlock.heroIds,
      heroLabels: heroBlock.heroLabels,
      wins: heroBlock.wins,
      losses: heroBlock.losses,
    );
  }

  static CoachingCheckpointHeroBlock? fromJsonOrNull(dynamic value) {
    if (value is! Map<dynamic, dynamic>) {
      return null;
    }

    final json = Map<String, dynamic>.from(value);
    final heroIds = (json['heroIds'] as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((heroId) => heroId.toInt())
        .toList(growable: false);
    if (heroIds.isEmpty) {
      return null;
    }

    final rawLabels = (json['heroLabels'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .map((label) => label.trim())
        .toList(growable: false);
    final heroLabels = [
      for (var index = 0; index < heroIds.length; index++)
        index < rawLabels.length && rawLabels[index].isNotEmpty
            ? rawLabels[index]
            : 'Hero ${heroIds[index]}',
    ];

    return CoachingCheckpointHeroBlock(
      heroIds: heroIds,
      heroLabels: heroLabels,
      wins: CoachingCheckpointSample._readInt(json['wins']),
      losses: CoachingCheckpointSample._readInt(json['losses']),
    );
  }
}

class CoachingCheckpointMatchSummary {
  const CoachingCheckpointMatchSummary({
    this.matchId = 0,
    required this.heroId,
    required this.didWin,
  });

  final int matchId;
  final int heroId;
  final bool didWin;

  String get windowToken =>
      matchId > 0 ? 'm$matchId' : 'h$heroId:${didWin ? 1 : 0}';

  Map<String, dynamic> toJson() {
    return {'matchId': matchId, 'heroId': heroId, 'didWin': didWin};
  }

  factory CoachingCheckpointMatchSummary.fromJson(Map<String, dynamic> json) {
    return CoachingCheckpointMatchSummary(
      matchId: CoachingCheckpointSample._readInt(json['matchId']),
      heroId: CoachingCheckpointSample._readInt(json['heroId']),
      didWin: json['didWin'] as bool? ?? false,
    );
  }
}
