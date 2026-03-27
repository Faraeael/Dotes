import '../../../player_import/domain/models/imported_player_data.dart';
import '../../../player_import/domain/models/recent_match.dart';
import '../../../roles/domain/models/sample_role_summary.dart';
import '../models/coaching_insight.dart';

class CoachingInsightsAnalyzer {
  const CoachingInsightsAnalyzer();

  static const int _minimumReliableSample = 5;

  List<CoachingInsight> analyze(
    ImportedPlayerData importedPlayer,
    SampleRoleSummary roleSummary,
  ) {
    final matches = importedPlayer.recentMatches;

    if (matches.length < _minimumReliableSample) {
      return [_buildLimitedConfidenceInsight(matches.length)];
    }

    final insights = <CoachingInsight>[];

    final weakRecentTrendInsight = _buildWeakRecentTrendInsight(matches);
    if (weakRecentTrendInsight != null) {
      insights.add(weakRecentTrendInsight);
    }

    final earlyDeathRiskInsight = _buildEarlyDeathRiskInsight(matches);
    if (earlyDeathRiskInsight != null) {
      insights.add(earlyDeathRiskInsight);
    }

    final comfortHeroDependenceInsight =
        _buildComfortHeroDependenceInsight(matches);
    if (comfortHeroDependenceInsight != null) {
      insights.add(comfortHeroDependenceInsight);
    }

    final heroPoolSpreadInsight = _buildHeroPoolSpreadInsight(matches);
    final specializationRecommendationInsight =
        _buildSpecializationRecommendationInsight(
          matches,
          roleSummary,
          hasHeroPoolSpread: heroPoolSpreadInsight != null,
        );
    if (specializationRecommendationInsight != null) {
      insights.add(specializationRecommendationInsight);
    }

    if (heroPoolSpreadInsight != null && specializationRecommendationInsight == null) {
      insights.add(heroPoolSpreadInsight);
    }

    insights.sort(_compareInsights);
    return insights;
  }

  CoachingInsight _buildLimitedConfidenceInsight(int sampleSize) {
    final matchLabel = sampleSize == 1 ? 'match' : 'matches';

    return CoachingInsight(
      type: CoachingInsightType.limitedConfidence,
      title: 'Limited confidence',
      explanation:
          'This read is still thin: only $sampleSize recent $matchLabel are available, so use the next few games to build a cleaner sample before trusting stronger conclusions.',
      severity: CoachingInsightSeverity.low,
      confidence: CoachingInsightConfidence.low,
    );
  }

  CoachingInsight? _buildWeakRecentTrendInsight(List<RecentMatch> matches) {
    final wins = matches.where((match) => match.didWin).length;
    final winRate = wins / matches.length;

    if (winRate > 0.4) {
      return null;
    }

    final severity = winRate <= 0.25
        ? CoachingInsightSeverity.high
        : CoachingInsightSeverity.medium;

    return CoachingInsight(
      type: CoachingInsightType.weakRecentTrend,
      title: 'Weak recent trend',
      explanation:
          'Recent results are below break-even: $wins wins in ${matches.length} matches (${_formatPercent(winRate)}). Treat this as a short-term reset signal, not a permanent verdict.',
      severity: severity,
      confidence: _confidenceForSample(matches.length),
    );
  }

  CoachingInsight? _buildEarlyDeathRiskInsight(List<RecentMatch> matches) {
    final totalDeaths = matches.fold<int>(
      0,
      (sum, match) => sum + match.deaths,
    );
    final averageDeaths = totalDeaths / matches.length;
    final highDeathMatches = matches.where((match) => match.deaths >= 8).length;

    if (averageDeaths < 7 && highDeathMatches < _requiredCount(matches, 0.5)) {
      return null;
    }

    final severity =
        averageDeaths >= 9 || highDeathMatches >= _requiredCount(matches, 0.7)
        ? CoachingInsightSeverity.high
        : CoachingInsightSeverity.medium;

    return CoachingInsight(
      type: CoachingInsightType.earlyDeathRisk,
      title: 'Early death risk',
      explanation:
          'Deaths are running high in this block: ${averageDeaths.toStringAsFixed(1)} per match on average, with $highDeathMatches games at 8 or more. That usually means less time to farm, pressure, and reset the map.',
      severity: severity,
      confidence: _confidenceForSample(matches.length),
    );
  }

  CoachingInsight? _buildHeroPoolSpreadInsight(List<RecentMatch> matches) {
    final heroUsage = _heroUsageCounts(matches);
    final uniqueHeroCount = heroUsage.length;
    final spreadRatio = uniqueHeroCount / matches.length;

    if (uniqueHeroCount < 5 || spreadRatio < 0.6) {
      return null;
    }

    final severity = uniqueHeroCount >= 8 || spreadRatio >= 0.8
        ? CoachingInsightSeverity.high
        : CoachingInsightSeverity.medium;

    return CoachingInsight(
      type: CoachingInsightType.heroPoolSpread,
      title: 'Hero pool spread',
      explanation:
          'Your recent sample is split across $uniqueHeroCount heroes in ${matches.length} matches. For a short coaching block, that much variety can hide repeatable mistakes and slow down pattern-building.',
      severity: severity,
      confidence: _confidenceForSample(matches.length),
    );
  }

  CoachingInsight? _buildSpecializationRecommendationInsight(
    List<RecentMatch> matches,
    SampleRoleSummary roleSummary, {
    required bool hasHeroPoolSpread,
  }) {
    final heroUsage = _heroUsageCounts(matches);
    final topHeroCount = heroUsage.values.fold<int>(
      0,
      (best, count) => count > best ? count : best,
    );
    final topTwoHeroShare = _topNMatchShare(heroUsage, matches.length, 2);
    final lowRepeatability = topHeroCount <= 2 || topTwoHeroShare < 0.55;
    final mixedOrUnclearRoleRead = !roleSummary.hasClearPrimaryRole;

    var signalCount = 0;
    if (hasHeroPoolSpread) {
      signalCount++;
    }
    if (mixedOrUnclearRoleRead) {
      signalCount++;
    }
    if (lowRepeatability) {
      signalCount++;
    }

    if (!mixedOrUnclearRoleRead || signalCount < 2) {
      return null;
    }

    final severity = signalCount >= 3
        ? CoachingInsightSeverity.high
        : CoachingInsightSeverity.medium;

    return CoachingInsight(
      type: CoachingInsightType.specializationRecommendation,
      title: 'Specialization recommendation',
      explanation:
          'Your current sample is broad enough to blur short-term feedback. Narrowing to one role and 2 to 3 heroes would make progress easier to measure over the next block.',
      severity: severity,
      confidence: _confidenceForSample(matches.length),
    );
  }

  CoachingInsight? _buildComfortHeroDependenceInsight(
    List<RecentMatch> matches,
  ) {
    final heroUsage = _heroUsageCounts(matches);
    final heroWins = _heroWinCounts(matches);
    final sortedHeroIds = heroUsage.keys.toList()
      ..sort((left, right) {
        final usageCompare = heroUsage[right]!.compareTo(heroUsage[left]!);
        if (usageCompare != 0) {
          return usageCompare;
        }

        return left.compareTo(right);
      });

    final topHeroIds = sortedHeroIds.take(2).toList(growable: false);
    final topHeroMatches = topHeroIds.fold<int>(
      0,
      (sum, heroId) => sum + heroUsage[heroId]!,
    );
    final totalWins = matches.where((match) => match.didWin).length;
    final topHeroWins = topHeroIds.fold<int>(
      0,
      (sum, heroId) => sum + (heroWins[heroId] ?? 0),
    );
    final matchShare = topHeroMatches / matches.length;
    final winShare = totalWins == 0 ? 0.0 : topHeroWins / totalWins;

    if (matchShare < 0.6 && winShare < 0.75) {
      return null;
    }

    final severity = matchShare >= 0.8 || winShare >= 0.85
        ? CoachingInsightSeverity.high
        : CoachingInsightSeverity.medium;
    final topHeroCount = topHeroIds.length;
    final winDetail = totalWins == 0
        ? ''
        : ' and $topHeroWins of $totalWins wins';

    return CoachingInsight(
      type: CoachingInsightType.comfortHeroDependence,
      title: 'Comfort hero dependence',
      explanation:
          'This sample is anchored by a small comfort core: $topHeroCount heroes account for $topHeroMatches of ${matches.length} matches$winDetail. That can be a strength if you use it intentionally.',
      severity: severity,
      confidence: _confidenceForSample(matches.length),
    );
  }

  Map<int, int> _heroUsageCounts(List<RecentMatch> matches) {
    final usage = <int, int>{};

    for (final match in matches) {
      usage.update(match.heroId, (count) => count + 1, ifAbsent: () => 1);
    }

    return usage;
  }

  Map<int, int> _heroWinCounts(List<RecentMatch> matches) {
    final wins = <int, int>{};

    for (final match in matches) {
      if (!match.didWin) {
        continue;
      }

      wins.update(match.heroId, (count) => count + 1, ifAbsent: () => 1);
    }

    return wins;
  }

  CoachingInsightConfidence _confidenceForSample(int sampleSize) {
    if (sampleSize >= 10) {
      return CoachingInsightConfidence.high;
    }

    if (sampleSize >= 7) {
      return CoachingInsightConfidence.medium;
    }

    return CoachingInsightConfidence.low;
  }

  int _requiredCount(List<RecentMatch> matches, double share) {
    return (matches.length * share).ceil();
  }

  double _topNMatchShare(Map<int, int> heroUsage, int totalMatches, int count) {
    if (totalMatches == 0) {
      return 0;
    }

    final topCounts = heroUsage.values.toList()..sort((left, right) => right.compareTo(left));
    final usedMatches = topCounts.take(count).fold<int>(0, (sum, value) => sum + value);
    return usedMatches / totalMatches;
  }

  String _formatPercent(double value) {
    return '${(value * 100).round()}%';
  }

  int _compareInsights(CoachingInsight left, CoachingInsight right) {
    final severityCompare = right.severity.sortWeight.compareTo(
      left.severity.sortWeight,
    );
    if (severityCompare != 0) {
      return severityCompare;
    }

    final confidenceCompare = right.confidence.sortWeight.compareTo(
      left.confidence.sortWeight,
    );
    if (confidenceCompare != 0) {
      return confidenceCompare;
    }

    return _typeSortOrder(left.type).compareTo(_typeSortOrder(right.type));
  }

  int _typeSortOrder(CoachingInsightType type) {
    return switch (type) {
      CoachingInsightType.weakRecentTrend => 0,
      CoachingInsightType.earlyDeathRisk => 1,
      CoachingInsightType.specializationRecommendation => 2,
      CoachingInsightType.comfortHeroDependence => 3,
      CoachingInsightType.heroPoolSpread => 4,
      CoachingInsightType.limitedConfidence => 5,
    };
  }
}
