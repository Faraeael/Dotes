import '../models/saved_block_summary.dart';

abstract class SavedBlockSummaryRepository {
  Future<List<SavedBlockSummary>> loadForAccount(int accountId);

  Future<void> saveForAccount(int accountId, SavedBlockSummary summary);
}
