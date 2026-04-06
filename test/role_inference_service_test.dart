import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/roles/domain/models/player_role.dart';
import 'package:dotes/src/features/roles/domain/models/role_confidence.dart';
import 'package:dotes/src/features/roles/domain/models/sample_role_summary.dart';
import 'package:dotes/src/features/roles/domain/services/role_inference_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = RoleInferenceService();

  group('RoleInferenceService', () {
    test('infers mid from clear lane and farm signals', () {
      final inferredRole = service.inferMatchRole(
        _match(
          laneRole: 2,
          kills: 10,
          goldPerMin: 520,
          xpPerMin: 600,
          lastHits: 160,
        ),
      );

      expect(inferredRole.role, PlayerRole.mid);
      expect(inferredRole.confidence, RoleConfidence.high);
    });

    test('infers hard support from safe lane low farm high assist signal', () {
      final inferredRole = service.inferMatchRole(
        _match(laneRole: 1, assists: 14, goldPerMin: 320, lastHits: 28),
      );

      expect(inferredRole.role, PlayerRole.hardSupport);
      expect(inferredRole.confidence, RoleConfidence.medium);
    });

    test('keeps farm-heavy fight-heavy safe lane samples out of carry', () {
      final inferredRole = service.inferMatchRole(
        _match(
          laneRole: 1,
          kills: 6,
          deaths: 8,
          assists: 11,
          goldPerMin: 530,
          xpPerMin: 500,
          lastHits: 164,
        ),
      );

      expect(inferredRole.role, PlayerRole.unknown);
      expect(inferredRole.confidence, RoleConfidence.low);
    });

    test('infers offlane from clear lane three core farm signals', () {
      final inferredRole = service.inferMatchRole(
        _match(
          laneRole: 3,
          kills: 6,
          assists: 9,
          goldPerMin: 455,
          xpPerMin: 510,
          lastHits: 124,
        ),
      );

      expect(inferredRole.role, PlayerRole.offlane);
      expect(inferredRole.confidence, RoleConfidence.high);
    });

    test('returns unknown when available signals are not reliable enough', () {
      final inferredRole = service.inferMatchRole(
        _match(assists: 7, goldPerMin: 430, lastHits: 95),
      );

      expect(inferredRole.role, PlayerRole.unknown);
      expect(inferredRole.confidence, RoleConfidence.low);
    });

    test('summarizes a clear primary role with confidence', () {
      final summary = service.summarizeSample([
        _match(
          laneRole: 1,
          kills: 8,
          deaths: 4,
          assists: 7,
          goldPerMin: 565,
          xpPerMin: 560,
          lastHits: 184,
        ),
        _match(
          laneRole: 1,
          kills: 8,
          deaths: 5,
          assists: 8,
          goldPerMin: 555,
          xpPerMin: 548,
          lastHits: 178,
        ),
        _match(
          laneRole: 1,
          kills: 7,
          deaths: 5,
          assists: 8,
          goldPerMin: 540,
          xpPerMin: 530,
          lastHits: 170,
        ),
        _match(
          laneRole: 1,
          kills: 7,
          deaths: 6,
          assists: 9,
          goldPerMin: 525,
          xpPerMin: 522,
          lastHits: 166,
        ),
        _match(
          laneRole: 1,
          kills: 8,
          deaths: 5,
          assists: 8,
          goldPerMin: 552,
          xpPerMin: 540,
          lastHits: 176,
        ),
        _match(laneRole: 3, goldPerMin: 420, lastHits: 95),
        _match(laneRole: 3, assists: 12, goldPerMin: 360, lastHits: 48),
      ]);

      expect(summary.primaryRole, PlayerRole.carry);
      expect(summary.primaryRoleConfidence, RoleConfidence.high);
      expect(summary.primaryRoleLabel, 'Carry');
      expect(summary.readType, SampleRoleReadType.clear);
      expect(
        summary.roleMixDetailsLabel,
        'Recent role estimate mix: Carry 5, Offlane 1, Soft Support 1',
      );
      expect(summary.estimateStrengthLabel, 'Strong estimate');
      expect(summary.roleDistribution[PlayerRole.carry], 5);
    });

    test(
      'adds hero-role cross-check support when local role references align',
      () {
        final summary = service.summarizeSample([
          _match(
            heroId: 48,
            laneRole: 1,
            kills: 8,
            deaths: 4,
            assists: 7,
            goldPerMin: 565,
            xpPerMin: 560,
            lastHits: 184,
          ),
          _match(
            heroId: 67,
            laneRole: 1,
            kills: 8,
            deaths: 5,
            assists: 8,
            goldPerMin: 555,
            xpPerMin: 548,
            lastHits: 178,
          ),
          _match(
            heroId: 18,
            laneRole: 1,
            kills: 7,
            deaths: 5,
            assists: 8,
            goldPerMin: 540,
            xpPerMin: 530,
            lastHits: 170,
          ),
          _match(
            heroId: 48,
            laneRole: 1,
            kills: 7,
            deaths: 6,
            assists: 9,
            goldPerMin: 525,
            xpPerMin: 522,
            lastHits: 166,
          ),
          _match(
            heroId: 67,
            laneRole: 1,
            kills: 8,
            deaths: 5,
            assists: 8,
            goldPerMin: 552,
            xpPerMin: 540,
            lastHits: 176,
          ),
        ], heroRoleHintLabelForHero: _heroRoleHintLabel);

        expect(summary.primaryRole, PlayerRole.carry);
        expect(
          summary.estimateStrengthLabel,
          'Strong estimate + hero-role cross-check',
        );
        expect(
          summary.reasonLabel,
          contains(
            'Tracked hero role references also lean Carry across 5 tagged matches.',
          ),
        );
      },
    );

    test(
      'keeps unclear samples conservative even when hero references lean one role',
      () {
        final summary = service.summarizeSample([
          _match(heroId: 48, assists: 7, goldPerMin: 430, lastHits: 95),
          _match(heroId: 67, assists: 6, goldPerMin: 410, lastHits: 88),
          _match(heroId: 18, assists: 5, goldPerMin: 445, lastHits: 90),
          _match(heroId: 48, assists: 9, goldPerMin: 420, lastHits: 82),
          _match(heroId: 53, assists: 8, goldPerMin: 430, lastHits: 94),
        ], heroRoleHintLabelForHero: _heroRoleHintLabel);

        expect(summary.primaryRole, PlayerRole.unknown);
        expect(summary.primaryRoleConfidence, RoleConfidence.low);
        expect(summary.readType, SampleRoleReadType.unclearSignals);
        expect(summary.estimateStrengthLabel, 'Low-confidence estimate');
        expect(
          summary.reasonLabel,
          contains(
            'Tracked hero role references lean Carry, but the live sample still stays estimate-first.',
          ),
        );
      },
    );

    test('keeps offlane-heavy core samples from becoming carry reads', () {
      final summary = service.summarizeSample([
        _match(
          laneRole: 3,
          kills: 6,
          deaths: 6,
          assists: 9,
          goldPerMin: 455,
          xpPerMin: 510,
          lastHits: 124,
        ),
        _match(
          laneRole: 3,
          kills: 7,
          deaths: 5,
          assists: 8,
          goldPerMin: 448,
          xpPerMin: 500,
          lastHits: 118,
        ),
        _match(
          laneRole: 3,
          kills: 6,
          deaths: 6,
          assists: 10,
          goldPerMin: 438,
          xpPerMin: 495,
          lastHits: 116,
        ),
        _match(
          laneRole: 3,
          kills: 7,
          deaths: 5,
          assists: 9,
          goldPerMin: 452,
          xpPerMin: 505,
          lastHits: 122,
        ),
        _match(
          laneRole: 1,
          kills: 6,
          deaths: 8,
          assists: 11,
          goldPerMin: 528,
          xpPerMin: 500,
          lastHits: 164,
        ),
        _match(
          laneRole: 1,
          kills: 5,
          deaths: 8,
          assists: 12,
          goldPerMin: 525,
          xpPerMin: 495,
          lastHits: 162,
        ),
      ]);

      expect(summary.primaryRole, PlayerRole.offlane);
      expect(summary.primaryRoleConfidence, RoleConfidence.medium);
      expect(summary.primaryRoleLabel, 'Core role leaning');
      expect(summary.trustedRoleLabelForFocus, isNull);
      expect(summary.roleMixDetailsLabel, isNull);
      expect(summary.roleDistribution[PlayerRole.carry], 0);
      expect(summary.roleDistribution[PlayerRole.offlane], 4);
      expect(summary.roleDistribution[PlayerRole.unknown], 2);
    });

    test('returns mixed roles when sample is split across roles', () {
      final summary = service.summarizeSample([
        _match(laneRole: 1, goldPerMin: 560, lastHits: 180),
        _match(laneRole: 1, goldPerMin: 520, lastHits: 155),
        _match(
          laneRole: 2,
          kills: 9,
          goldPerMin: 510,
          xpPerMin: 590,
          lastHits: 145,
        ),
        _match(
          laneRole: 2,
          kills: 8,
          goldPerMin: 500,
          xpPerMin: 570,
          lastHits: 138,
        ),
        _match(laneRole: 3, goldPerMin: 420, lastHits: 92),
        _match(assists: 8, goldPerMin: 430, lastHits: 95),
      ]);

      expect(summary.primaryRole, PlayerRole.unknown);
      expect(summary.primaryRoleConfidence, RoleConfidence.low);
      expect(summary.primaryRoleLabel, 'Mixed / still estimating');
      expect(summary.readType, SampleRoleReadType.mixedRoles);
      expect(
        summary.reasonLabel,
        'Your recent matches point toward multiple role patterns, so the app keeps the role estimate broad for now.',
      );
      expect(summary.roleMixDetailsLabel, isNull);
    });

    test('returns unclear signals when too many matches are unknown', () {
      final summary = service.summarizeSample([
        _match(assists: 7, goldPerMin: 430, lastHits: 95),
        _match(assists: 6, goldPerMin: 410, lastHits: 88),
        _match(assists: 5, goldPerMin: 445, lastHits: 90),
        _match(assists: 9, goldPerMin: 420, lastHits: 82),
        _match(laneRole: 1, goldPerMin: 560, lastHits: 180),
        _match(laneRole: 1, goldPerMin: 520, lastHits: 155),
      ]);

      expect(summary.primaryRole, PlayerRole.unknown);
      expect(summary.primaryRoleConfidence, RoleConfidence.low);
      expect(summary.readType, SampleRoleReadType.unclearSignals);
      expect(
        summary.reasonLabel,
        'Too many recent matches lacked enough lane or economy signal for a precise role estimate.',
      );
      expect(summary.roleMixDetailsLabel, isNull);
    });

    test('role summary is deterministic', () {
      final sample = [
        _match(laneRole: 1, goldPerMin: 560, lastHits: 180),
        _match(
          laneRole: 1,
          kills: 7,
          deaths: 5,
          assists: 8,
          goldPerMin: 552,
          xpPerMin: 540,
          lastHits: 176,
        ),
        _match(laneRole: 3, goldPerMin: 420, lastHits: 92),
        _match(laneRole: 3, assists: 12, goldPerMin: 360, lastHits: 48),
        _match(
          laneRole: 2,
          kills: 8,
          goldPerMin: 500,
          xpPerMin: 570,
          lastHits: 138,
        ),
      ];

      final firstPass = service.summarizeSample(sample);
      final secondPass = service.summarizeSample(sample);

      expect(firstPass.primaryRole, secondPass.primaryRole);
      expect(firstPass.primaryRoleConfidence, secondPass.primaryRoleConfidence);
      expect(firstPass.readType, secondPass.readType);
      expect(firstPass.roleMixDetailsLabel, secondPass.roleMixDetailsLabel);
    });
  });
}

RecentMatch _match({
  int heroId = 1,
  int kills = 5,
  int deaths = 4,
  int assists = 8,
  int? goldPerMin,
  int? xpPerMin,
  int? lastHits,
  int? laneRole,
}) {
  return RecentMatch(
    matchId: heroId,
    heroId: heroId,
    startedAt: DateTime(2025, 3, 20, 18),
    duration: const Duration(minutes: 34),
    kills: kills,
    deaths: deaths,
    assists: assists,
    didWin: true,
    goldPerMin: goldPerMin,
    xpPerMin: xpPerMin,
    lastHits: lastHits,
    laneRole: laneRole,
    partySize: 1,
  );
}

String? _heroRoleHintLabel(int heroId) {
  return switch (heroId) {
    18 || 48 || 67 => 'Carry',
    17 || 22 || 25 => 'Mid tempo core',
    28 || 29 || 96 || 129 || 135 => 'Offlane initiator',
    _ => null,
  };
}
