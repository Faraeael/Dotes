import 'package:dotes/src/features/meta_reference/data/patch_packs/local_meta_patch_registry.dart';
import 'package:dotes/src/features/meta_reference/data/repositories/local_hero_meta_reference_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalHeroMetaReferenceRepository', () {
    test('reads from the current 7.41a patch pack deterministically', () {
      const repository = LocalHeroMetaReferenceRepository();

      final first = repository.loadForHero(129);
      final second = repository.loadForHero(129);

      expect(first, isNotNull);
      expect(first!.patchLabel, latestAvailableLocalMetaPatchPack.patchLabel);
      expect(first.patchLabel, '7.41a');
      expect(first.roleLabel, 'Offlane initiator');
      expect(second!.coreItemDirection, first.coreItemDirection);
      expect(second.tier, first.tier);
    });

    test('returns null for heroes missing from the local patch pack', () {
      const repository = LocalHeroMetaReferenceRepository();

      expect(repository.loadForHero(777), isNull);
    });
  });
}
