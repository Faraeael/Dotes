import '../models/hero_meta_freshness.dart';

class HeroMetaFreshnessService {
  const HeroMetaFreshnessService();

  HeroMetaFreshness build({
    required String metaPatchLabel,
    required String currentSupportedPatchLabel,
  }) {
    return HeroMetaFreshness(
      metaPatchLabel: metaPatchLabel,
      currentSupportedPatchLabel: currentSupportedPatchLabel,
      status: metaPatchLabel.trim() == currentSupportedPatchLabel.trim()
          ? HeroMetaFreshnessStatus.current
          : HeroMetaFreshnessStatus.outdated,
    );
  }
}
