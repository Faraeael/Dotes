enum SessionPlanTargetType {
  deaths,
  heroPool,
  comfortBlock,
}

class SessionPlan {
  const SessionPlan({
    required this.queue,
    required this.heroBlock,
    required this.target,
    required this.reviewWindow,
    required this.targetType,
    this.heroBlockHeroIds = const [],
    this.roleBlockKey,
  });

  final String queue;
  final String heroBlock;
  final String target;
  final String reviewWindow;
  final SessionPlanTargetType targetType;
  final List<int> heroBlockHeroIds;
  final String? roleBlockKey;

  bool get hasHeroSpecificBlock => heroBlockHeroIds.isNotEmpty;

  bool get hasRoleBlock => roleBlockKey != null && roleBlockKey!.isNotEmpty;
}
