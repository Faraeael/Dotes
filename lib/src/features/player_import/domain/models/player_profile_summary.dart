/// The eight Dota 2 rank medals, plus [unknown] for null / unranked profiles.
enum RankBracket {
  herald,
  guardian,
  crusader,
  archon,
  legend,
  ancient,
  divine,
  immortal,
  unknown;

  static RankBracket fromRankTier(int? rankTier) {
    if (rankTier == null || rankTier == 0) return RankBracket.unknown;
    return switch (rankTier ~/ 10) {
      1 => RankBracket.herald,
      2 => RankBracket.guardian,
      3 => RankBracket.crusader,
      4 => RankBracket.archon,
      5 => RankBracket.legend,
      6 => RankBracket.ancient,
      7 => RankBracket.divine,
      8 => RankBracket.immortal,
      _ => RankBracket.unknown,
    };
  }
}

/// Three pedagogical coaching tiers collapsed from the eight Dota medals.
///
/// - [introductory]: Herald, Guardian, Crusader — simpler phrasing, no jargon.
/// - [standard]: Archon, Legend, Ancient — current baseline.
/// - [advanced]: Divine, Immortal — terse, efficiency-first framing.
enum CoachingRankTier {
  introductory,
  standard,
  advanced;

  static CoachingRankTier fromBracket(RankBracket bracket) {
    return switch (bracket) {
      RankBracket.herald ||
      RankBracket.guardian ||
      RankBracket.crusader =>
        CoachingRankTier.introductory,
      RankBracket.archon ||
      RankBracket.legend ||
      RankBracket.ancient =>
        CoachingRankTier.standard,
      RankBracket.divine || RankBracket.immortal => CoachingRankTier.advanced,
      RankBracket.unknown => CoachingRankTier.standard,
    };
  }
}

class PlayerProfileSummary {
  const PlayerProfileSummary({
    required this.accountId,
    required this.personaName,
    required this.avatarUrl,
    this.realName,
    this.rankTier,
    this.leaderboardRank,
  });

  final int accountId;
  final String personaName;
  final String avatarUrl;
  final String? realName;
  final int? rankTier;
  final int? leaderboardRank;

  String get displayName => personaName.isEmpty ? 'Unknown player' : personaName;

  bool get hasProfile => accountId > 0;

  /// Decoded rank bracket (e.g. [RankBracket.legend]).
  RankBracket get rankBracket => RankBracket.fromRankTier(rankTier);

  /// Collapsed coaching tier used to pick tone in generated copy.
  CoachingRankTier get coachingRankTier =>
      CoachingRankTier.fromBracket(rankBracket);

  /// Human-readable rank label, e.g. `"Legend 1"`, `"Immortal"`, or `null`
  /// when rank is unknown.
  String? get rankLabel {
    final bracket = rankBracket;
    if (bracket == RankBracket.unknown) return null;

    final bracketName = bracket.name[0].toUpperCase() + bracket.name.substring(1);
    if (bracket == RankBracket.immortal) {
      return leaderboardRank != null
          ? 'Immortal (#$leaderboardRank)'
          : 'Immortal';
    }

    final stars = rankTier != null ? (rankTier! % 10) : 0;
    return stars > 0 ? '$bracketName $stars' : bracketName;
  }

  factory PlayerProfileSummary.fromJson(Map<String, dynamic> json) {
    final profile = Map<String, dynamic>.from(
      json['profile'] as Map<dynamic, dynamic>? ?? const {},
    );

    return PlayerProfileSummary(
      accountId: _readInt(profile['account_id']) ?? 0,
      personaName: profile['personaname'] as String? ?? '',
      avatarUrl:
          profile['avatarfull'] as String? ??
          profile['avatar'] as String? ??
          '',
      realName: profile['name'] as String?,
      rankTier: _readInt(json['rank_tier']),
      leaderboardRank: _readInt(json['leaderboard_rank']),
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }
}
