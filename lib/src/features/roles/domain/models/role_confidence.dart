enum RoleConfidence {
  low,
  medium,
  high;

  String get label => switch (this) {
    RoleConfidence.low => 'Low',
    RoleConfidence.medium => 'Medium',
    RoleConfidence.high => 'High',
  };
}
