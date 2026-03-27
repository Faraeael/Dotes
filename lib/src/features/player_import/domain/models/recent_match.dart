class RecentMatch {
  const RecentMatch({
    required this.matchId,
    required this.heroId,
    required this.startedAt,
    required this.duration,
    required this.kills,
    required this.deaths,
    required this.assists,
    required this.didWin,
    this.goldPerMin,
    this.xpPerMin,
    this.lastHits,
    this.lane,
    this.laneRole,
    this.isRoaming,
    this.partySize,
  });

  final int matchId;
  final int heroId;
  final DateTime startedAt;
  final Duration duration;
  final int kills;
  final int deaths;
  final int assists;
  final bool didWin;
  final int? goldPerMin;
  final int? xpPerMin;
  final int? lastHits;
  final int? lane;
  final int? laneRole;
  final bool? isRoaming;
  final int? partySize;

  String get kdaLine => '$kills / $deaths / $assists';

  factory RecentMatch.fromJson(Map<String, dynamic> json) {
    final playerSlot = _readInt(json['player_slot']) ?? 0;
    final radiantWin = json['radiant_win'] as bool? ?? false;
    final isRadiant = playerSlot < 128;

    return RecentMatch(
      matchId: _readInt(json['match_id']) ?? 0,
      heroId: _readInt(json['hero_id']) ?? 0,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        (_readInt(json['start_time']) ?? 0) * 1000,
        isUtc: true,
      ).toLocal(),
      duration: Duration(seconds: _readInt(json['duration']) ?? 0),
      kills: _readInt(json['kills']) ?? 0,
      deaths: _readInt(json['deaths']) ?? 0,
      assists: _readInt(json['assists']) ?? 0,
      didWin: radiantWin == isRadiant,
      goldPerMin: _readInt(json['gold_per_min']),
      xpPerMin: _readInt(json['xp_per_min']),
      lastHits: _readInt(json['last_hits']),
      lane: _readInt(json['lane']),
      laneRole: _readInt(json['lane_role']),
      isRoaming: json['is_roaming'] as bool?,
      partySize: _readInt(json['party_size']),
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
