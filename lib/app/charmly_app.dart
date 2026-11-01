import 'package:flutter/material.dart';

import '../features/foundation/app_controller.dart';
import '../features/foundation/app_state.dart';
import '../features/screens/screens.dart';
import '../core/theme/charmly_theme.dart';

class CharmlyApp extends StatelessWidget {
  const CharmlyApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        return MaterialApp(
          title: 'Charmly',
          debugShowCheckedModeBanner: false,
          theme: buildCharmlyTheme(),
          home: _screenFor(state),
        );
      },
    );
  }

  Widget _screenFor(AppState state) {
    switch (state.screen) {
      case AppScreen.loading:
        return const LoadingScreen();
      case AppScreen.onboarding:
        return OnboardingScreen(onContinue: controller.completeOnboarding);
      case AppScreen.quiz:
        return QuizScreen(onComplete: controller.completeQuiz);
      case AppScreen.personas:
        return PersonasScreen(
          selectedId: state.personaId,
          isPremium: state.isPremium,
          onSelect: controller.selectPersona,
          onBack: () => controller.goTo(AppScreen.quiz),
        );
      case AppScreen.curriculum:
        return CurriculumScreen(
          completed: state.completedModules,
          isPremium: state.isPremium,
          selectedModule: state.moduleId,
          onSelect: controller.selectModule,
          onAssist: controller.openAssist,
          onBack: () => controller.goTo(AppScreen.personas),
        );
      case AppScreen.chat:
        return ChatScreen(
          controller: controller,
          persona: controller.activePersona,
          module: controller.activeModule,
          lastScore: state.lastScore,
          onBack: () => controller.goTo(AppScreen.curriculum),
          onEnd: (messages, voiceUsed) =>
              controller.endSession(messages: messages, voiceUsed: voiceUsed),
        );
      case AppScreen.score:
        return ScoreScreen(
          result: state.activeScore!,
          persona: controller.activePersona,
          module: controller.activeModule,
          isPremium: state.isPremium,
          showNudge: state.showNudge,
          onPracticeAgain: controller.practiceAgain,
          onNext: controller.openNextModule,
          onPaywall: controller.openPaywall,
        );
      case AppScreen.assist:
        return AssistScreen(
          controller: controller,
          isPremium: state.isPremium,
          onBack: () => controller.goTo(AppScreen.curriculum),
          onPaywall: controller.openPaywall,
        );
      case AppScreen.paywall:
        return PaywallScreen(
          state: state,
          onClose: () => controller.goTo(AppScreen.curriculum),
          onRestore: controller.restorePurchases,
          onManage: controller.manageSubscription,
          onPurchase: controller.purchasePremium,
        );
    }
  }
}
