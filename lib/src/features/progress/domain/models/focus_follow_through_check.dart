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
  }) : fallbackMessage = null;

  const FocusFollowThroughCheck.waiting({
    required this.fallbackMessage,
  })  : status = null,
        detail = null;

  final FocusFollowThroughStatus? status;
  final String? detail;
  final String? fallbackMessage;

  bool get isReady => status != null;
}
