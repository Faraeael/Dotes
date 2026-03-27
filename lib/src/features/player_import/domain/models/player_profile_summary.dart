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
