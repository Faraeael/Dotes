import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan_meta_sanity.dart';
import 'package:dotes/src/features/dashboard/domain/services/session_plan_meta_sanity_service.dart';
import 'package:dotes/src/features/meta_reference/data/patch_packs/patch_7_41a_pack.dart';
import 'package:dotes/src/features/meta_reference/domain/models/hero_meta_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = SessionPlanMetaSanityService();

  group('SessionPlanMetaSanityService', () {
    test(
      'marks a two-hero block as meta-aligned when both heroes are high meta',
      () {
        final sanity = service.build(
          plan: _plan([129, 135]),
          currentSupportedPatchLabel: '7.41a',
          comfortCore: null,
          metaReferenceFor: _referenceFor,
        );

        expect(sanity.status, SessionPlanMetaSanityStatus.metaAligned);
        expect(sanity.message, 'This block is meta-aligned.');
      },
    );

    test(
      'marks a block as mixed when one hero is high meta and one is not',
      () {
        final sanity = service.build(
          plan: _plan([129, 28]),
          currentSupportedPatchLabel: '7.41a',
          comfortCore: null,
          metaReferenceFor: _referenceFor,
        );

        expect(sanity.status, SessionPlanMetaSanityStatus.mixed);
        expect(sanity.message, 'This block is mixed between comfort and meta.');
      },
    );

    test(
      'marks a block as comfort-first when covered heroes are not high meta',
      () {
        final sanity = service.build(
          plan: _plan([28, 67]),
          currentSupportedPatchLabel: '7.41a',
          comfortCore: null,
          metaReferenceFor: _referenceFor,
        );

        expect(sanity.status, SessionPlanMetaSanityStatus.comfortFirst);
        expect(sanity.message, 'This block is comfort-first, not meta-first.');
      },
    );

    test('falls back calmly when the plan has incomplete meta coverage', () {
      final sanity = service.build(
        plan: _plan([129, 777]),
        currentSupportedPatchLabel: '7.41a',
        comfortCore: null,
        metaReferenceFor: _referenceFor,
      );

      expect(sanity.status, SessionPlanMetaSanityStatus.noReference);
      expect(sanity.message, 'No meta reference yet. Lean on your own sample.');
    });

    test('stays conservative when the meta data is stale', () {
      final sanity = service.build(
        plan: _plan([129, 135]),
        currentSupportedPatchLabel: '7.41b',
        comfortCore: null,
        metaReferenceFor: _referenceFor,
      );

      expect(sanity.status, SessionPlanMetaSanityStatus.stale);
      expect(
        sanity.message,
        'Patch 7.41a is behind supported patch 7.41b. Lean on your own sample.',
      );
    });
  });
}

SessionPlan _plan(List<int> heroIds) {
  return SessionPlan(
    queue: 'Offlane only',
    heroBlock: 'Hero block',
    target: 'stay inside the block',
    reviewWindow: 'next 5 games',
    targetType: SessionPlanTargetType.comfortBlock,
    heroBlockHeroIds: heroIds,
  );
}

HeroMetaReference? _referenceFor(int heroId) {
  return patch741aMetaPack.loadForHero(heroId);
}
