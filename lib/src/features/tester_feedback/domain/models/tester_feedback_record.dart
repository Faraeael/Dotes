import 'tester_feedback.dart';

class TesterFeedbackRecord {
  const TesterFeedbackRecord({
    required this.accountId,
    required this.feedback,
  });

  final int accountId;
  final TesterFeedback feedback;
}
