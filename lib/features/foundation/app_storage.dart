import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class AppStorage {
  Future<bool> getOnboardingComplete();
  Future<Map<String, String>> getQuizAnswers();
  Future<String?> getSelectedPersona();
  Future<String?> getSelectedModule();
  Future<void> setOnboardingComplete(bool complete);
  Future<void> setQuizAnswers(Map<String, String> answers);
  Future<void> setSelectedPersona(String personaId);
  Future<void> setSelectedModule(String moduleId);
}

class SharedPrefsStorage implements AppStorage {
  static const _onboardingKey = '@charmly/onboarding-complete';
  static const _quizKey = '@charmly/quiz';
  static const _personaKey = '@charmly/persona';
  static const _moduleKey = '@charmly/module';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<bool> getOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<Map<String, String>> getQuizAnswers() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_quizKey);
    if (raw == null || raw.isEmpty) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, value.toString()));
  }

  @override
  Future<String?> getSelectedPersona() async {
    final prefs = await _prefs;
    return prefs.getString(_personaKey);
  }

  @override
  Future<String?> getSelectedModule() async {
    final prefs = await _prefs;
    return prefs.getString(_moduleKey);
  }

  @override
  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingKey, complete);
  }

  @override
  Future<void> setQuizAnswers(Map<String, String> answers) async {
    final prefs = await _prefs;
    await prefs.setString(_quizKey, jsonEncode(answers));
  }

  @override
  Future<void> setSelectedPersona(String personaId) async {
    final prefs = await _prefs;
    await prefs.setString(_personaKey, personaId);
  }

  @override
  Future<void> setSelectedModule(String moduleId) async {
    final prefs = await _prefs;
    await prefs.setString(_moduleKey, moduleId);
  }
}
