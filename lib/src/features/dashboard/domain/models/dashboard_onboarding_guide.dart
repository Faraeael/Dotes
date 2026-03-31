class DashboardOnboardingGuide {
  const DashboardOnboardingGuide({
    required this.title,
    required this.subtitle,
    required this.steps,
    required this.cardHints,
  });

  final String title;
  final String subtitle;
  final List<DashboardOnboardingStep> steps;
  final List<DashboardOnboardingCardHint> cardHints;
}

class DashboardOnboardingStep {
  const DashboardOnboardingStep({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class DashboardOnboardingCardHint {
  const DashboardOnboardingCardHint({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
