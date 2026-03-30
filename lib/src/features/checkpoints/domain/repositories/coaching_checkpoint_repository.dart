import '../models/coaching_checkpoint.dart';

abstract class CoachingCheckpointRepository {
  Future<CoachingCheckpoint?> loadForAccount(int accountId);

  Future<List<CoachingCheckpoint>> loadHistoryForAccount(int accountId);

  Future<CoachingCheckpoint> saveDraft(CoachingCheckpointDraft draft);
}
