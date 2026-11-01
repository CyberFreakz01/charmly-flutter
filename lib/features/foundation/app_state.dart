import 'package:flutter/foundation.dart';

import '../../core/charmly_models.dart' as legacy;
import '../../core/models/module.dart';
import '../../core/models/persona.dart';
import '../../core/models/score_result.dart';
import 'app_storage.dart';

enum AppScreen {
  loading,
  onboarding,
  quiz,
  personas,
  curriculum,
  chat,
  score,
  assist,
  paywall,
}

class AppState {
  const AppState({
    required this.screen,
    required this.quiz,
    required this.personaId,
    required this.moduleId,
    required this.completedModules,
    required this.lastScore,
    required this.activeScore,
    required this.showNudge,
    required this.adaptiveNudgeSeen,
    required this.isPremium,
    required this.paywallConfigured,
    required this.busy,
    required this.lockedReason,
    required this.error,
    required this.cancelled,
  });

  final AppScreen screen;
  final Map<String, String> quiz;
  final String personaId;
  final String moduleId;
  final List<String> completedModules;
  final ScoreResult? lastScore;
  final ScoreResult? activeScore;
  final bool showNudge;
  final bool adaptiveNudgeSeen;
  final bool isPremium;
  final bool paywallConfigured;
  final bool busy;
  final String? lockedReason;
  final String? error;
  final bool cancelled;

  AppState copyWith({
    AppScreen? screen,
    Map<String, String>? quiz,
    String? personaId,
    String? moduleId,
    List<String>? completedModules,
    ScoreResult? lastScore,
    ScoreResult? activeScore,
    bool? showNudge,
    bool? adaptiveNudgeSeen,
    bool? isPremium,
    bool? paywallConfigured,
    bool? busy,
    String? lockedReason,
    String? error,
    bool? cancelled,
  }) {
    return AppState(
      screen: screen ?? this.screen,
      quiz: quiz ?? this.quiz,
      personaId: personaId ?? this.personaId,
      moduleId: moduleId ?? this.moduleId,
      completedModules: completedModules ?? this.completedModules,
      lastScore: lastScore ?? this.lastScore,
      activeScore: activeScore ?? this.activeScore,
      showNudge: showNudge ?? this.showNudge,
      adaptiveNudgeSeen: adaptiveNudgeSeen ?? this.adaptiveNudgeSeen,
      isPremium: isPremium ?? this.isPremium,
      paywallConfigured: paywallConfigured ?? this.paywallConfigured,
      busy: busy ?? this.busy,
      lockedReason: lockedReason,
      error: error,
      cancelled: cancelled ?? this.cancelled,
    );
  }

  static const AppState initial = AppState(
    screen: AppScreen.loading,
    quiz: <String, String>{},
    personaId: 'maya',
    moduleId: 'opener',
    completedModules: <String>[],
    lastScore: null,
    activeScore: null,
    showNudge: false,
    adaptiveNudgeSeen: false,
    isPremium: false,
    paywallConfigured: false,
    busy: false,
    lockedReason: null,
    error: null,
    cancelled: false,
  );
}

Persona personaById(String id, List<Persona> list) {
  return list.firstWhere((item) => item.id == id, orElse: () => list.first);
}

CurriculumModule moduleById(String id, List<CurriculumModule> list) {
  return list.firstWhere((item) => item.id == id, orElse: () => list.first);
}

@Deprecated('Use AppController and AppState for the active application flow.')
class Phase1AppState extends ChangeNotifier {
  Phase1AppState({required AppStorage storage}) : _storage = storage;

  final AppStorage _storage;

  Phase1Screen screen = Phase1Screen.loading;
  bool ageConfirmed = false;
  bool termsConfirmed = false;
  final Map<String, String> quizAnswers = {};
  String selectedPersonaId = legacy.personas.first.id;
  String selectedModuleId = legacy.modules.first.id;
  bool isPremium = false;

  int _quizIndex = 0;
  int get quizIndex => _quizIndex;
  legacy.QuizQuestion get currentQuestion => legacy.quizQuestions[_quizIndex];

  Future<void> initialize() async {
    final onboardingComplete = await _storage.getOnboardingComplete();
    final savedQuiz = await _storage.getQuizAnswers();
    final savedPersona = await _storage.getSelectedPersona();
    final savedModule = await _storage.getSelectedModule();
    quizAnswers
      ..clear()
      ..addAll(savedQuiz);
    if (savedPersona != null &&
        legacy.personas.any((p) => p.id == savedPersona)) {
      selectedPersonaId = savedPersona;
    }
    if (savedModule != null &&
        legacy.modules.any((m) => m.id == savedModule)) {
      selectedModuleId = savedModule;
    }
    if (onboardingComplete) {
      ageConfirmed = true;
      termsConfirmed = true;
      screen = quizAnswers.length == legacy.quizQuestions.length
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
    if (_quizIndex < legacy.quizQuestions.length - 1) {
      _quizIndex += 1;
      notifyListeners();
      return;
    }
    await _storage.setQuizAnswers(quizAnswers);
    screen = Phase1Screen.personas;
    notifyListeners();
  }

  Future<void> selectPersona(legacy.Persona persona) async {
    if (!isPremium && persona.tier != legacy.Tier.easy) return;
    selectedPersonaId = persona.id;
    await _storage.setSelectedPersona(persona.id);
    notifyListeners();
  }

  Future<void> continueToCurriculum() async {
    screen = Phase1Screen.curriculum;
    notifyListeners();
  }

  Future<void> selectModule(legacy.CurriculumModule module) async {
    if (module.premium && !isPremium) return;
    selectedModuleId = module.id;
    await _storage.setSelectedModule(module.id);
    notifyListeners();
  }

  int _nextQuestionIndex() {
    for (var i = 0; i < legacy.quizQuestions.length; i += 1) {
      if ((quizAnswers[legacy.quizQuestions[i].id] ?? '').isEmpty) return i;
    }
    return legacy.quizQuestions.length - 1;
  }
}

enum Phase1Screen { loading, onboarding, quiz, personas, curriculum }
