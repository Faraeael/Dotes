import '../../../dashboard/domain/models/comfort_core_summary.dart';
import '../../../meta_reference/domain/models/hero_meta_freshness.dart';
import '../../../meta_reference/domain/models/hero_meta_reference.dart';
import '../../../meta_reference/domain/services/hero_meta_freshness_service.dart';
import '../models/session_plan.dart';
import '../models/session_plan_meta_sanity.dart';

class SessionPlanMetaSanityService {
  const SessionPlanMetaSanityService({
    HeroMetaFreshnessService freshnessService =
        const HeroMetaFreshnessService(),
  }) : _freshnessService = freshnessService;

  final HeroMetaFreshnessService _freshnessService;

  SessionPlanMetaSanity build({
    required SessionPlan plan,
    required String currentSupportedPatchLabel,
    required ComfortCoreSummary? comfortCore,
    required HeroMetaReference? Function(int heroId) metaReferenceFor,
  }) {
    final heroIds = _heroIdsForPlan(plan, comfortCore);
    if (heroIds.isEmpty) {
      return const SessionPlanMetaSanity(
        status: SessionPlanMetaSanityStatus.noReference,
        message: 'No meta reference yet. Lean on your own sample.',
      );
    }

    final references = heroIds
        .map(metaReferenceFor)
        .whereType<HeroMetaReference>()
        .toList(growable: false);
    if (references.length < heroIds.length) {
      return const SessionPlanMetaSanity(
        status: SessionPlanMetaSanityStatus.noReference,
        message: 'No meta reference yet. Lean on your own sample.',
      );
    }

    final freshness = references
        .map(
          (reference) => _freshnessService.build(
            metaPatchLabel: reference.patchLabel,
            currentSupportedPatchLabel: currentSupportedPatchLabel,
          ),
        )
        .toList(growable: false);
    if (freshness.any((item) => item.status == HeroMetaFreshnessStatus.outdated)) {
      return const SessionPlanMetaSanity(
        status: SessionPlanMetaSanityStatus.stale,
        message: 'Meta reference is outdated. Lean on your own sample.',
      );
    }

    final highMetaCount = references.where((item) => item.tier.isHighMeta).length;
    if (highMetaCount == references.length) {
      return const SessionPlanMetaSanity(
        status: SessionPlanMetaSanityStatus.metaAligned,
        message: 'This block is meta-aligned.',
      );
    }

    if (highMetaCount > 0) {
      return const SessionPlanMetaSanity(
        status: SessionPlanMetaSanityStatus.mixed,
        message: 'This block is mixed between comfort and meta.',
      );
    }

    return const SessionPlanMetaSanity(
      status: SessionPlanMetaSanityStatus.comfortFirst,
      message: 'This block is comfort-first, not meta-first.',
    );
  }

  List<int> _heroIdsForPlan(SessionPlan plan, ComfortCoreSummary? comfortCore) {
    if (plan.heroBlockHeroIds.isNotEmpty) {
      return plan.heroBlockHeroIds;
    }

    if (comfortCore == null || !comfortCore.isReady) {
      return const [];
    }

    final hasStableBlock =
        comfortCore.conclusionType ==
            ComfortCoreConclusionType.successInsideCore ||
        comfortCore.conclusionType == ComfortCoreConclusionType.outsideWeaker;
    if (!hasStableBlock) {
      return const [];
    }

    return comfortCore.topHeroes
        .take(2)
        .map((hero) => hero.heroId)
        .toList(growable: false);
  }
}
