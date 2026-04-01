enum SessionPlanMetaSanityStatus {
  metaAligned('Meta-aligned'),
  mixed('Mixed'),
  comfortFirst('Comfort-first'),
  noReference('No meta yet'),
  stale('Outdated');

  const SessionPlanMetaSanityStatus(this.label);

  final String label;
}

class SessionPlanMetaSanity {
  const SessionPlanMetaSanity({
    required this.status,
    required this.message,
    this.detail,
  });

  final SessionPlanMetaSanityStatus status;
  final String message;
  final String? detail;

  bool get isFallback =>
      status == SessionPlanMetaSanityStatus.noReference ||
      status == SessionPlanMetaSanityStatus.stale;
}
