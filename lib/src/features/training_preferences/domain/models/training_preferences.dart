import '../../../roles/domain/models/player_role.dart';

enum TrainingCoachingMode {
  followAppRead,
  preferManualSetup;

  String get label => switch (this) {
    TrainingCoachingMode.followAppRead => 'Follow app read',
    TrainingCoachingMode.preferManualSetup => 'Prefer manual setup',
  };
}

enum TrainingRolePreference {
  auto,
  carry,
  mid,
  offlane,
  softSupport,
  hardSupport;

  String get label => switch (this) {
    TrainingRolePreference.auto => 'Auto',
    TrainingRolePreference.carry => 'Carry',
    TrainingRolePreference.mid => 'Mid',
    TrainingRolePreference.offlane => 'Offlane',
    TrainingRolePreference.softSupport => 'Soft Support',
    TrainingRolePreference.hardSupport => 'Hard Support',
  };

  PlayerRole? get playerRole => switch (this) {
    TrainingRolePreference.auto => null,
    TrainingRolePreference.carry => PlayerRole.carry,
    TrainingRolePreference.mid => PlayerRole.mid,
    TrainingRolePreference.offlane => PlayerRole.offlane,
    TrainingRolePreference.softSupport => PlayerRole.softSupport,
    TrainingRolePreference.hardSupport => PlayerRole.hardSupport,
  };
}

class TrainingPreferences {
  const TrainingPreferences({
    this.preferredRole = TrainingRolePreference.auto,
    this.lockedHeroIds = const [],
    this.coachingMode = TrainingCoachingMode.followAppRead,
  });

  final TrainingRolePreference preferredRole;
  final List<int> lockedHeroIds;
  final TrainingCoachingMode coachingMode;

  bool get prefersManualSetup =>
      coachingMode == TrainingCoachingMode.preferManualSetup;

  PlayerRole? get activePreferredRole =>
      prefersManualSetup ? preferredRole.playerRole : null;

  List<int> get normalizedLockedHeroIds => _normalizeHeroIds(lockedHeroIds);

  List<int> get activeLockedHeroIds =>
      prefersManualSetup ? normalizedLockedHeroIds : const [];

  bool get hasLockedHeroBlock => activeLockedHeroIds.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'preferredRole': preferredRole.name,
      'lockedHeroIds': normalizedLockedHeroIds,
      'coachingMode': coachingMode.name,
    };
  }

  TrainingPreferences copyWith({
    TrainingRolePreference? preferredRole,
    List<int>? lockedHeroIds,
    TrainingCoachingMode? coachingMode,
  }) {
    return TrainingPreferences(
      preferredRole: preferredRole ?? this.preferredRole,
      lockedHeroIds: lockedHeroIds ?? this.lockedHeroIds,
      coachingMode: coachingMode ?? this.coachingMode,
    );
  }

  factory TrainingPreferences.fromJson(Map<String, dynamic> json) {
    return TrainingPreferences(
      preferredRole: _readPreferredRole(json['preferredRole'] as String?),
      lockedHeroIds: (json['lockedHeroIds'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((heroId) => heroId.toInt())
          .toList(growable: false),
      coachingMode: _readCoachingMode(json['coachingMode'] as String?),
    );
  }

  static TrainingRolePreference _readPreferredRole(String? value) {
    for (final role in TrainingRolePreference.values) {
      if (role.name == value) {
        return role;
      }
    }

    return TrainingRolePreference.auto;
  }

  static TrainingCoachingMode _readCoachingMode(String? value) {
    for (final mode in TrainingCoachingMode.values) {
      if (mode.name == value) {
        return mode;
      }
    }

    return TrainingCoachingMode.followAppRead;
  }

  static List<int> _normalizeHeroIds(List<int> rawHeroIds) {
    final seenHeroIds = <int>{};
    final normalized = <int>[];
    for (final heroId in rawHeroIds) {
      if (heroId <= 0 || seenHeroIds.contains(heroId)) {
        continue;
      }

      seenHeroIds.add(heroId);
      normalized.add(heroId);
      if (normalized.length == 2) {
        break;
      }
    }

    return normalized;
  }
}
