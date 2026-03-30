import 'package:dotes/src/features/dashboard/domain/models/comfort_core_summary.dart';
import 'package:dotes/src/features/dashboard/domain/services/comfort_core_service.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = ComfortCoreService();

  group('ComfortCoreService', () {
    test('detects a strong comfort core when wins cluster on the top 2 heroes', () {
      final summary = service.build([
        _match(matchId: 1, hoursAgo: 1, heroId: 1, didWin: true),
        _match(matchId: 2, hoursAgo: 2, heroId: 1, didWin: true),
        _match(matchId: 3, hoursAgo: 3, heroId: 1, didWin: false),
        _match(matchId: 4, hoursAgo: 4, heroId: 2, didWin: true),
        _match(matchId: 5, hoursAgo: 5, heroId: 2, didWin: true),
        _match(matchId: 6, hoursAgo: 6, heroId: 3, didWin: false),
        _match(matchId: 7, hoursAgo: 7, heroId: 4, didWin: false),
      ]);

      expect(summary.isReady, isTrue);
      expect(summary.topHeroes.map((hero) => hero.heroId).toList(), [1, 2]);
      expect(summary.topHeroWins, 4);
      expect(summary.topHeroLosses, 1);
      expect(summary.otherHeroWins, 0);
      expect(summary.otherHeroLosses, 2);
      expect(
        summary.conclusionType,
        ComfortCoreConclusionType.successInsideCore,
      );
      expect(
        summary.conclusion,
        'Most of your recent success is inside a small comfort core.',
      );
    });

    test('returns no clear core when the sample stays spread out', () {
      final summary = service.build([
        _match(matchId: 1, hoursAgo: 1, heroId: 1, didWin: true),
        _match(matchId: 2, hoursAgo: 2, heroId: 2, didWin: false),
        _match(matchId: 3, hoursAgo: 3, heroId: 3, didWin: true),
        _match(matchId: 4, hoursAgo: 4, heroId: 4, didWin: false),
        _match(matchId: 5, hoursAgo: 5, heroId: 5, didWin: true),
        _match(matchId: 6, hoursAgo: 6, heroId: 1, didWin: false),
      ]);

      expect(summary.isReady, isTrue);
      expect(summary.topHeroes.map((hero) => hero.heroId).toList(), [1, 2]);
      expect(summary.topHeroWins, 1);
      expect(summary.topHeroLosses, 2);
      expect(summary.otherHeroWins, 2);
      expect(summary.otherHeroLosses, 1);
      expect(summary.conclusionType, ComfortCoreConclusionType.noClearCore);
      expect(
        summary.conclusion,
        'Your sample is too spread out to identify a clear comfort core.',
      );
    });

    test('returns a fallback for a tiny sample', () {
      final summary = service.build([
        _match(matchId: 1, hoursAgo: 1, heroId: 1, didWin: true),
        _match(matchId: 2, hoursAgo: 2, heroId: 2, didWin: false),
        _match(matchId: 3, hoursAgo: 3, heroId: 1, didWin: true),
        _match(matchId: 4, hoursAgo: 4, heroId: 3, didWin: false),
      ]);

      expect(summary.isReady, isFalse);
      expect(summary.topHeroes, isEmpty);
      expect(summary.topHeroWins, 0);
      expect(summary.otherHeroLosses, 0);
      expect(summary.conclusionType, ComfortCoreConclusionType.tinySample);
      expect(
        summary.conclusion,
        'Need at least 5 recent matches before this comfort core read becomes useful.',
      );
    });

    test('keeps top hero ordering deterministic when usage ties', () {
      final sample = [
        _match(matchId: 1, hoursAgo: 1, heroId: 2, didWin: true),
        _match(matchId: 2, hoursAgo: 2, heroId: 1, didWin: true),
        _match(matchId: 3, hoursAgo: 3, heroId: 2, didWin: false),
        _match(matchId: 4, hoursAgo: 4, heroId: 1, didWin: false),
        _match(matchId: 5, hoursAgo: 5, heroId: 3, didWin: false),
      ];

      final firstPass = service.build(sample);
      final secondPass = service.build(sample);

      expect(firstPass.topHeroes.map((hero) => hero.heroId).toList(), [1, 2]);
      expect(
        firstPass.topHeroes.map((hero) => hero.heroId).toList(),
        secondPass.topHeroes.map((hero) => hero.heroId).toList(),
      );
      expect(firstPass.conclusion, secondPass.conclusion);
    });
  });
}

RecentMatch _match({
  required int matchId,
  required int hoursAgo,
  required int heroId,
  bool didWin = false,
}) {
  return RecentMatch(
    matchId: matchId,
    heroId: heroId,
    startedAt: DateTime(2025, 3, 20, 18).subtract(Duration(hours: hoursAgo)),
    duration: const Duration(minutes: 34),
    kills: 5,
    deaths: 4,
    assists: 8,
    didWin: didWin,
    partySize: 1,
  );
}
