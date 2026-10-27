import 'package:flutter/foundation.dart';

import '../../core/charmly_models.dart';
import 'app_storage.dart';

enum Phase1Screen { loading, onboarding, quiz, personas, curriculum }

class Phase1AppState extends ChangeNotifier {
  Phase1AppState({required AppStorage storage}) : _storage = storage;

  final AppStorage _storage;

  Phase1Screen screen = Phase1Screen.loading;
  bool ageConfirmed = false;
  bool termsConfirmed = false;
  final Map<String, String> quizAnswers = {};
  String selectedPersonaId = personas.first.id;
  String selectedModuleId = modules.first.id;
  bool isPremium = false;

  int _quizIndex = 0;
  int get quizIndex => _quizIndex;
  QuizQuestion get currentQuestion => quizQuestions[_quizIndex];

  Future<void> initialize() async {
    final onboardingComplete = await _storage.getOnboardingComplete();
    final savedQuiz = await _storage.getQuizAnswers();
    final savedPersona = await _storage.getSelectedPersona();
    final savedModule = await _storage.getSelectedModule();

    quizAnswers
      ..clear()
      ..addAll(savedQuiz);

    if (savedPersona != null && personas.any((p) => p.id == savedPersona)) {
      selectedPersonaId = savedPersona;
    }

    if (savedModule != null && modules.any((m) => m.id == savedModule)) {
      selectedModuleId = savedModule;
    }

    if (onboardingComplete) {
      ageConfirmed = true;
      termsConfirmed = true;
      screen = quizAnswers.length == quizQuestions.length
          ? Phase1Screen.curriculum
          : Phase1Screen.quiz;
      _quizIndex = _nextQuestionIndex();
    } else {
      screen = Phase1Screen.onboarding;
    }

    notifyListeners();
  }

  bool get canContinueOnboarding => ageConfirmed && termsConfirmed;

  void setAgeConfirmed(bool value) {
    ageConfirmed = value;
    notifyListeners();
  }

  void setTermsConfirmed(bool value) {
    termsConfirmed = value;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    if (!canContinueOnboarding) return;
    await _storage.setOnboardingComplete(true);
    screen = Phase1Screen.quiz;
    notifyListeners();
  }

  bool get hasQuizSelection =>
      quizAnswers[currentQuestion.id] != null &&
      quizAnswers[currentQuestion.id]!.isNotEmpty;

  void setQuizAnswer(String value) {
    quizAnswers[currentQuestion.id] = value;
    notifyListeners();
  }

  Future<void> nextQuizStep() async {
    if (!hasQuizSelection) return;

    if (_quizIndex < quizQuestions.length - 1) {
      _quizIndex += 1;
      notifyListeners();
      return;
    }

    await _storage.setQuizAnswers(quizAnswers);
    screen = Phase1Screen.personas;
    notifyListeners();
  }

  Future<void> selectPersona(Persona persona) async {
    if (!isPremium && persona.tier != Tier.easy) return;
    selectedPersonaId = persona.id;
    await _storage.setSelectedPersona(persona.id);
    notifyListeners();
  }

  Future<void> continueToCurriculum() async {
    screen = Phase1Screen.curriculum;
    notifyListeners();
  }

  Future<void> selectModule(CurriculumModule module) async {
    if (module.premium && !isPremium) return;
    selectedModuleId = module.id;
    await _storage.setSelectedModule(module.id);
    notifyListeners();
  }

  int _nextQuestionIndex() {
    for (var i = 0; i < quizQuestions.length; i += 1) {
      if ((quizAnswers[quizQuestions[i].id] ?? '').isEmpty) return i;
    }
    return quizQuestions.length - 1;
  }
}
