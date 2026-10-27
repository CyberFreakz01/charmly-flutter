import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog.dart';
import '../models/score_result.dart';

class PersistedAppData {
  const PersistedAppData({
    required this.onboardingComplete,
    required this.quiz,
    required this.personaId,
    required this.moduleId,
    required this.completedModules,
    required this.lastScore,
    required this.adaptiveNudgeSeen,
  });

  final bool onboardingComplete;
  final Map<String, String> quiz;
  final String personaId;
  final String moduleId;
  final List<String> completedModules;
  final ScoreResult? lastScore;
  final bool adaptiveNudgeSeen;
}

class AppStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppStorage(prefs);
  }

  Future<PersistedAppData> load() async {
    final onboarding = _prefs.getString(storageKeys['onboarding']!) == 'true' &&
        _prefs.getString(storageKeys['ageConfirmed']!) == 'true' &&
        _prefs.getString(storageKeys['termsAgreed']!) == 'true';

    final quizJson = _prefs.getString(storageKeys['quiz']!);
    final quiz = quizJson == null
        ? <String, String>{}
        : (jsonDecode(quizJson) as Map<String, dynamic>)
            .map((key, value) => MapEntry<String, String>(key, value.toString()));
    final completedJson = _prefs.getString(storageKeys['completed']!);
    final completed = completedJson == null
        ? <String>[]
        : (jsonDecode(completedJson) as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final scoreJson = _prefs.getString(storageKeys['score']!);
    final score = scoreJson == null
        ? null
        : ScoreResult.fromJson(jsonDecode(scoreJson) as Map<String, dynamic>);

    return PersistedAppData(
      onboardingComplete: onboarding,
      quiz: quiz,
      personaId: _prefs.getString(storageKeys['persona']!) ?? 'maya',
      moduleId: _prefs.getString(storageKeys['module']!) ?? 'opener',
      completedModules: completed,
      lastScore: score,
      adaptiveNudgeSeen: _prefs.getString(storageKeys['adaptiveNudge']!) == 'true',
    );
  }

  Future<void> markOnboardingComplete() async {
    await Future.wait(<Future<bool>>[
      _prefs.setString(storageKeys['onboarding']!, 'true'),
      _prefs.setString(storageKeys['ageConfirmed']!, 'true'),
      _prefs.setString(storageKeys['termsAgreed']!, 'true'),
    ]);
  }

  Future<void> saveQuiz(Map<String, String> quiz) async {
    await _prefs.setString(storageKeys['quiz']!, jsonEncode(quiz));
  }

  Future<void> savePersona(String id) async {
    await _prefs.setString(storageKeys['persona']!, id);
  }

  Future<void> saveModule(String id) async {
    await _prefs.setString(storageKeys['module']!, id);
  }

  Future<void> saveCompletedModules(List<String> ids) async {
    await _prefs.setString(storageKeys['completed']!, jsonEncode(ids));
  }

  Future<void> saveLastScore(ScoreResult score) async {
    await _prefs.setString(storageKeys['score']!, jsonEncode(score.toJson()));
  }

  Future<void> saveAdaptiveNudgeSeen() async {
    await _prefs.setString(storageKeys['adaptiveNudge']!, 'true');
  }
}
