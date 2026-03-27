import 'dart:convert';

import '../../../insights/domain/models/coaching_insight.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import '../../../roles/domain/models/sample_role_summary.dart';

class CoachingCheckpointDraft {
  const CoachingCheckpointDraft({
    required this.accountId,
    required this.focusAction,
    required this.focusSourceLabel,
    required this.topInsightType,
    required this.sample,
  });

  final int accountId;
  final String focusAction;
  final String focusSourceLabel;
  final CoachingInsightType? topInsightType;
  final CoachingCheckpointSample sample;

  String get fingerprint => jsonEncode({
    'accountId': accountId,
    'focusAction': focusAction,
    'focusSourceLabel': focusSourceLabel,
    'topInsightType': topInsightType?.name,
    'sample': sample.toJson(),
  });

  CoachingCheckpoint toCheckpoint(DateTime savedAt) {
    return CoachingCheckpoint(
      accountId: accountId,
      savedAt: savedAt,
      focusAction: focusAction,
      focusSourceLabel: focusSourceLabel,
      topInsightType: topInsightType,
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
  });

  final int accountId;
  final DateTime savedAt;
  final String focusAction;
  final String focusSourceLabel;
  final CoachingInsightType? topInsightType;
  final CoachingCheckpointSample sample;

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'savedAt': savedAt.toUtc().toIso8601String(),
      'focusAction': focusAction,
      'focusSourceLabel': focusSourceLabel,
      'topInsightType': topInsightType?.name,
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

  factory CoachingCheckpointSample.fromImportedPlayer(
    ImportedPlayerData importedPlayer,
    SampleRoleSummary roleSummary,
  ) {
    final matches = importedPlayer.recentMatches;
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
