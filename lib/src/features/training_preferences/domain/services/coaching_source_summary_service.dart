import '../models/coaching_source_summary.dart';
import '../models/training_preferences.dart';

class CoachingSourceSummaryService {
  const CoachingSourceSummaryService();

  CoachingSourceSummary build(
    TrainingPreferences preferences, {
    String Function(int heroId)? heroLabelFor,
  }) {
    if (!preferences.prefersManualSetup) {
      return const CoachingSourceSummary(
        headline: 'Coaching source: App read',
        detail: 'Using the app read for role and hero block.',
      );
    }

    final detailParts = <String>[];
    final preferredRole = preferences.activePreferredRole;
    if (preferredRole != null) {
      detailParts.add('Role: ${preferredRole.label}');
    }

    final heroBlockLabel = _heroBlockLabel(
      preferences.activeLockedHeroIds,
      heroLabelFor,
    );
    if (heroBlockLabel != null) {
      detailParts.add('Hero block: $heroBlockLabel');
    }

    return CoachingSourceSummary(
      headline: 'Coaching source: Manual setup',
      detail: detailParts.isEmpty
          ? 'Manual setup is on, but no role or hero block is locked.'
          : detailParts.join(' | '),
    );
  }

  String? _heroBlockLabel(
    List<int> heroIds,
    String Function(int heroId)? heroLabelFor,
  ) {
    if (heroIds.isEmpty) {
      return null;
    }

    if (heroLabelFor == null) {
      return heroIds.length == 1 ? '1 hero' : '2 heroes';
    }

    final heroLabels = heroIds
        .map((heroId) => heroLabelFor(heroId).trim())
        .where((label) => label.isNotEmpty)
        .toList(growable: false);
    if (heroLabels.length != heroIds.length) {
      return heroIds.length == 1 ? '1 hero' : '2 heroes';
    }

    return heroLabels.join(' + ');
  }
}
