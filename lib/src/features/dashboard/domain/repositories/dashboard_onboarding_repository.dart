abstract class DashboardOnboardingRepository {
  Future<bool> loadDismissed();

  Future<void> saveDismissed(bool dismissed);
}
