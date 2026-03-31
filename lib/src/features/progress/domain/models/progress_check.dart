enum ProgressDirection {
  up('Up'),
  down('Down'),
  same('Same'),
  narrower('Narrower'),
  wider('Wider');

  const ProgressDirection(this.label);

  final String label;
}

class ProgressMetricComparison {
  const ProgressMetricComparison({
    required this.label,
    required this.direction,
    required this.currentValueLabel,
    required this.previousValueLabel,
  });

  final String label;
  final ProgressDirection direction;
  final String currentValueLabel;
  final String previousValueLabel;

  String get detailLabel => '$currentValueLabel now vs $previousValueLabel before';
}

class ProgressCheck {
  const ProgressCheck.ready({
    required this.blockSize,
    required this.comparisons,
  }) : fallbackMessage = null;

  const ProgressCheck.tooSmall({
    required this.fallbackMessage,
  })  : blockSize = null,
        comparisons = const [];

  final int? blockSize;
  final List<ProgressMetricComparison> comparisons;
  final String? fallbackMessage;

  bool get isReady => blockSize != null;

  String get subtitle {
    if (blockSize == null) {
      return 'Waiting for a larger sample.';
    }

    return 'Latest $blockSize matches vs previous $blockSize.';
  }
}
