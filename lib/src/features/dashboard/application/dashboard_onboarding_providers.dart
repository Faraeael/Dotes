import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../player_import/application/imported_player_provider.dart';
import '../data/local/dashboard_onboarding_local_store.dart';
import '../data/local/shared_preferences_dashboard_onboarding_local_store.dart';
import '../data/repositories/local_dashboard_onboarding_repository.dart';
import '../domain/models/dashboard_onboarding_guide.dart';
import '../domain/repositories/dashboard_onboarding_repository.dart';
import '../domain/services/dashboard_onboarding_guide_service.dart';

final dashboardOnboardingLocalStoreProvider =
    Provider<DashboardOnboardingLocalStore>((ref) {
      return SharedPreferencesDashboardOnboardingLocalStore(
        SharedPreferencesAsync(),
      );
    });

final dashboardOnboardingRepositoryProvider =
    Provider<DashboardOnboardingRepository>((ref) {
      final store = ref.watch(dashboardOnboardingLocalStoreProvider);
      return LocalDashboardOnboardingRepository(store);
    });

final dashboardOnboardingGuideServiceProvider =
    Provider<DashboardOnboardingGuideService>((ref) {
      return const DashboardOnboardingGuideService();
    });

final dashboardOnboardingGuideProvider = Provider<DashboardOnboardingGuide>((
  ref,
) {
  return ref.watch(dashboardOnboardingGuideServiceProvider).build();
});

final dashboardOnboardingControllerProvider = StateNotifierProvider<
  DashboardOnboardingController,
  DashboardOnboardingState
>((ref) {
  final repository = ref.watch(dashboardOnboardingRepositoryProvider);
  return DashboardOnboardingController(repository);
});

final dashboardOnboardingVisibleProvider = Provider<bool>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  final onboardingState = ref.watch(dashboardOnboardingControllerProvider);
  return importedPlayer != null && onboardingState.isVisible;
});

class DashboardOnboardingController
    extends StateNotifier<DashboardOnboardingState> {
  DashboardOnboardingController(this._repository)
    : super(const DashboardOnboardingState()) {
    unawaited(_loadDismissedState());
  }

  final DashboardOnboardingRepository _repository;
  bool _disposed = false;

  Future<void> dismiss() async {
    await _repository.saveDismissed(true);
    if (_disposed) {
      return;
    }

    state = state.copyWith(
      hasLoaded: true,
      dismissed: true,
      forceVisible: false,
    );
  }

  void showGuide() {
    state = state.copyWith(hasLoaded: true, forceVisible: true);
  }

  Future<void> _loadDismissedState() async {
    final dismissed = await _repository.loadDismissed();
    if (_disposed) {
      return;
    }

    state = state.copyWith(hasLoaded: true, dismissed: dismissed);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class DashboardOnboardingState {
  const DashboardOnboardingState({
    this.hasLoaded = false,
    this.dismissed = false,
    this.forceVisible = false,
  });

  final bool hasLoaded;
  final bool dismissed;
  final bool forceVisible;

  bool get isVisible => hasLoaded && (!dismissed || forceVisible);

  DashboardOnboardingState copyWith({
    bool? hasLoaded,
    bool? dismissed,
    bool? forceVisible,
  }) {
    return DashboardOnboardingState(
      hasLoaded: hasLoaded ?? this.hasLoaded,
      dismissed: dismissed ?? this.dismissed,
      forceVisible: forceVisible ?? this.forceVisible,
    );
  }
}
