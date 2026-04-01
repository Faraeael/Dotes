import 'package:dotes/src/features/player_import/data/local/saved_accounts_local_store.dart';
import 'package:dotes/src/features/player_import/data/repositories/local_saved_account_repository.dart';
import 'package:dotes/src/features/player_import/domain/models/saved_account_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalSavedAccountRepository', () {
    test('updates last-opened order deterministically', () async {
      final repository = LocalSavedAccountRepository(FakeSavedAccountsLocalStore());

      await repository.saveEntry(
        SavedAccountEntry(
          accountId: 86745912,
          displayName: 'Player One',
          sourceType: SavedAccountSourceType.real,
          lastOpenedAt: DateTime.utc(2026, 3, 31, 12),
        ),
      );
      await repository.saveEntry(
        SavedAccountEntry(
          accountId: 2222,
          displayName: 'Player Two',
          sourceType: SavedAccountSourceType.real,
          lastOpenedAt: DateTime.utc(2026, 4, 1, 12),
        ),
      );

      final entries = await repository.loadAll();
      expect(entries.map((entry) => entry.accountId), [2222, 86745912]);
    });

    test('removes a saved account cleanly', () async {
      final repository = LocalSavedAccountRepository(FakeSavedAccountsLocalStore());

      await repository.saveEntry(
        SavedAccountEntry(
          accountId: 86745912,
          displayName: 'Player One',
          sourceType: SavedAccountSourceType.real,
          lastOpenedAt: DateTime.utc(2026, 4, 1, 12),
        ),
      );
      await repository.remove(86745912);

      expect(await repository.loadAll(), isEmpty);
    });

    test('pins one account as default at a time', () async {
      final repository = LocalSavedAccountRepository(FakeSavedAccountsLocalStore());

      await repository.saveEntry(
        SavedAccountEntry(
          accountId: 86745912,
          displayName: 'Player One',
          sourceType: SavedAccountSourceType.real,
          lastOpenedAt: DateTime.utc(2026, 4, 1, 12),
        ),
      );
      await repository.saveEntry(
        SavedAccountEntry(
          accountId: 2222,
          displayName: 'Player Two',
          sourceType: SavedAccountSourceType.real,
          lastOpenedAt: DateTime.utc(2026, 4, 1, 11),
        ),
      );

      await repository.setPinnedAccount(2222);
      final entries = await repository.loadAll();

      expect(entries.first.accountId, 2222);
      expect(entries.first.isPinned, isTrue);
      expect(entries.last.isPinned, isFalse);
    });
  });
}

class FakeSavedAccountsLocalStore implements SavedAccountsLocalStore {
  String? value;

  @override
  Future<String?> getString(String key) async {
    return value;
  }

  @override
  Future<void> setString(String key, String value) async {
    this.value = value;
  }
}
