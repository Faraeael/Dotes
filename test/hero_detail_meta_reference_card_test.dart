import 'package:dotes/src/features/dashboard/domain/services/comfort_core_service.dart';
import 'package:dotes/src/features/hero_detail/domain/services/hero_detail_service.dart';
import 'package:dotes/src/features/hero_detail/presentation/widgets/hero_detail_meta_reference_card.dart';
import 'package:dotes/src/features/meta_reference/data/repositories/local_hero_meta_reference_repository.dart';
import 'package:dotes/src/features/meta_reference/domain/models/hero_meta_reference.dart';
import 'package:dotes/src/features/player_import/data/demo/demo_player_scenarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('demo-mode hero detail meta card still renders correctly', (
    tester,
  ) async {
    final scenario = demoPlayerScenarios.firstWhere(
      (item) => item.id == 'completed_on_track_block',
    );
    final detail = const HeroDetailService().build(
      heroId: 28,
      allMatches: scenario.importedPlayer.recentMatches,
      heroLabelFor: (heroId) => heroId == 28 ? 'Slardar' : 'Hero $heroId',
      currentSupportedPatchLabel: '7.41a',
      comfortCore: const ComfortCoreService().build(
        scenario.importedPlayer.recentMatches,
      ),
      metaReference: const LocalHeroMetaReferenceRepository().loadForHero(28),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HeroDetailMetaReferenceCard(detail: detail)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meta reference'), findsOneWidget);
    expect(find.text('7.41a'), findsOneWidget);
    expect(find.text('Playable'), findsOneWidget);
    expect(find.text('Current patch'), findsOneWidget);
    expect(
      find.text('Patch 7.41a matches the supported patch.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'This hero looks playable, but your own comfort read matters more than the patch.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('stale meta shows an outdated warning badge and calmer wording', (
    tester,
  ) async {
    final scenario = demoPlayerScenarios.firstWhere(
      (item) => item.id == 'completed_on_track_block',
    );
    final detail = const HeroDetailService().build(
      heroId: 129,
      allMatches: scenario.importedPlayer.recentMatches,
      heroLabelFor: (heroId) => heroId == 129 ? 'Mars' : 'Hero $heroId',
      currentSupportedPatchLabel: '7.41b',
      comfortCore: const ComfortCoreService().build(
        scenario.importedPlayer.recentMatches,
      ),
      metaReference: const HeroMetaReference(
        heroId: 129,
        patchLabel: '7.41a',
        tier: HeroMetaTier.top,
        roleLabel: 'Offlane initiator',
        coreItemDirection: 'Blink into BKB and control',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HeroDetailMetaReferenceCard(detail: detail)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Outdated'), findsOneWidget);
    expect(
      find.text('Patch 7.41a is behind supported patch 7.41b.'),
      findsWidgets,
    );
    expect(
      find.text(
        'Lean on your own sample until the local patch reference is refreshed.',
      ),
      findsOneWidget,
    );
  });
}
