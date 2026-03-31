import '../../domain/repositories/dashboard_onboarding_repository.dart';
import '../local/dashboard_onboarding_local_store.dart';

class LocalDashboardOnboardingRepository
    implements DashboardOnboardingRepository {
  LocalDashboardOnboardingRepository(this._store);

  final DashboardOnboardingLocalStore _store;

  @override
  Future<bool> loadDismissed() async {
    return await _store.getBool(_storageKey) ?? false;
  }

  @override
  Future<void> saveDismissed(bool dismissed) async {
    await _store.setBool(_storageKey, dismissed);
  }
}

const _storageKey = 'dashboard_onboarding.dismissed';
