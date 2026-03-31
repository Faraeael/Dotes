abstract class DashboardOnboardingLocalStore {
  Future<bool?> getBool(String key);

  Future<void> setBool(String key, bool value);
}
