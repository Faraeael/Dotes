abstract class TesterFeedbackLocalStore {
  Future<String?> getString(String key);

  Future<Set<String>> getKeys();

  Future<void> setString(String key, String value);
}
