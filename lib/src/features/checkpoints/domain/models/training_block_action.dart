enum TrainingBlockActionType {
  start('Start 5-game block'),
  restart('Restart block');

  const TrainingBlockActionType(this.label);

  final String label;
}

class TrainingBlockActionControl {
  const TrainingBlockActionControl({
    required this.actionType,
    required this.blockStateLabel,
    this.blockStateDetail,
  });

  final TrainingBlockActionType actionType;
  final String blockStateLabel;
  final String? blockStateDetail;
}
