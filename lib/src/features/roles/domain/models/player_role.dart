enum PlayerRole {
  carry,
  mid,
  offlane,
  softSupport,
  hardSupport,
  unknown;

  String get label => switch (this) {
    PlayerRole.carry => 'Carry',
    PlayerRole.mid => 'Mid',
    PlayerRole.offlane => 'Offlane',
    PlayerRole.softSupport => 'Soft Support',
    PlayerRole.hardSupport => 'Hard Support',
    PlayerRole.unknown => 'Unknown',
  };

  int get sortOrder => switch (this) {
    PlayerRole.carry => 0,
    PlayerRole.mid => 1,
    PlayerRole.offlane => 2,
    PlayerRole.softSupport => 3,
    PlayerRole.hardSupport => 4,
    PlayerRole.unknown => 5,
  };
}
