import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../matches/presentation/utils/hero_labels.dart';
import '../../hero_compare/application/hero_compare_providers.dart';
import '../../hero_compare/domain/models/hero_compare.dart';
import '../../hero_compare/presentation/hero_compare_screen.dart';
import '../../dashboard/presentation/widgets/dashboard_shell.dart';
import '../../dashboard/presentation/widgets/section_card.dart';
import '../application/hero_detail_provider.dart';
import 'widgets/hero_detail_block_context_card.dart';
import 'widgets/hero_detail_header_card.dart';
import 'widgets/hero_detail_meta_reference_card.dart';
import 'widgets/hero_detail_matches_card.dart';
import 'widgets/hero_detail_summary_card.dart';
import 'widgets/hero_detail_training_block_card.dart';

class HeroDetailScreen extends ConsumerWidget {
  const HeroDetailScreen({required this.heroId, super.key});

  final int heroId;

  static Route<void> route(int heroId) {
    return MaterialPageRoute<void>(
      builder: (_) => HeroDetailScreen(heroId: heroId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(heroDetailProvider(heroId));
    final compareOptions = ref.watch(heroCompareOptionsProvider(heroId));
    final title = detail?.heroName ?? heroDisplayName(heroId);

    return DashboardShell(
      title: title,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (detail == null)
            SectionCard(
              title: title,
              body:
                  'Import a recent match sample first to inspect hero-level reads.',
            )
          else ...[
            HeroDetailHeaderCard(
              detail: detail,
              onCompareHero: compareOptions.isEmpty
                  ? null
                  : () async {
                      final selectedHeroId = await _HeroComparePickerDialog.show(
                        context,
                        options: compareOptions,
                      );
                      if (!context.mounted || selectedHeroId == null) {
                        return;
                      }

                      Navigator.of(context).push(
                        HeroCompareScreen.route(
                          primaryHeroId: heroId,
                          secondaryHeroId: selectedHeroId,
                        ),
                      );
                    },
            ),
            const SizedBox(height: 16),
            HeroDetailTrainingBlockCard(heroId: heroId),
            const SizedBox(height: 16),
            HeroDetailMetaReferenceCard(detail: detail),
            const SizedBox(height: 16),
            HeroDetailSummaryCard(detail: detail),
            if (detail.blockContext != null) ...[
              const SizedBox(height: 16),
              HeroDetailBlockContextCard(blockContext: detail.blockContext!),
            ],
            const SizedBox(height: 16),
            HeroDetailMatchesCard(detail: detail),
          ],
        ],
      ),
    );
  }
}

class _HeroComparePickerDialog extends StatelessWidget {
  const _HeroComparePickerDialog({required this.options});

  final List<HeroCompareOption> options;

  static Future<int?> show(
    BuildContext context,
    {required List<HeroCompareOption> options,}
  ) {
    return showDialog<int>(
      context: context,
      builder: (_) => _HeroComparePickerDialog(options: options),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Compare with'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final option in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option.heroName),
                onTap: () => Navigator.of(context).pop(option.heroId),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
