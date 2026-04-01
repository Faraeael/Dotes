import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../training_preferences/domain/models/training_preferences.dart';
import '../../../tester_feedback/domain/models/tester_feedback.dart';
import 'imported_player_data.dart';

class DemoPlayerScenario {
  const DemoPlayerScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.importedPlayer,
    this.checkpointHistory = const [],
    this.trainingPreferences = const TrainingPreferences(),
    this.testerFeedback,
  });

  final String id;
  final String title;
  final String description;
  final ImportedPlayerData importedPlayer;
  final List<CoachingCheckpoint> checkpointHistory;
  final TrainingPreferences trainingPreferences;
  final TesterFeedback? testerFeedback;
}
