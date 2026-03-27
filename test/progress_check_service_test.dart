import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/progress/domain/models/progress_check.dart';
import 'package:dotes/src/features/progress/domain/services/progress_check_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = ProgressCheckService();

  group('ProgressCheckService', () {
    test('detects improvement across two 5-match blocks', () {
      final progressCheck = service.build([
        _match(
          matchId: 1,
          hoursAgo: 1,
          heroId: 1,
          didWin: true,
          deaths: 4,
        ),
        _match(
          matchId: 2,
          hoursAgo: 2,
          heroId: 1,
          didWin: true,
          deaths: 3,
        ),
        _match(
          matchId: 3,
          hoursAgo: 3,
          heroId: 2,
          didWin: false,
          deaths: 5,
        ),
        _match(
          matchId: 4,
          hoursAgo: 4,
          heroId: 2,
          didWin: true,
          deaths: 4,
        ),
        _match(
          matchId: 5,
          hoursAgo: 5,
          heroId: 1,
          didWin: false,
          deaths: 4,
        ),
        _match(
          matchId: 6,
          hoursAgo: 6,
          heroId: 3,
          didWin: false,
          deaths: 8,
        ),
        _match(
          matchId: 7,
          hoursAgo: 7,
          heroId: 4,
          didWin: false,
          deaths: 7,
        ),
        _match(
          matchId: 8,
          hoursAgo: 8,
          heroId: 5,
          didWin: true,
          deaths: 6,
        ),
        _match(
          matchId: 9,
          hoursAgo: 9,
          heroId: 6,
          didWin: false,
          deaths: 7,
        ),
        _match(
          matchId: 10,
          hoursAgo: 10,
          heroId: 7,
          didWin: false,
          deaths: 7,
        ),
      ]);

      expect(progressCheck.isReady, isTrue);
      expect(progressCheck.blockSize, 5);
      expect(progressCheck.comparisons[0].label, 'Win rate');
      expect(progressCheck.comparisons[0].direction, ProgressDirection.up);
      expect(progressCheck.comparisons[1].label, 'Deaths');
      expect(progressCheck.comparisons[1].direction, ProgressDirection.down);
      expect(progressCheck.comparisons[2].label, 'Hero pool');
      expect(
        progressCheck.comparisons[2].direction,
        ProgressDirection.narrower,
      );
    });

    test('detects decline across two 10-match blocks when enough matches exist', () {
      final progressCheck = service.build([
        for (var index = 0; index < 10; index++)
          _match(
            matchId: index + 1,
            hoursAgo: index + 1,
            heroId: (index % 8) + 1,
            didWin: index < 3,
            deaths: 8,
          ),
        for (var index = 0; index < 10; index++)
          _match(
            matchId: index + 11,
            hoursAgo: index + 11,
            heroId: (index % 3) + 11,
            didWin: index < 7,
            deaths: 4,
          ),
      ]);

      expect(progressCheck.isReady, isTrue);
      expect(progressCheck.blockSize, 10);
      expect(progressCheck.comparisons[0].direction, ProgressDirection.down);
      expect(progressCheck.comparisons[1].direction, ProgressDirection.up);
      expect(progressCheck.comparisons[2].direction, ProgressDirection.wider);
    });

    test('returns a calm fallback when the sample is too small', () {
      final progressCheck = service.build([
        for (var index = 0; index < 9; index++)
          _match(
            matchId: index + 1,
            hoursAgo: index + 1,
            heroId: 1,
          ),
      ]);

      expect(progressCheck.isReady, isFalse);
      expect(progressCheck.blockSize, isNull);
      expect(progressCheck.comparisons, isEmpty);
      expect(
        progressCheck.fallbackMessage,
        'Need at least 10 recent matches before this progress check becomes useful.',
      );
    });

    test('keeps output deterministic for the same imported sample', () {
      final sample = [
        _match(matchId: 1, hoursAgo: 1, heroId: 1, didWin: true, deaths: 4),
        _match(matchId: 2, hoursAgo: 2, heroId: 1, didWin: true, deaths: 4),
        _match(matchId: 3, hoursAgo: 3, heroId: 2, didWin: false, deaths: 5),
        _match(matchId: 4, hoursAgo: 4, heroId: 2, didWin: true, deaths: 3),
        _match(matchId: 5, hoursAgo: 5, heroId: 3, didWin: false, deaths: 4),
        _match(matchId: 6, hoursAgo: 6, heroId: 4, didWin: false, deaths: 7),
        _match(matchId: 7, hoursAgo: 7, heroId: 5, didWin: false, deaths: 8),
        _match(matchId: 8, hoursAgo: 8, heroId: 6, didWin: true, deaths: 6),
        _match(matchId: 9, hoursAgo: 9, heroId: 7, didWin: false, deaths: 7),
        _match(matchId: 10, hoursAgo: 10, heroId: 8, didWin: false, deaths: 7),
      ];

      final firstPass = service.build(sample);
      final secondPass = service.build(sample);

      expect(firstPass.blockSize, secondPass.blockSize);
      expect(
        firstPass.comparisons.map((comparison) => comparison.direction).toList(),
        secondPass.comparisons
            .map((comparison) => comparison.direction)
            .toList(),
      );
      expect(
        firstPass.comparisons
            .map((comparison) => comparison.detailLabel)
            .toList(),
        secondPass.comparisons
            .map((comparison) => comparison.detailLabel)
            .toList(),
      );
    });
  });
}

RecentMatch _match({
  required int matchId,
  required int hoursAgo,
  required int heroId,
  bool didWin = false,
  int deaths = 4,
}) {
  return RecentMatch(
    matchId: matchId,
    heroId: heroId,
    startedAt: DateTime(2025, 3, 20, 18).subtract(Duration(hours: hoursAgo)),
    duration: const Duration(minutes: 34),
    kills: 5,
    deaths: deaths,
    assists: 8,
    didWin: didWin,
    partySize: 1,
  );
}
