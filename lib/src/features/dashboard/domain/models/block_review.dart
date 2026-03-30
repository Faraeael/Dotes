enum BlockReviewStatus {
  inProgress('In progress'),
  completed('Completed');

  const BlockReviewStatus(this.label);

  final String label;
}

enum BlockReviewAdherence {
  stayedInsideBlock('stayed inside block'),
  partialDrift('partial drift'),
  offBlock('off block'),
  noBlockSet('no block set'),
  notEnoughGames('not enough games yet');

  const BlockReviewAdherence(this.label);

  final String label;
}

enum BlockReviewTargetResult {
  improved('improved'),
  flat('flat'),
  worse('worse');

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
