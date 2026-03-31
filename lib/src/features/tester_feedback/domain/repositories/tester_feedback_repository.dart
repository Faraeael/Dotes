import '../models/tester_feedback.dart';
import '../models/tester_feedback_record.dart';

abstract class TesterFeedbackRepository {
  Future<TesterFeedback?> loadForAccount(int accountId);

  Future<List<TesterFeedbackRecord>> loadAll();

  Future<void> saveForAccount(int accountId, TesterFeedback feedback);
}
