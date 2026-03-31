import 'package:dotes/src/features/dashboard/application/dashboard_onboarding_providers.dart';
import 'package:dotes/src/features/dashboard/domain/repositories/dashboard_onboarding_repository.dart';
import 'package:dotes/src/features/player_import/application/imported_player_provider.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dashboard onboarding', () {
    test('first-run explainer shown', () async {
      final repository = FakeDashboardOnboardingRepository();
      final container = ProviderContainer(
        overrides: [
          dashboardOnboardingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(dashboardOnboardingControllerProvider.notifier);
      container.read(importedPlayerProvider.notifier).state = _importedPlayer();

      await _settleOnboarding();

      expect(container.read(dashboardOnboardingVisibleProvider), isTrue);
    });

    test('dismissed state saved locally', () async {
      final repository = FakeDashboardOnboardingRepository();
      final container = ProviderContainer(
        overrides: [
          dashboardOnboardingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(dashboardOnboardingControllerProvider.notifier);
      container.read(importedPlayerProvider.notifier).state = _importedPlayer();

      await _settleOnboarding();
      await container.read(dashboardOnboardingControllerProvider.notifier).dismiss();

      expect(repository.dismissed, isTrue);
      expect(container.read(dashboardOnboardingVisibleProvider), isFalse);
    });

    test('explainer not shown again after dismissal', () async {
      final repository = FakeDashboardOnboardingRepository();
      final firstContainer = ProviderContainer(
        overrides: [
          dashboardOnboardingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(firstContainer.dispose);

      firstContainer.read(dashboardOnboardingControllerProvider.notifier);
      firstContainer.read(importedPlayerProvider.notifier).state = _importedPlayer();

      await _settleOnboarding();
      await firstContainer
          .read(dashboardOnboardingControllerProvider.notifier)
          .dismiss();

      final secondContainer = ProviderContainer(
        overrides: [
          dashboardOnboardingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(secondContainer.dispose);

      secondContainer.read(dashboardOnboardingControllerProvider.notifier);
      secondContainer.read(importedPlayerProvider.notifier).state =
          _importedPlayer();

      await _settleOnboarding();

      expect(secondContainer.read(dashboardOnboardingVisibleProvider), isFalse);
    });

    test('manual reopen works', () async {
      final repository = FakeDashboardOnboardingRepository(initialDismissed: true);
      final container = ProviderContainer(
        overrides: [
          dashboardOnboardingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(dashboardOnboardingControllerProvider.notifier);
      container.read(importedPlayerProvider.notifier).state = _importedPlayer();

      await _settleOnboarding();
      expect(container.read(dashboardOnboardingVisibleProvider), isFalse);

      container.read(dashboardOnboardingControllerProvider.notifier).showGuide();

      expect(container.read(dashboardOnboardingVisibleProvider), isTrue);
    });
  });
}

Future<void> _settleOnboarding() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

ImportedPlayerData _importedPlayer() {
  return ImportedPlayerData(
    profile: const PlayerProfileSummary(
      accountId: 86745912,
      personaName: 'Player',
      avatarUrl: '',
      leaderboardRank: null,
    ),
    recentMatches: [
      RecentMatch(
        matchId: 9001,
        heroId: 28,
        startedAt: DateTime.utc(2025, 3, 20),
        duration: Duration(minutes: 30),
        kills: 8,
        deaths: 4,
        assists: 10,
        didWin: true,
        partySize: 1,
      ),
    ],
  );
}

class FakeDashboardOnboardingRepository
    implements DashboardOnboardingRepository {
  FakeDashboardOnboardingRepository({this.initialDismissed = false})
    : dismissed = initialDismissed;

  final bool initialDismissed;
  bool dismissed;

  @override
  Future<bool> loadDismissed() async {
    return dismissed;
  }

  @override
  Future<void> saveDismissed(bool dismissed) async {
    this.dismissed = dismissed;
  }
}
