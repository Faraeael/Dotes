import 'dart:convert';

import '../../../insights/domain/models/coaching_insight.dart';
import '../../../insights/domain/models/next_games_focus.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import '../../../roles/domain/models/sample_role_summary.dart';

class CoachingCheckpointDraft {
  const CoachingCheckpointDraft({
    required this.accountId,
    required this.focusAction,
    required this.focusSourceLabel,
    required this.topInsightType,
    required this.sample,
    this.focusHeroBlock,
  });

  final int accountId;
  final String focusAction;
  final String focusSourceLabel;
  final CoachingInsightType? topInsightType;
  final CoachingCheckpointSample sample;
  final CoachingCheckpointHeroBlock? focusHeroBlock;

  String get fingerprint => jsonEncode({
    'accountId': accountId,
    'focusAction': focusAction,
    'focusSourceLabel': focusSourceLabel,
    'topInsightType': topInsightType?.name,
    'focusHeroBlock': focusHeroBlock?.toJson(),
    'sample': sample.toJson(),
  });

  CoachingCheckpoint toCheckpoint(DateTime savedAt) {
    return CoachingCheckpoint(
      accountId: accountId,
      savedAt: savedAt,
      focusAction: focusAction,
      focusSourceLabel: focusSourceLabel,
      topInsightType: topInsightType,
      focusHeroBlock: focusHeroBlock,
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
  });

  final int accountId;
  final DateTime savedAt;
  final String focusAction;
  final String focusSourceLabel;
  final CoachingInsightType? topInsightType;
  final CoachingCheckpointSample sample;
  final CoachingCheckpointHeroBlock? focusHeroBlock;

  String get fingerprint => jsonEncode({
    'accountId': accountId,
    'focusAction': focusAction,
    'focusSourceLabel': focusSourceLabel,
    'topInsightType': topInsightType?.name,
    'focusHeroBlock': focusHeroBlock?.toJson(),
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
      'sample': sample.toJson(),
    };
  }

  factory CoachingCheckpoint.fromJson(Map<String, dynamic> json) {
    return CoachingCheckpoint(
      accountId: json['accountId'] as int? ?? 0,
      savedAt: DateTime.parse(
        json['savedAt'] as String? ?? DateTime.fromMillisecondsSinceEpoch(0).toUtc().toIso8601String(),
      ).toUtc(),
      focusAction: json['focusAction'] as String? ?? '',
      focusSourceLabel: json['focusSourceLabel'] as String? ?? '',
      topInsightType: _readInsightType(json['topInsightType'] as String?),
      focusHeroBlock: CoachingCheckpointHeroBlock.fromJsonOrNull(
        json['focusHeroBlock'],
      ),
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
    for (final match in recentMatchesWindow) {
      if (match.matchId > 0) {
        return match.matchId;
      }
    }

    return null;
  }

  List<String> get recentWindowTokens =>
      recentMatchesWindow.map((match) => match.windowToken).toList(growable: false);

  String get reviewedBlockSignature => recentWindowTokens.join('|');

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
      recentMatchesWindow: importedPlayer.recentMatches
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
    return {
      'matchId': matchId,
      'heroId': heroId,
      'didWin': didWin,
    };
  }

  factory CoachingCheckpointMatchSummary.fromJson(Map<String, dynamic> json) {
    return CoachingCheckpointMatchSummary(
      matchId: CoachingCheckpointSample._readInt(json['matchId']),
      heroId: CoachingCheckpointSample._readInt(json['heroId']),
      didWin: json['didWin'] as bool? ?? false,
    );
  }
}
