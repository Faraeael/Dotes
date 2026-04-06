import 'package:dotes/src/features/dashboard/presentation/utils/imported_sample_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/roles/domain/models/player_role.dart';
import 'package:dotes/src/features/roles/domain/models/role_confidence.dart';
import 'package:dotes/src/features/roles/domain/models/sample_role_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImportedSampleSummary.topHeroes', () {
    test('includes heroes with 3+ games sorted by game count descending', () {
      final summary = ImportedSampleSummary.fromImportedPlayer(
        _player([
          // Hero 1 (id 53): 5 games, 3 wins
          _match(heroId: 53, didWin: true),
          _match(heroId: 53, didWin: true),
          _match(heroId: 53, didWin: true),
          _match(heroId: 53, didWin: false),
          _match(heroId: 53, didWin: false),
          // Hero 2 (id 1): 4 games, 2 wins
          _match(heroId: 1, didWin: true),
          _match(heroId: 1, didWin: true),
          _match(heroId: 1, didWin: false),
          _match(heroId: 1, didWin: false),
          // Hero 3 (id 2): 3 games, 1 win
          _match(heroId: 2, didWin: true),
          _match(heroId: 2, didWin: false),
          _match(heroId: 2, didWin: false),
          // Hero 4 (id 3): 2 games — below threshold, excluded
          _match(heroId: 3, didWin: true),
          _match(heroId: 3, didWin: false),
        ]),
        _clearRoleSummary(),
      );

      expect(summary.topHeroes, hasLength(3));
      // Sorted by games desc: hero 53 (5g), hero 1 (4g), hero 2 (3g)
      expect(summary.topHeroes[0].games, 5);
      expect(summary.topHeroes[0].winRatePercent, 60);
      expect(summary.topHeroes[1].games, 4);
      expect(summary.topHeroes[1].winRatePercent, 50);
      expect(summary.topHeroes[2].games, 3);
      expect(summary.topHeroes[2].winRatePercent, 33);
    });

    test('topHeroes is empty when fewer than 2 heroes qualify', () {
      final summary = ImportedSampleSummary.fromImportedPlayer(
        _player([
          // Only one hero with 3+ games
          _match(heroId: 53, didWin: true),
          _match(heroId: 53, didWin: true),
          _match(heroId: 53, didWin: false),
          // Another hero with only 2 games — excluded
          _match(heroId: 1, didWin: true),
          _match(heroId: 1, didWin: false),
        ]),
        _clearRoleSummary(),
      );

      expect(summary.topHeroes, isEmpty);
    });

    test('topHeroes capped at 3 even when more qualify', () {
      final summary = ImportedSampleSummary.fromImportedPlayer(
        _player([
          _match(heroId: 10, didWin: true),
          _match(heroId: 10, didWin: true),
          _match(heroId: 10, didWin: true),
          _match(heroId: 11, didWin: true),
          _match(heroId: 11, didWin: true),
          _match(heroId: 11, didWin: true),
          _match(heroId: 12, didWin: true),
          _match(heroId: 12, didWin: true),
          _match(heroId: 12, didWin: true),
          _match(heroId: 13, didWin: true),
          _match(heroId: 13, didWin: true),
          _match(heroId: 13, didWin: true),
        ]),
        _clearRoleSummary(),
      );

      expect(summary.topHeroes, hasLength(3));
    });
  });

  group('ImportedSampleSummary.primaryRoleAdherenceLabel', () {
    test('is populated for a clear role read', () {
      // 8 of 10 matches in primary role → 80%
      final summary = ImportedSampleSummary.fromImportedPlayer(
        _player([_match(heroId: 53, didWin: true)]),
        SampleRoleSummary(
          primaryRole: PlayerRole.carry,
          primaryRoleConfidence: RoleConfidence.high,
          readType: SampleRoleReadType.clear,
          roleDistribution: {
            PlayerRole.carry: 8,
            PlayerRole.mid: 1,
            PlayerRole.offlane: 0,
            PlayerRole.softSupport: 0,
            PlayerRole.hardSupport: 0,
            PlayerRole.unknown: 1,
          },
        ),
      );

      expect(summary.primaryRoleAdherenceLabel, '80%');
      expect(
        summary.roleRationaleLines,
        contains('8 of 10 matches currently lean Carry.'),
      );
    });

    test('is populated for a mixed role read', () {
      final summary = ImportedSampleSummary.fromImportedPlayer(
        _player([_match(heroId: 53, didWin: true)]),
        SampleRoleSummary(
          primaryRole: PlayerRole.mid,
          primaryRoleConfidence: RoleConfidence.medium,
          readType: SampleRoleReadType.mixedRoles,
          roleDistribution: {
            PlayerRole.carry: 3,
            PlayerRole.mid: 5,
            PlayerRole.offlane: 0,
            PlayerRole.softSupport: 0,
            PlayerRole.hardSupport: 0,
            PlayerRole.unknown: 2,
          },
        ),
      );

      expect(summary.primaryRoleAdherenceLabel, '50%');
      expect(
        summary.roleRationaleLines.first,
        'Recent matches are split across multiple role patterns, so the app keeps the role read broad.',
      );
    });

    test('is null for a small sample read', () {
      final summary = ImportedSampleSummary.fromImportedPlayer(
        _player([_match(heroId: 53, didWin: true)]),
        SampleRoleSummary(
          primaryRole: PlayerRole.carry,
          primaryRoleConfidence: RoleConfidence.low,
          readType: SampleRoleReadType.smallSample,
          roleDistribution: {
            PlayerRole.carry: 2,
            PlayerRole.mid: 0,
            PlayerRole.offlane: 0,
            PlayerRole.softSupport: 0,
            PlayerRole.hardSupport: 0,
            PlayerRole.unknown: 1,
          },
        ),
      );

      expect(summary.primaryRoleAdherenceLabel, isNull);
      expect(
        summary.roleRationaleLines.first,
        'This sample is still small, so the role read can move quickly with a few more games.',
      );
    });

    test('is null for an unclear signals read', () {
      final summary = ImportedSampleSummary.fromImportedPlayer(
        _player([_match(heroId: 53, didWin: true)]),
        SampleRoleSummary(
          primaryRole: PlayerRole.unknown,
          primaryRoleConfidence: RoleConfidence.low,
          readType: SampleRoleReadType.unclearSignals,
          roleDistribution: {
            PlayerRole.carry: 0,
            PlayerRole.mid: 0,
            PlayerRole.offlane: 0,
            PlayerRole.softSupport: 0,
            PlayerRole.hardSupport: 0,
            PlayerRole.unknown: 5,
          },
        ),
      );

      expect(summary.primaryRoleAdherenceLabel, isNull);
      expect(
        summary.roleRationaleLines,
        contains('100% of matches stayed too noisy for a precise role label.'),
      );
    });
  });
}

ImportedPlayerData _player(List<RecentMatch> matches) {
  return ImportedPlayerData(
    profile: const PlayerProfileSummary(
      accountId: 86745912,
      personaName: 'Tester',
      avatarUrl: '',
      rankTier: 50,
      leaderboardRank: null,
    ),
    recentMatches: matches,
  );
}

RecentMatch _match({required int heroId, required bool didWin}) {
  return RecentMatch(
    matchId: heroId * 1000 + (didWin ? 1 : 0),
    heroId: heroId,
    startedAt: DateTime.utc(2025, 3, 20),
    duration: const Duration(minutes: 30),
    kills: 5,
    deaths: 3,
    assists: 7,
    didWin: didWin,
    partySize: 1,
  );
}

SampleRoleSummary _clearRoleSummary() {
  return const SampleRoleSummary(
    primaryRole: PlayerRole.carry,
    primaryRoleConfidence: RoleConfidence.high,
    readType: SampleRoleReadType.clear,
    roleDistribution: {
      PlayerRole.carry: 8,
      PlayerRole.mid: 1,
      PlayerRole.offlane: 0,
      PlayerRole.softSupport: 0,
      PlayerRole.hardSupport: 0,
      PlayerRole.unknown: 1,
    },
  );
}
