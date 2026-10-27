import 'package:flutter/foundation.dart';

import '../../core/data/catalog.dart';
import '../../core/models/assist_result.dart';
import '../../core/models/message.dart';
import '../../core/models/module.dart';
import '../../core/models/persona.dart';
import '../../core/models/score_result.dart';
import '../../core/persistence/app_storage.dart';
import '../../core/services/ai_backend_client.dart';
import '../../core/services/paywall_service.dart';
import '../../core/services/voice_service.dart';
import 'app_state.dart';

class AppController extends ChangeNotifier {
  AppController({
    required AppStorage storage,
    required AiCoachService ai,
    required PaywallService paywall,
    required VoiceInputService voiceInput,
    required VoiceOutputService voiceOutput,
  })  : _storage = storage,
        _ai = ai,
        _paywall = paywall,
        _voiceInput = voiceInput,
        _voiceOutput = voiceOutput;

  final AppStorage _storage;
  final AiCoachService _ai;
  final PaywallService _paywall;
  final VoiceInputService _voiceInput;
  final VoiceOutputService _voiceOutput;

  AppState _state = AppState.initial;

  AppState get state => _state;
  List<Persona> get personasList => personas;
  List<CurriculumModule> get modulesList => modules;

  Persona get activePersona => personaById(_state.personaId, personas);
  CurriculumModule get activeModule => moduleById(_state.moduleId, modules);

  Future<void> initialize() async {
    _setState(_state.copyWith(screen: AppScreen.loading, busy: true));
    try {
      final data = await _storage.load();
      final paywallStatus = await _paywall.initialize();
      final screen = !data.onboardingComplete
          ? AppScreen.onboarding
          : data.quiz.isEmpty
              ? AppScreen.quiz
              : AppScreen.curriculum;
      _setState(
        _state.copyWith(
          screen: screen,
          busy: false,
          quiz: data.quiz,
          personaId: data.personaId,
          moduleId: data.moduleId,
          completedModules: data.completedModules,
          lastScore: data.lastScore,
          adaptiveNudgeSeen: data.adaptiveNudgeSeen,
          isPremium: paywallStatus.isPremium,
          paywallConfigured: paywallStatus.isConfigured,
          error: null,
          lockedReason: null,
          cancelled: false,
        ),
      );
    } catch (e) {
      _setState(
        _state.copyWith(
          screen: AppScreen.onboarding,
          busy: false,
          error: 'Could not load saved state. You can retry.',
        ),
      );
    }
  }

  Future<void> retryInitialize() async {
    await initialize();
  }

  void completeOnboarding() {
    _storage.markOnboardingComplete();
    _setState(_state.copyWith(screen: AppScreen.quiz, error: null));
  }

  Future<void> completeQuiz(Map<String, String> answers) async {
    final recommended = answers['struggle'] == 'flow'
        ? 'flow'
        : answers['struggle'] == 'signals'
            ? 'signals'
            : 'opener';
    await _storage.saveQuiz(answers);
    await _storage.saveModule(recommended);
    _setState(
      _state.copyWith(
        quiz: Map<String, String>.from(answers),
        moduleId: recommended,
        screen: AppScreen.personas,
        error: null,
      ),
    );
  }

  Future<void> selectPersona(Persona persona) async {
    if (!_state.isPremium && !persona.isEasy) {
      _setState(
        _state.copyWith(
          lockedReason:
              'This persona is premium. Unlock Premium to practice medium and hard tiers.',
          screen: AppScreen.paywall,
          cancelled: false,
        ),
      );
      return;
    }
    await _storage.savePersona(persona.id);
    _setState(
      _state.copyWith(
        personaId: persona.id,
        screen: AppScreen.curriculum,
        lockedReason: null,
        error: null,
      ),
    );
  }

  Future<void> selectModule(CurriculumModule module) async {
    if (module.premium && !_state.isPremium) {
      _setState(
        _state.copyWith(
          lockedReason:
              'This module is premium. Unlock Premium to continue the curriculum.',
          screen: AppScreen.paywall,
          cancelled: false,
        ),
      );
      return;
    }
    await _storage.saveModule(module.id);
    _setState(
      _state.copyWith(
        moduleId: module.id,
        screen: AppScreen.chat,
        error: null,
        lockedReason: null,
      ),
    );
  }

  void openAssist() => _setState(_state.copyWith(screen: AppScreen.assist));

  void openPaywall() => _setState(_state.copyWith(screen: AppScreen.paywall));

  void goTo(AppScreen screen) => _setState(_state.copyWith(screen: screen));

  Future<String> getCoachReply(List<ChatMessage> messages) {
    return _ai.getCoachReply(
      messages: messages,
      persona: activePersona,
      module: activeModule,
    );
  }

  Future<void> endSession({
    required List<ChatMessage> messages,
    required bool voiceUsed,
  }) async {
    _setState(_state.copyWith(busy: true, cancelled: false));
    final result = await _ai.scoreConversation(
      messages: messages,
      persona: activePersona,
      module: activeModule,
      voiceUsed: voiceUsed,
    );
    final completed = _state.completedModules.contains(activeModule.id)
        ? _state.completedModules
        : <String>[..._state.completedModules, activeModule.id];

    final shouldNudge = result.score >= 80 &&
        activePersona.isEasy &&
        !_state.adaptiveNudgeSeen;

    await _storage.saveLastScore(result);
    await _storage.saveCompletedModules(completed);
    if (shouldNudge) {
      await _storage.saveAdaptiveNudgeSeen();
    }

    _setState(
      _state.copyWith(
        busy: false,
        activeScore: result,
        lastScore: result,
        completedModules: completed,
        showNudge: shouldNudge,
        adaptiveNudgeSeen: _state.adaptiveNudgeSeen || shouldNudge,
        screen: AppScreen.score,
        error: null,
      ),
    );
  }

  void practiceAgain() {
    _setState(_state.copyWith(screen: AppScreen.chat, activeScore: null));
  }

  Future<void> openNextModule() async {
    final index = modules.indexWhere((m) => m.id == activeModule.id);
    final next = index >= 0 && index < modules.length - 1 ? modules[index + 1] : null;
    if (next == null) {
      _setState(_state.copyWith(screen: AppScreen.curriculum));
      return;
    }
    await selectModule(next);
  }

  Future<AssistResult> reviewAssist(String transcript) {
    return _ai.reviewTranscript(transcript: transcript);
  }

  Future<void> refreshEntitlement() async {
    final status = await _paywall.refresh();
    _setState(
      _state.copyWith(
        isPremium: status.isPremium,
        paywallConfigured: status.isConfigured,
        error: status.lastError,
        cancelled: status.cancelled,
      ),
    );
  }

  Future<void> purchasePremium() async {
    _setState(_state.copyWith(busy: true, cancelled: false));
    final status = await _paywall.purchase();
    _setState(
      _state.copyWith(
        busy: false,
        isPremium: status.isPremium,
        paywallConfigured: status.isConfigured,
        cancelled: status.cancelled,
        error: status.lastError,
      ),
    );
  }

  Future<void> restorePurchases() async {
    _setState(_state.copyWith(busy: true, cancelled: false));
    final status = await _paywall.restore();
    _setState(
      _state.copyWith(
        busy: false,
        isPremium: status.isPremium,
        paywallConfigured: status.isConfigured,
        error: status.lastError,
      ),
    );
  }

  Future<void> manageSubscription() => _paywall.manageSubscription();

  Future<VoiceInputState> startListening() async {
    final state = await _voiceInput.startListening();
    if (state.error != null) {
      _setState(_state.copyWith(error: state.error));
    }
    return state;
  }

  Future<void> stopListening() => _voiceInput.stopListening();

  Future<void> speak(String text) => _voiceOutput.speak(text);

  Future<void> cancelCurrentAction() async {
    await _voiceOutput.stop();
    await _voiceInput.stopListening();
    _setState(_state.copyWith(cancelled: true, busy: false));
  }

  void _setState(AppState value) {
    _state = value;
    notifyListeners();
  }
}
