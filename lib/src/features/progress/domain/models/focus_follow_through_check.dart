enum FocusFollowThroughStatus {
  onTrack('On track'),
  mixed('Mixed'),
  offTrack('Off track');

  const FocusFollowThroughStatus(this.label);

  final String label;
}

class FocusFollowThroughCheck {
  const FocusFollowThroughCheck.ready({
    required this.status,
    required this.detail,
    required this.checkpointSavedAt,
    required this.previousFocusLabel,
    required this.comparisonLabel,
  }) : fallbackMessage = null;

  const FocusFollowThroughCheck.waiting({
    required this.fallbackMessage,
    this.checkpointSavedAt,
    this.previousFocusLabel,
    this.comparisonLabel,
  })  : status = null,
        detail = null;

  final FocusFollowThroughStatus? status;
  final String? detail;
  final String? fallbackMessage;
  final DateTime? checkpointSavedAt;
  final String? previousFocusLabel;
  final String? comparisonLabel;

  bool get isReady => status != null;

  bool get hasCheckpointContext =>
      checkpointSavedAt != null &&
      previousFocusLabel != null &&
      previousFocusLabel!.isNotEmpty &&
      comparisonLabel != null &&
      comparisonLabel!.isNotEmpty;
}
