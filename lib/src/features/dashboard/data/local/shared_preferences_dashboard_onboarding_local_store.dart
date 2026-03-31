import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_onboarding_local_store.dart';

class SharedPreferencesDashboardOnboardingLocalStore
    implements DashboardOnboardingLocalStore {
  SharedPreferencesDashboardOnboardingLocalStore(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<bool?> getBool(String key) {
    return _preferences.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }
}
