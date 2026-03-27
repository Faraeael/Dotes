import '../../../player_import/domain/models/recent_match.dart';
import '../models/inferred_match_role.dart';
import '../models/player_role.dart';
import '../models/role_confidence.dart';
import '../models/sample_role_summary.dart';

class RoleInferenceService {
  const RoleInferenceService();

  // Current role reads are intentionally conservative estimates.
  //
  // The app only imports the lightweight OpenDota recent-match summary fields
  // right now: lane, lane_role, is_roaming, last_hits, gold_per_min,
  // xp_per_min, kills, deaths, and assists. That is enough for a cautious role
  // estimate, but it is weaker than replay-grade or richer parsed-match role
  // systems. When the available summary stats do not support an honest read,
  // this service should fall back to Unknown instead of forcing a label.
  //
  // Future improvements should prefer richer inputs such as detailed parsed
  // match fields, team-relative economy context, and replay-derived position
  // traces before relaxing these guardrails.
  InferredMatchRole inferMatchRole(RecentMatch match) {
    final laneRole = match.laneRole;
    final lastHits = match.lastHits;
    final goldPerMin = match.goldPerMin;
    final xpPerMin = match.xpPerMin;
    final assists = match.assists;
    final kills = match.kills;
    final deaths = match.deaths;
    final isRoaming = match.isRoaming ?? false;
    final hasStrongCarryFarm = _meetsAll([
      lastHits != null && lastHits >= 175,
      goldPerMin != null && goldPerMin >= 550,
    ]);
    final hasCarryFarm = _meetsAll([
      lastHits != null && lastHits >= 160,
      goldPerMin != null && goldPerMin >= 520,
    ]);
    final looksFightHeavyCore = assists >= 11 || deaths >= 8;

    if (laneRole == 2 &&
        _meetsAny([
          xpPerMin != null && xpPerMin >= 500,
          goldPerMin != null && goldPerMin >= 480,
          lastHits != null && lastHits >= 100,
          kills >= 8,
        ])) {
      return const InferredMatchRole(
        role: PlayerRole.mid,
        confidence: RoleConfidence.high,
      );
    }

    if (laneRole == 1) {
      // Safe-lane farm alone is not enough to call a match "Carry".
      // Farm-heavy offlane/core games can overlap with these numbers, so
      // the carry tag only appears when the rest of the line also looks
      // clean and carry-like.
      if (_meetsAll([
        hasStrongCarryFarm,
        assists <= 8,
        deaths <= 6,
        _meetsAny([
          xpPerMin != null && xpPerMin >= 540,
          kills >= 8,
        ]),
      ])) {
        return const InferredMatchRole(
          role: PlayerRole.carry,
          confidence: RoleConfidence.high,
        );
      }

      if (_meetsAll([
        hasCarryFarm,
        assists <= 9,
        deaths <= 7,
        _meetsAny([
          xpPerMin != null && xpPerMin >= 520,
          kills >= 7,
        ]),
      ])) {
        return const InferredMatchRole(
          role: PlayerRole.carry,
          confidence: RoleConfidence.medium,
        );
      }

      if (hasCarryFarm && looksFightHeavyCore) {
        return const InferredMatchRole(
          role: PlayerRole.unknown,
          confidence: RoleConfidence.low,
        );
      }

      if (_meetsAny([
        lastHits != null && lastHits <= 60,
        goldPerMin != null && goldPerMin <= 380,
      ]) &&
          assists >= 10) {
        return const InferredMatchRole(
          role: PlayerRole.hardSupport,
          confidence: RoleConfidence.medium,
        );
      }
    }

    if (laneRole == 3) {
      if (_meetsAll([
        lastHits != null && lastHits >= 110,
        goldPerMin != null && goldPerMin >= 420,
      ])) {
        return const InferredMatchRole(
          role: PlayerRole.offlane,
          confidence: RoleConfidence.high,
        );
      }

      if (_meetsAll([
        lastHits != null && lastHits >= 85,
        goldPerMin != null && goldPerMin >= 380,
      ])) {
        return const InferredMatchRole(
          role: PlayerRole.offlane,
          confidence: RoleConfidence.medium,
        );
      }

      if (_meetsAny([
        lastHits != null && lastHits <= 70,
        goldPerMin != null && goldPerMin <= 400,
      ]) &&
          assists >= 10) {
        return const InferredMatchRole(
          role: PlayerRole.softSupport,
          confidence: RoleConfidence.medium,
        );
      }
    }

    if (isRoaming &&
        assists >= 10 &&
        _meetsAny([
          lastHits != null && lastHits <= 70,
          goldPerMin != null && goldPerMin <= 400,
        ])) {
      return const InferredMatchRole(
        role: PlayerRole.softSupport,
        confidence: RoleConfidence.medium,
      );
    }

    if (_meetsAll([
      xpPerMin != null && xpPerMin >= 550,
      goldPerMin != null && goldPerMin >= 480,
    ]) &&
        kills >= 8) {
      return const InferredMatchRole(
        role: PlayerRole.mid,
        confidence: RoleConfidence.low,
      );
    }

    return const InferredMatchRole(
      role: PlayerRole.unknown,
      confidence: RoleConfidence.low,
    );
  }

  SampleRoleSummary summarizeSample(List<RecentMatch> matches) {
    final distribution = {
      PlayerRole.carry: 0,
      PlayerRole.mid: 0,
      PlayerRole.offlane: 0,
      PlayerRole.softSupport: 0,
      PlayerRole.hardSupport: 0,
      PlayerRole.unknown: 0,
    };

    for (final match in matches) {
      final inferredRole = inferMatchRole(match);
      distribution.update(inferredRole.role, (count) => count + 1);
    }

    final knownEntries = distribution.entries
        .where((entry) => entry.key != PlayerRole.unknown && entry.value > 0)
        .toList()
      ..sort((left, right) {
        final countCompare = right.value.compareTo(left.value);
        if (countCompare != 0) {
          return countCompare;
        }

        return left.key.sortOrder.compareTo(right.key.sortOrder);
      });

    if (knownEntries.isEmpty) {
      return _buildLowConfidenceSummary(
        readType: SampleRoleReadType.unclearSignals,
        roleDistribution: distribution,
      );
    }

    final primaryEntry = knownEntries.first;
    final secondaryCount = knownEntries.length > 1 ? knownEntries[1].value : 0;
    final primaryShare = matches.isEmpty ? 0.0 : primaryEntry.value / matches.length;
    final unknownCount = distribution[PlayerRole.unknown] ?? 0;
    final readType = _summarizeReadType(
      primaryCount: primaryEntry.value,
      secondaryCount: secondaryCount,
      totalMatches: matches.length,
      unknownCount: unknownCount,
      primaryShare: primaryShare,
    );

    final confidence = _summarizePrimaryRoleConfidence(
      readType: readType,
      primaryCount: primaryEntry.value,
      totalMatches: matches.length,
      unknownCount: unknownCount,
      primaryShare: primaryShare,
    );

    if (confidence == RoleConfidence.low) {
      return _buildLowConfidenceSummary(
        readType: readType,
        roleDistribution: distribution,
      );
    }

    return SampleRoleSummary(
      primaryRole: primaryEntry.key,
      primaryRoleConfidence: confidence,
      readType: readType,
      roleDistribution: distribution,
    );
  }

  SampleRoleReadType _summarizeReadType({
    required int primaryCount,
    required int secondaryCount,
    required int totalMatches,
    required int unknownCount,
    required double primaryShare,
  }) {
    final gap = primaryCount - secondaryCount;

    if (totalMatches < 5) {
      return SampleRoleReadType.smallSample;
    }

    if (unknownCount > totalMatches ~/ 2) {
      return SampleRoleReadType.unclearSignals;
    }

    if (primaryShare >= 0.6 && gap >= 2) {
      return SampleRoleReadType.clear;
    }

    if (primaryShare >= 0.5 && gap >= 2 && unknownCount == 0) {
      return SampleRoleReadType.clear;
    }

    return SampleRoleReadType.mixedRoles;
  }

  RoleConfidence _summarizePrimaryRoleConfidence({
    required SampleRoleReadType readType,
    required int primaryCount,
    required int totalMatches,
    required int unknownCount,
    required double primaryShare,
  }) {
    if (readType != SampleRoleReadType.clear) {
      return RoleConfidence.low;
    }

    if (primaryShare >= 0.7 &&
        primaryCount >= 5 &&
        unknownCount * 5 <= totalMatches) {
      return RoleConfidence.high;
    }

    return RoleConfidence.medium;
  }

  SampleRoleSummary _buildLowConfidenceSummary({
    required SampleRoleReadType readType,
    required Map<PlayerRole, int> roleDistribution,
  }) {
    return SampleRoleSummary(
      primaryRole: PlayerRole.unknown,
      primaryRoleConfidence: RoleConfidence.low,
      readType: readType,
      roleDistribution: roleDistribution,
    );
  }

  bool _meetsAny(List<bool> checks) => checks.any((check) => check);

  bool _meetsAll(List<bool> checks) => checks.every((check) => check);
}
