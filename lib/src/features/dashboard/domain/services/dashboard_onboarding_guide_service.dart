import '../models/dashboard_onboarding_guide.dart';

class DashboardOnboardingGuideService {
  const DashboardOnboardingGuideService();

  DashboardOnboardingGuide build() {
    return const DashboardOnboardingGuide(
      title: 'How coaching works',
      subtitle:
          'Import a sample, play one focused 5-game block, then re-import to review it.',
      steps: [
        DashboardOnboardingStep(
          title: 'Step 1: Import recent matches',
          description:
              'Load the latest sample so the app can read your role, hero pool, and trends.',
        ),
        DashboardOnboardingStep(
          title: 'Step 2: Follow the 5-game session plan',
          description:
              'Stick to the queue, hero block, and target so the block stays easy to judge.',
        ),
        DashboardOnboardingStep(
          title: 'Step 3: Re-import later to review the block',
          description:
              'Import newer matches so Block review and History can score the cycle.',
        ),
      ],
      cardHints: [
        DashboardOnboardingCardHint(
          title: 'Verdict',
          description: 'Quick read on the biggest leak or edge right now.',
        ),
        DashboardOnboardingCardHint(
          title: 'Block review',
          description:
              'Checks whether the last 5-game block stayed on plan and moved the target.',
        ),
        DashboardOnboardingCardHint(
          title: 'Session plan',
          description: 'Your next 5-game block: queue, hero block, and focus.',
        ),
        DashboardOnboardingCardHint(
          title: 'Training setup',
          description:
              'Choose app read or lock a manual role and hero block.',
        ),
      ],
    );
  }
}
