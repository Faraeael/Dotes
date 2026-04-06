enum HeroMetaFreshnessStatus {
  current('Current patch'),
  outdated('Outdated');

  const HeroMetaFreshnessStatus(this.label);

  final String label;
}

class HeroMetaFreshness {
  const HeroMetaFreshness({
    required this.metaPatchLabel,
    required this.currentSupportedPatchLabel,
    required this.status,
  });

  final String metaPatchLabel;
  final String currentSupportedPatchLabel;
  final HeroMetaFreshnessStatus status;

  bool get isCurrent => status == HeroMetaFreshnessStatus.current;
  bool get isOutdated => status == HeroMetaFreshnessStatus.outdated;

  String get detailLabel => isCurrent
      ? 'Patch $metaPatchLabel matches the supported patch.'
      : 'Patch $metaPatchLabel is behind supported patch $currentSupportedPatchLabel.';
}
