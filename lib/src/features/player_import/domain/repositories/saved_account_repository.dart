import '../models/saved_account_entry.dart';

abstract class SavedAccountRepository {
  Future<List<SavedAccountEntry>> loadAll();

  Future<void> saveEntry(SavedAccountEntry entry);

  Future<void> remove(int accountId);

  Future<void> setPinnedAccount(int? accountId);
}
