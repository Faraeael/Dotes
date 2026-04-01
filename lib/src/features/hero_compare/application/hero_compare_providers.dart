import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../hero_detail/application/hero_detail_provider.dart';
import '../../matches/presentation/utils/hero_labels.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../../training_preferences/application/manual_hero_block_action_providers.dart';
import '../domain/models/hero_compare.dart';
import '../domain/models/hero_compare_block_actions.dart';
import '../domain/services/hero_compare_block_actions_service.dart';
import '../domain/services/hero_compare_service.dart';

final heroCompareServiceProvider = Provider<HeroCompareService>((ref) {
  return const HeroCompareService();
});

final heroCompareBlockActionsServiceProvider =
    Provider<HeroCompareBlockActionsService>((ref) {
      return const HeroCompareBlockActionsService();
    });

final heroCompareOptionsProvider =
    Provider.family<List<HeroCompareOption>, int>((ref, heroId) {
      final importedPlayer = ref.watch(importedPlayerProvider);
      if (importedPlayer == null) {
        return const [];
      }

      final heroIds = importedPlayer.recentMatches
          .map((match) => match.heroId)
          .where((candidate) => candidate != heroId)
          .toSet()
          .toList(growable: true)
        ..sort((left, right) => heroDisplayName(left).compareTo(heroDisplayName(right)));

      return heroIds
          .map(
            (candidate) => HeroCompareOption(
              heroId: candidate,
              heroName: heroDisplayName(candidate),
            ),
          )
          .toList(growable: false);
    });

final heroCompareProvider =
    Provider.family<HeroCompare?, HeroCompareRequest>((ref, request) {
      final primary = ref.watch(heroDetailProvider(request.primaryHeroId));
      final secondary = ref.watch(heroDetailProvider(request.secondaryHeroId));
      if (primary == null || secondary == null) {
        return null;
      }

      return ref.watch(heroCompareServiceProvider).build(
            primaryHero: primary,
            secondaryHero: secondary,
          );
    });

final heroCompareBlockActionsProvider =
    Provider.family<HeroCompareBlockActions?, HeroCompareRequest>((ref, request) {
      final compare = ref.watch(heroCompareProvider(request));
      if (compare == null) {
        return null;
      }

      final leftControl = ref.watch(
        heroTrainingBlockControlProvider(request.primaryHeroId),
      );
      final rightControl = ref.watch(
        heroTrainingBlockControlProvider(request.secondaryHeroId),
      );
      if (leftControl == null || rightControl == null) {
        return null;
      }

      return ref.watch(heroCompareBlockActionsServiceProvider).build(
            compare: compare,
            leftControl: leftControl,
            rightControl: rightControl,
          );
    });
