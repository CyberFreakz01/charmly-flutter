import 'package:charmly_flutter/core/charmly_models.dart';
import 'package:charmly_flutter/features/foundation/app_state.dart';
import 'package:charmly_flutter/features/foundation/app_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryStorage implements AppStorage {
  bool onboardingComplete = false;
  Map<String, String> quizAnswers = {};
  String? persona;
  String? module;

  @override
  Future<bool> getOnboardingComplete() async => onboardingComplete;

  @override
  Future<Map<String, String>> getQuizAnswers() async => quizAnswers;

  @override
  Future<String?> getSelectedModule() async => module;

  @override
  Future<String?> getSelectedPersona() async => persona;

  @override
  Future<void> setOnboardingComplete(bool complete) async {
    onboardingComplete = complete;
  }

  @override
  Future<void> setQuizAnswers(Map<String, String> answers) async {
    quizAnswers = answers;
  }

  @override
  Future<void> setSelectedModule(String moduleId) async {
    module = moduleId;
  }

  @override
  Future<void> setSelectedPersona(String personaId) async {
    persona = personaId;
  }
}

void main() {
  test('onboarding requires age and terms before continue', () async {
    final storage = _InMemoryStorage();
    final state = Phase1AppState(storage: storage);

    await state.initialize();
    expect(state.screen, Phase1Screen.onboarding);

    await state.completeOnboarding();
    expect(state.screen, Phase1Screen.onboarding);

    state
      ..setAgeConfirmed(true)
      ..setTermsConfirmed(true);

    await state.completeOnboarding();
    expect(state.screen, Phase1Screen.quiz);
    expect(storage.onboardingComplete, isTrue);
  });

  test('quiz flow requires answers and then opens personas', () async {
    final state = Phase1AppState(storage: _InMemoryStorage());
    await state.initialize();
    state
      ..setAgeConfirmed(true)
      ..setTermsConfirmed(true);
    await state.completeOnboarding();

    expect(state.hasQuizSelection, isFalse);
    await state.nextQuizStep();
    expect(state.quizIndex, 0);

    state.setQuizAnswer('starting');
    await state.nextQuizStep();
    state.setQuizAnswer('nervous');
    await state.nextQuizStep();
    state.setQuizAnswer('opening');
    await state.nextQuizStep();

    expect(state.screen, Phase1Screen.personas);
  });

  test('premium persona/module remain unavailable', () async {
    final storage = _InMemoryStorage();
    final state = Phase1AppState(storage: storage);
    await state.initialize();

    await state.selectPersona(personas.firstWhere((p) => p.id == 'sofia'));
    expect(state.selectedPersonaId, 'maya');

    await state.selectModule(modules.firstWhere((m) => m.id == 'flow'));
    expect(state.selectedModuleId, 'opener');
  });
}
