import 'package:flutter/material.dart';

import '../core/charmly_models.dart';
import '../features/foundation/app_state.dart';
import '../features/foundation/app_storage.dart';
import '../features/foundation/widgets.dart';
import 'charmly_theme.dart';

class CharmlyApp extends StatefulWidget {
  const CharmlyApp({super.key});

  @override
  State<CharmlyApp> createState() => _CharmlyAppState();
}

class _CharmlyAppState extends State<CharmlyApp> {
  late final Phase1AppState state;

  @override
  void initState() {
    super.initState();
    state = Phase1AppState(storage: SharedPrefsStorage())..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'Charmly',
          debugShowCheckedModeBanner: false,
          theme: buildCharmlyTheme(),
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: switch (state.screen) {
                  Phase1Screen.loading => const _LoadingScreen(),
                  Phase1Screen.onboarding => _OnboardingScreen(state: state),
                  Phase1Screen.quiz => _QuizScreen(state: state),
                  Phase1Screen.personas => _PersonasScreen(state: state),
                  Phase1Screen.curriculum => _CurriculumScreen(state: state),
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: CharmlyTokens.primary),
    );
  }
}

class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen({required this.state});

  final Phase1AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CharmlyHeader(
          title: 'Charmly',
          subtitle: 'Adults-only conversation practice, rebuilt in Flutter.',
        ),
        const SizedBox(height: 24),
        Text(
          'Before continuing, confirm both requirements.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        CheckRow(
          label: 'I am at least 18 years old',
          value: state.ageConfirmed,
          onChanged: state.setAgeConfirmed,
        ),
        const SizedBox(height: 10),
        CheckRow(
          label: 'I agree to the terms and community rules',
          value: state.termsConfirmed,
          onChanged: state.setTermsConfirmed,
        ),
        const Spacer(),
        PrimaryButton(
          label: 'Continue',
          onPressed:
              state.canContinueOnboarding ? () => state.completeOnboarding() : null,
        ),
      ],
    );
  }
}

class _QuizScreen extends StatelessWidget {
  const _QuizScreen({required this.state});

  final Phase1AppState state;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    final selected = state.quizAnswers[question.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CharmlyHeader(
          title: 'Personalization quiz',
          subtitle: 'Step ${state.quizIndex + 1} of ${quizQuestions.length}',
        ),
        const SizedBox(height: 16),
        ProgressSegments(current: state.quizIndex, total: quizQuestions.length),
        const SizedBox(height: 18),
        Text(question.question, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...question.options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => state.setQuizAnswer(option.$1),
              borderRadius: BorderRadius.circular(CharmlyTokens.radius),
              child: Container(
                decoration: BoxDecoration(
                  color: selected == option.$1
                      ? CharmlyTokens.primary
                      : CharmlyTokens.card,
                  borderRadius: BorderRadius.circular(CharmlyTokens.radius),
                  border: Border.all(
                    color: selected == option.$1
                        ? CharmlyTokens.primary
                        : CharmlyTokens.border,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.$2,
                        style: TextStyle(
                          color: selected == option.$1
                              ? CharmlyTokens.background
                              : CharmlyTokens.foreground,
                        ),
                      ),
                    ),
                    Icon(
                      selected == option.$1
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: selected == option.$1
                          ? CharmlyTokens.background
                          : CharmlyTokens.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        PrimaryButton(
          label: state.quizIndex == quizQuestions.length - 1
              ? 'Continue to personas'
              : 'Next',
          onPressed: state.hasQuizSelection ? () => state.nextQuizStep() : null,
        ),
      ],
    );
  }
}

class _PersonasScreen extends StatelessWidget {
  const _PersonasScreen({required this.state});

  final Phase1AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CharmlyHeader(
          title: 'Choose your persona',
          subtitle: 'Easy is available in Phase 1. Premium tiers remain locked.',
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            children: personas
                .map(
                  (persona) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PersonaCard(
                      persona: persona,
                      selected: state.selectedPersonaId == persona.id,
                      locked: !state.isPremium && persona.tier != Tier.easy,
                      onTap: () => state.selectPersona(persona),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Continue to curriculum',
          onPressed: () => state.continueToCurriculum(),
        ),
      ],
    );
  }
}

class _CurriculumScreen extends StatelessWidget {
  const _CurriculumScreen({required this.state});

  final Phase1AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CharmlyHeader(
          title: 'Curriculum',
          subtitle: 'Five modules mapped from the source app. Premium remains locked.',
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            children: modules
                .map(
                  (module) => CurriculumModuleRow(
                    module: module,
                    selected: state.selectedModuleId == module.id,
                    locked: module.premium && !state.isPremium,
                    onTap: () => state.selectModule(module),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        SecondaryButton(
          label: 'Phase 1 complete: premium/AI/chat in later phases',
          onPressed: null,
        ),
      ],
    );
  }
}
