import 'package:dotes/src/features/dashboard/data/local/saved_block_summary_local_store.dart';
import 'package:dotes/src/features/dashboard/data/repositories/local_saved_block_summary_repository.dart';
import 'package:dotes/src/features/dashboard/domain/models/saved_block_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalSavedBlockSummaryRepository', () {
    test('saves and reloads summaries newest first', () async {
      final repository = LocalSavedBlockSummaryRepository(_FakeStore());

      await repository.saveForAccount(
        86745912,
        _summary(savedAt: DateTime.utc(2026, 4, 1)),
      );
      await repository.saveForAccount(
        86745912,
        _summary(
          completionDateLabel: 'Apr 6, 2026',
          shareText: 'summary-2',
          savedAt: DateTime.utc(2026, 4, 6),
        ),
      );

      final loaded = await repository.loadForAccount(86745912);

      expect(loaded, hasLength(2));
      expect(loaded.first.shareText, 'summary-2');
      expect(loaded.last.shareText, 'summary-1');
    });

    test(
      'does not duplicate the same summary export for one account',
      () async {
        final repository = LocalSavedBlockSummaryRepository(_FakeStore());

        await repository.saveForAccount(86745912, _summary());
        await repository.saveForAccount(
          86745912,
          _summary(savedAt: DateTime.utc(2026, 4, 7)),
        );

        final loaded = await repository.loadForAccount(86745912);

        expect(loaded, hasLength(1));
        expect(loaded.single.shareText, 'summary-1');
      },
    );

    test('keeps summaries isolated per account', () async {
      final repository = LocalSavedBlockSummaryRepository(_FakeStore());

      await repository.saveForAccount(
        86745912,
        _summary(shareText: 'summary-a'),
      );
      await repository.saveForAccount(
        99887766,
        _summary(shareText: 'summary-b'),
      );

      final firstAccount = await repository.loadForAccount(86745912);
      final secondAccount = await repository.loadForAccount(99887766);

      expect(firstAccount.single.shareText, 'summary-a');
      expect(secondAccount.single.shareText, 'summary-b');
    });

    test('reloads saved practice notes when present', () async {
      final repository = LocalSavedBlockSummaryRepository(_FakeStore());

      await repository.saveForAccount(
        86745912,
        _summary(practiceNote: 'Safer lane exits and disciplined fights.'),
      );

      final loaded = await repository.loadForAccount(86745912);

      expect(
        loaded.single.practiceNote,
        'Safer lane exits and disciplined fights.',
      );
    });
  });
}

SavedBlockSummary _summary({
  String completionDateLabel = 'Apr 1, 2026',
  String shareText = 'summary-1',
  DateTime? savedAt,
  String? practiceNote,
}) {
  return SavedBlockSummary(
    playerLabel: 'Tester (Account 86745912)',
    completionDateLabel: completionDateLabel,
    outcome: 'On track',
    mainTargetResult: 'Improved',
    adherenceResult: 'Stayed in block',
    takeaway: 'Deaths improved.',
    nextStep: 'Run the same block again.',
    shareText: shareText,
    savedAt: savedAt ?? DateTime.utc(2026, 4, 5),
    practiceNote: practiceNote,
  );
}

class _FakeStore implements SavedBlockSummaryLocalStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> getString(String key) async {
    return _values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}
