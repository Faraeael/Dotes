import 'package:dotes/src/features/meta_reference/domain/models/hero_meta_freshness.dart';
import 'package:dotes/src/features/meta_reference/domain/services/hero_meta_freshness_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = HeroMetaFreshnessService();

  group('HeroMetaFreshnessService', () {
    test('marks matching patch labels as current', () {
      final freshness = service.build(
        metaPatchLabel: '7.41a',
        currentSupportedPatchLabel: '7.41a',
      );

      expect(freshness.status, HeroMetaFreshnessStatus.current);
      expect(freshness.detailLabel, 'Patch 7.41a matches the supported patch.');
    });

    test(
      'marks mismatched patch labels as outdated with explicit versions',
      () {
        final freshness = service.build(
          metaPatchLabel: '7.41a',
          currentSupportedPatchLabel: '7.41b',
        );

        expect(freshness.status, HeroMetaFreshnessStatus.outdated);
        expect(
          freshness.detailLabel,
          'Patch 7.41a is behind supported patch 7.41b.',
        );
      },
    );
  });
}
