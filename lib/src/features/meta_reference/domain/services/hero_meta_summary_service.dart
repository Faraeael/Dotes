import '../models/hero_meta_reference.dart';
import '../models/hero_meta_summary.dart';
import 'hero_meta_freshness_service.dart';

class HeroMetaSummaryService {
  const HeroMetaSummaryService({
    HeroMetaFreshnessService freshnessService =
        const HeroMetaFreshnessService(),
  }) : _freshnessService = freshnessService;

  final HeroMetaFreshnessService _freshnessService;

  HeroMetaSummary build({
    required HeroMetaReference? reference,
    required String currentSupportedPatchLabel,
    required bool hasStrongRead,
    required bool isInComfortCore,
    required bool isInCurrentPlan,
    required bool isOutsideCurrentPlan,
    required bool isStrongerRecentPick,
    required bool isWeakerThanTopBlock,
  }) {
    if (reference == null) {
      return HeroMetaSummary(
        reference: null,
        freshness: null,
        interpretation: hasStrongRead
            ? 'Lean on your own coaching sample for this hero right now.'
            : 'This hero still needs more of your own sample before adding meta context.',
        fallbackMessage: 'No local meta reference is seeded for this hero yet.',
      );
    }

    final freshness = _freshnessService.build(
      metaPatchLabel: reference.patchLabel,
      currentSupportedPatchLabel: currentSupportedPatchLabel,
    );
    if (freshness.isOutdated) {
      return HeroMetaSummary(
        reference: reference,
        freshness: freshness,
        interpretation:
            'Lean on your own sample until the local patch reference is refreshed.',
        fallbackMessage: '',
        staleWarning: freshness.detailLabel,
      );
    }

    return HeroMetaSummary(
      reference: reference,
      freshness: freshness,
      interpretation: _interpretationFor(
        reference: reference,
        hasStrongRead: hasStrongRead,
        isInComfortCore: isInComfortCore,
        isInCurrentPlan: isInCurrentPlan,
        isOutsideCurrentPlan: isOutsideCurrentPlan,
        isStrongerRecentPick: isStrongerRecentPick,
        isWeakerThanTopBlock: isWeakerThanTopBlock,
      ),
      fallbackMessage: '',
    );
  }

  String _interpretationFor({
    required HeroMetaReference reference,
    required bool hasStrongRead,
    required bool isInComfortCore,
    required bool isInCurrentPlan,
    required bool isOutsideCurrentPlan,
    required bool isStrongerRecentPick,
    required bool isWeakerThanTopBlock,
  }) {
    if (reference.tier.isHighMeta) {
      if (isInCurrentPlan || isInComfortCore || isStrongerRecentPick) {
        return 'This hero currently matches the high-level meta.';
      }
      if (!hasStrongRead) {
        return 'The patch likes this hero, but your own sample is still thin.';
      }
      if (isOutsideCurrentPlan || isWeakerThanTopBlock) {
        return 'The patch likes this hero more than your current coaching read does.';
      }
      return 'This hero looks playable in the patch, but your own sample should still drive the call.';
    }

    if (reference.tier == HeroMetaTier.neutral) {
      if (isInComfortCore || isStrongerRecentPick) {
        return 'This hero looks playable, but your own comfort read matters more than the patch.';
      }
      return 'This hero looks neutral in the patch, so your own sample should drive the call.';
    }

    if (isInComfortCore || isInCurrentPlan || isStrongerRecentPick) {
      return 'This hero is more comfort-driven than meta-driven right now.';
    }
    if (!hasStrongRead) {
      return 'This hero is not strongly meta-backed, and your own sample is still thin.';
    }
    return 'This hero looks niche in the patch, so keep the call tightly tied to your own sample.';
  }
}
