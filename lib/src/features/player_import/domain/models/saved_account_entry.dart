enum SavedAccountSourceType { real, demo }

class SavedAccountEntry {
  const SavedAccountEntry({
    required this.accountId,
    required this.displayName,
    required this.sourceType,
    required this.lastOpenedAt,
    this.isPinned = false,
  });

  final int accountId;
  final String displayName;
  final SavedAccountSourceType sourceType;
  final DateTime lastOpenedAt;
  final bool isPinned;

  String get sourceLabel => switch (sourceType) {
    SavedAccountSourceType.real => 'Real account',
    SavedAccountSourceType.demo => 'Demo account',
  };

  SavedAccountEntry copyWith({
    int? accountId,
    String? displayName,
    SavedAccountSourceType? sourceType,
    DateTime? lastOpenedAt,
    bool? isPinned,
  }) {
    return SavedAccountEntry(
      accountId: accountId ?? this.accountId,
      displayName: displayName ?? this.displayName,
      sourceType: sourceType ?? this.sourceType,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'accountId': accountId,
      'displayName': displayName,
      'sourceType': sourceType.name,
      'lastOpenedAt': lastOpenedAt.toIso8601String(),
      'isPinned': isPinned,
    };
  }

  factory SavedAccountEntry.fromJson(Map<String, dynamic> json) {
    final sourceName = json['sourceType'] as String? ?? 'real';
    return SavedAccountEntry(
      accountId: (json['accountId'] as num?)?.toInt() ?? 0,
      displayName: json['displayName'] as String? ?? 'Unknown player',
      sourceType: SavedAccountSourceType.values.firstWhere(
        (candidate) => candidate.name == sourceName,
        orElse: () => SavedAccountSourceType.real,
      ),
      lastOpenedAt:
          DateTime.tryParse(json['lastOpenedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }
}
