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

enum TrainingFocusPriority {
  auto,
  reduceDeaths,
  tightenHeroPool,
  stayInComfortBlock;

  String get label => switch (this) {
    TrainingFocusPriority.auto => 'Auto',
    TrainingFocusPriority.reduceDeaths => 'Reduce deaths',
    TrainingFocusPriority.tightenHeroPool => 'Tighten hero pool',
    TrainingFocusPriority.stayInComfortBlock => 'Stay in comfort block',
  };
}

enum TrainingCoachingStyle {
  auto,
  steady,
  direct;

  String get label => switch (this) {
    TrainingCoachingStyle.auto => 'Auto',
    TrainingCoachingStyle.steady => 'Steady',
    TrainingCoachingStyle.direct => 'Direct',
  };
}

enum TrainingQueuePreference {
  auto,
  soloOnly,
  partyOnly;

  String get label => switch (this) {
    TrainingQueuePreference.auto => 'Auto',
    TrainingQueuePreference.soloOnly => 'Solo only',
    TrainingQueuePreference.partyOnly => 'Party only',
  };
}

class TrainingPreferences {
  const TrainingPreferences({
    this.preferredRole = TrainingRolePreference.auto,
    this.lockedHeroIds = const [],
    this.coachingMode = TrainingCoachingMode.followAppRead,
    this.focusPriority = TrainingFocusPriority.auto,
    this.coachingStyle = TrainingCoachingStyle.auto,
    this.queuePreference = TrainingQueuePreference.auto,
    this.coachingNote = '',
  });

  final TrainingRolePreference preferredRole;
  final List<int> lockedHeroIds;
  final TrainingCoachingMode coachingMode;
  final TrainingFocusPriority focusPriority;
  final TrainingCoachingStyle coachingStyle;
  final TrainingQueuePreference queuePreference;
  final String coachingNote;

  bool get prefersManualSetup =>
      coachingMode == TrainingCoachingMode.preferManualSetup;

  PlayerRole? get activePreferredRole =>
      prefersManualSetup ? preferredRole.playerRole : null;

  List<int> get normalizedLockedHeroIds => _normalizeHeroIds(lockedHeroIds);

  List<int> get activeLockedHeroIds =>
      prefersManualSetup ? normalizedLockedHeroIds : const [];

  bool get hasLockedHeroBlock => activeLockedHeroIds.isNotEmpty;
  String? get trimmedCoachingNote {
    final trimmed = coachingNote.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredRole': preferredRole.name,
      'lockedHeroIds': normalizedLockedHeroIds,
      'coachingMode': coachingMode.name,
      'focusPriority': focusPriority.name,
      'coachingStyle': coachingStyle.name,
      'queuePreference': queuePreference.name,
      'coachingNote': trimmedCoachingNote,
    };
  }

  TrainingPreferences copyWith({
    TrainingRolePreference? preferredRole,
    List<int>? lockedHeroIds,
    TrainingCoachingMode? coachingMode,
    TrainingFocusPriority? focusPriority,
    TrainingCoachingStyle? coachingStyle,
    TrainingQueuePreference? queuePreference,
    String? coachingNote,
  }) {
    return TrainingPreferences(
      preferredRole: preferredRole ?? this.preferredRole,
      lockedHeroIds: lockedHeroIds ?? this.lockedHeroIds,
      coachingMode: coachingMode ?? this.coachingMode,
      focusPriority: focusPriority ?? this.focusPriority,
      coachingStyle: coachingStyle ?? this.coachingStyle,
      queuePreference: queuePreference ?? this.queuePreference,
      coachingNote: coachingNote ?? this.coachingNote,
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
      focusPriority: _readFocusPriority(json['focusPriority'] as String?),
      coachingStyle: _readCoachingStyle(json['coachingStyle'] as String?),
      queuePreference: _readQueuePreference(
        json['queuePreference'] as String?,
      ),
      coachingNote: json['coachingNote'] as String? ?? '',
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

  static TrainingFocusPriority _readFocusPriority(String? value) {
    for (final priority in TrainingFocusPriority.values) {
      if (priority.name == value) {
        return priority;
      }
    }

    return TrainingFocusPriority.auto;
  }

  static TrainingCoachingStyle _readCoachingStyle(String? value) {
    for (final style in TrainingCoachingStyle.values) {
      if (style.name == value) {
        return style;
      }
    }

    return TrainingCoachingStyle.auto;
  }

  static TrainingQueuePreference _readQueuePreference(String? value) {
    for (final queuePreference in TrainingQueuePreference.values) {
      if (queuePreference.name == value) {
        return queuePreference;
      }
    }

    return TrainingQueuePreference.auto;
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
