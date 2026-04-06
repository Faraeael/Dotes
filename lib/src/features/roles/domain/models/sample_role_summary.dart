import 'player_role.dart';
import 'role_confidence.dart';

enum SampleRoleReadType { clear, mixedRoles, unclearSignals, smallSample }

class SampleRoleSummary {
  const SampleRoleSummary({
    required this.primaryRole,
    required this.primaryRoleConfidence,
    required this.readType,
    required this.roleDistribution,
    this.roleCrossCheckLabel,
  });

  final PlayerRole primaryRole;
  final RoleConfidence primaryRoleConfidence;
  final SampleRoleReadType readType;
  final Map<PlayerRole, int> roleDistribution;
  final String? roleCrossCheckLabel;

  int get totalMatches =>
      roleDistribution.values.fold<int>(0, (sum, count) => sum + count);

  int get primaryRoleMatchCount => primaryRole == PlayerRole.unknown
      ? 0
      : (roleDistribution[primaryRole] ?? 0);

  double get primaryRoleShare =>
      totalMatches == 0 ? 0 : primaryRoleMatchCount / totalMatches;

  double get unknownShare => totalMatches == 0
      ? 0
      : (roleDistribution[PlayerRole.unknown] ?? 0) / totalMatches;

  bool get hasClearPrimaryRole =>
      readType == SampleRoleReadType.clear &&
      primaryRole != PlayerRole.unknown &&
      primaryRoleConfidence != RoleConfidence.low;

  // Exact role names stay behind a stricter trust bar than the general
  // "clear role read" state. The current engine only uses summary fields from
  // recent match imports, so UI wording should stay estimate-first unless one
  // role clearly dominates a solid sample.
  bool get hasTrustedPrimaryRoleForFocus =>
      readType == SampleRoleReadType.clear &&
      primaryRole != PlayerRole.unknown &&
      primaryRoleConfidence == RoleConfidence.high &&
      primaryRoleMatchCount >= 5 &&
      primaryRoleShare >= 0.7 &&
      unknownShare <= 0.2;

  String get primaryRoleLabel {
    if (hasTrustedPrimaryRoleForFocus) {
      return primaryRole.label;
    }

    if (hasClearPrimaryRole && _isCoreRole(primaryRole)) {
      return 'Core role leaning';
    }

    if (hasClearPrimaryRole && _isSupportRole(primaryRole)) {
      return 'Support role leaning';
    }

    return 'Mixed / still estimating';
  }

  String get estimateStrengthLabel {
    final baseLabel = switch (primaryRoleConfidence) {
      RoleConfidence.high => 'Strong estimate',
      RoleConfidence.medium => 'Moderate estimate',
      RoleConfidence.low => 'Low-confidence estimate',
    };

    if (roleCrossCheckLabel == null ||
        primaryRoleConfidence == RoleConfidence.low) {
      return baseLabel;
    }

    return '$baseLabel + hero-role cross-check';
  }

  String? get trustedRoleLabelForFocus =>
      hasTrustedPrimaryRoleForFocus ? primaryRole.label : null;

  String get focusRoleScopeLabel {
    if (trustedRoleLabelForFocus != null) {
      return trustedRoleLabelForFocus!;
    }

    if (hasClearPrimaryRole && _isCoreRole(primaryRole)) {
      return 'one core role';
    }

    return 'one role';
  }

  String get reasonLabel {
    final baseLabel = switch (readType) {
      SampleRoleReadType.clear =>
        hasTrustedPrimaryRoleForFocus
            ? 'Recent matches lean strongly toward one role read from the available summary stats.'
            : 'Recent matches lean in one direction, but the current role read is still an estimate from limited summary stats.',
      SampleRoleReadType.mixedRoles =>
        'Your recent matches point toward multiple role patterns, so the app keeps the role estimate broad for now.',
      SampleRoleReadType.unclearSignals =>
        'Too many recent matches lacked enough lane or economy signal for a precise role estimate.',
      SampleRoleReadType.smallSample =>
        'This sample is still small, so the current role estimate can move quickly over the next few matches.',
    };

    if (roleCrossCheckLabel == null) {
      return baseLabel;
    }

    return '$baseLabel $roleCrossCheckLabel';
  }

  List<String> get rationaleLines {
    final lines = <String>[
      switch (readType) {
        SampleRoleReadType.clear =>
          hasTrustedPrimaryRoleForFocus
              ? 'One role clearly leads the current sample from the available summary stats.'
              : 'One role leads the sample, but the read still stays estimate-first.',
        SampleRoleReadType.mixedRoles =>
          'Recent matches are split across multiple role patterns, so the app keeps the role read broad.',
        SampleRoleReadType.unclearSignals =>
          'Too many matches lacked enough lane or economy signal for a precise role read.',
        SampleRoleReadType.smallSample =>
          'This sample is still small, so the role read can move quickly with a few more games.',
      },
    ];

    if (hasClearPrimaryRole && primaryRole != PlayerRole.unknown) {
      lines.add(
        '$primaryRoleMatchCount of $totalMatches matches currently lean ${hasTrustedPrimaryRoleForFocus ? primaryRole.label : focusRoleScopeLabel}.',
      );
    }

    if (unknownShare > 0) {
      lines.add(
        '${(unknownShare * 100).round()}% of matches stayed too noisy for a precise role label.',
      );
    }

    if (roleCrossCheckLabel != null) {
      lines.add(roleCrossCheckLabel!);
    }

    return lines;
  }

  String? get roleMixDetailsLabel {
    if (!hasTrustedPrimaryRoleForFocus) {
      return null;
    }

    final entries =
        roleDistribution.entries
            .where(
              (entry) => entry.key != PlayerRole.unknown && entry.value > 0,
            )
            .toList()
          ..sort((left, right) {
            final countCompare = right.value.compareTo(left.value);
            if (countCompare != 0) {
              return countCompare;
            }

            return left.key.sortOrder.compareTo(right.key.sortOrder);
          });

    if (entries.isEmpty) {
      return null;
    }

    final parts = entries
        .map((entry) => '${entry.key.label} ${entry.value}')
        .join(', ');

    return 'Recent role estimate mix: $parts';
  }

  bool _isCoreRole(PlayerRole role) {
    return role == PlayerRole.carry ||
        role == PlayerRole.mid ||
        role == PlayerRole.offlane;
  }

  bool _isSupportRole(PlayerRole role) {
    return role == PlayerRole.softSupport || role == PlayerRole.hardSupport;
  }
}
