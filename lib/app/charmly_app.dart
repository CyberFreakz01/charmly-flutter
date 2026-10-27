import 'package:flutter/material.dart';

import '../core/theme/charmly_theme.dart';
import '../features/foundation/app_controller.dart';
import '../features/foundation/app_state.dart';
import '../features/screens/screens.dart';

class CharmlyApp extends StatefulWidget {
  const CharmlyApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<CharmlyApp> createState() => _CharmlyAppState();
}

class _CharmlyAppState extends State<CharmlyApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onState);
    super.dispose();
  }

  void _onState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    return MaterialApp(
      title: 'Charmly',
      debugShowCheckedModeBanner: false,
      theme: buildCharmlyTheme(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _buildScreen(state),
      ),
    );
  }

  Widget _buildScreen(AppState state) {
    switch (state.screen) {
      case AppScreen.loading:
        return const LoadingScreen(key: ValueKey<String>('loading'));
      case AppScreen.onboarding:
        return OnboardingScreen(
          key: const ValueKey<String>('onboarding'),
          onContinue: widget.controller.completeOnboarding,
        );
      case AppScreen.quiz:
        return QuizScreen(
          key: const ValueKey<String>('quiz'),
          onComplete: widget.controller.completeQuiz,
        );
      case AppScreen.personas:
        return PersonasScreen(
          key: const ValueKey<String>('personas'),
          selectedId: state.personaId,
          isPremium: state.isPremium,
          onSelect: widget.controller.selectPersona,
          onBack: () => widget.controller.goTo(AppScreen.quiz),
        );
      case AppScreen.curriculum:
        return CurriculumScreen(
          key: const ValueKey<String>('curriculum'),
          completed: state.completedModules,
          isPremium: state.isPremium,
          selectedModule: state.moduleId,
          onSelect: widget.controller.selectModule,
          onAssist: widget.controller.openAssist,
          onBack: () => widget.controller.goTo(AppScreen.personas),
        );
      case AppScreen.chat:
        return ChatScreen(
          key: const ValueKey<String>('chat'),
          controller: widget.controller,
          persona: widget.controller.activePersona,
          module: widget.controller.activeModule,
          lastScore: state.lastScore,
          onBack: () => widget.controller.goTo(AppScreen.curriculum),
          onEnd: (messages, voiceUsed) =>
              widget.controller.endSession(messages: messages, voiceUsed: voiceUsed),
        );
      case AppScreen.score:
        if (state.activeScore == null) {
          return Scaffold(
            key: const ValueKey<String>('score-empty'),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('No score yet'),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Retry',
                    onPressed: () => widget.controller.goTo(AppScreen.chat),
                  ),
                ],
              ),
            ),
          );
        }
        return ScoreScreen(
          key: const ValueKey<String>('score'),
          result: state.activeScore!,
          persona: widget.controller.activePersona,
          module: widget.controller.activeModule,
          isPremium: state.isPremium,
          showNudge: state.showNudge,
          onPracticeAgain: widget.controller.practiceAgain,
          onNext: widget.controller.openNextModule,
          onPaywall: widget.controller.openPaywall,
        );
      case AppScreen.assist:
        return AssistScreen(
          key: const ValueKey<String>('assist'),
          controller: widget.controller,
          isPremium: state.isPremium,
          onBack: () => widget.controller.goTo(AppScreen.curriculum),
          onPaywall: widget.controller.openPaywall,
        );
      case AppScreen.paywall:
        return PaywallScreen(
          key: const ValueKey<String>('paywall'),
          state: state,
          onClose: () => widget.controller.goTo(AppScreen.curriculum),
          onRestore: widget.controller.restorePurchases,
          onManage: widget.controller.manageSubscription,
          onPurchase: widget.controller.purchasePremium,
        );
    }
  }
}
