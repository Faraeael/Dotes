enum TrainingBlockActionType {
  start('Start this 5-game block'),
  restart('Restart this 5-game block');

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
