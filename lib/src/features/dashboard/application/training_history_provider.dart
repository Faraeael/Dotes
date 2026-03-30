import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkpoints/application/coaching_checkpoint_providers.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../domain/models/training_history.dart';
import '../domain/services/training_history_service.dart';

final trainingHistoryServiceProvider = Provider<TrainingHistoryService>((ref) {
  return const TrainingHistoryService();
});

final trainingHistoryProvider = Provider<TrainingHistory?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  if (importedPlayer == null) {
    return null;
  }

  final history = ref.watch(coachingCheckpointHistoryProvider);
  final service = ref.watch(trainingHistoryServiceProvider);
  return service.build(history);
});
