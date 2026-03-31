enum BlockReviewStatus {
  inProgress('Live'),
  completed('Complete');

  const BlockReviewStatus(this.label);

  final String label;
}

enum BlockReviewAdherence {
  stayedInsideBlock('Stayed in block'),
  partialDrift('Some drift'),
  offBlock('Off block'),
  noBlockSet('No block set'),
  notEnoughGames('Need more games');

  const BlockReviewAdherence(this.label);

  final String label;
}

enum BlockReviewTargetResult {
  improved('Improved'),
  flat('Flat'),
  worse('Worse');

  const BlockReviewTargetResult(this.label);

  final String label;
}

enum BlockReviewOutcome {
  onTrack('On track'),
  mixed('Mixed'),
  offTrack('Off track');

  const BlockReviewOutcome(this.label);

  final String label;
}

class BlockReview {
  const BlockReview({
    required this.blockStatus,
    required this.gamesLogged,
    required this.blockSize,
    required this.adherence,
    required this.targetResult,
    required this.overallOutcome,
  });

  final BlockReviewStatus blockStatus;
  final int gamesLogged;
  final int blockSize;
  final BlockReviewAdherence adherence;
  final BlockReviewTargetResult targetResult;
  final BlockReviewOutcome overallOutcome;

  String get gamesLoggedLabel => '$gamesLogged of $blockSize';
}
