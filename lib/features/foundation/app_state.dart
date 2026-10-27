import '../../core/models/module.dart';
import '../../core/models/persona.dart';
import '../../core/models/score_result.dart';

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
