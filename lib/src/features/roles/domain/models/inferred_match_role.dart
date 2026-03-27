import 'player_role.dart';
import 'role_confidence.dart';

class InferredMatchRole {
  const InferredMatchRole({
    required this.role,
    required this.confidence,
  });

  final PlayerRole role;
  final RoleConfidence confidence;
}
