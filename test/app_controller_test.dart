import 'package:charmly_flutter/core/models/assist_result.dart';
import 'package:charmly_flutter/core/models/message.dart';
import 'package:charmly_flutter/core/models/module.dart';
import 'package:charmly_flutter/core/models/persona.dart';
import 'package:charmly_flutter/core/models/score_result.dart';
import 'package:charmly_flutter/core/persistence/app_storage.dart';
import 'package:charmly_flutter/core/services/ai_backend_client.dart';
import 'package:charmly_flutter/core/services/paywall_service.dart';
import 'package:charmly_flutter/core/services/voice_service.dart';
import 'package:charmly_flutter/features/foundation/app_controller.dart';
import 'package:charmly_flutter/features/foundation/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStorage implements AppStorage {
  PersistedAppData data = const PersistedAppData(
    onboardingComplete: false,
    quiz: <String, String>{},
    personaId: 'maya',
    moduleId: 'opener',
    completedModules: <String>[],
    lastScore: null,
    adaptiveNudgeSeen: false,
  );

  @override
  Future<PersistedAppData> load() async => data;

  @override
  Future<void> markOnboardingComplete() async {}

  @override
  Future<void> saveAdaptiveNudgeSeen() async {}

  @override
  Future<void> saveCompletedModules(List<String> ids) async {}

  @override
  Future<void> saveLastScore(ScoreResult score) async {}

  @override
  Future<void> saveModule(String id) async {}

  @override
  Future<void> savePersona(String id) async {}

  @override
  Future<void> saveQuiz(Map<String, String> quiz) async {}
}

class _FakeAi implements AiCoachService {
  @override
  Future<String> getCoachReply({
    required List<ChatMessage> messages,
    required Persona persona,
    required CurriculumModule module,
  }) async =>
      'reply';

  @override
  Future<AssistResult> reviewTranscript({required String transcript}) async => AssistResult.fallback();

  @override
  Future<ScoreResult> scoreConversation({
    required List<ChatMessage> messages,
    required Persona persona,
    required CurriculumModule module,
    required bool voiceUsed,
  }) async =>
      ScoreResult.fallback(voiceUsed: voiceUsed);
}

class _FakePaywall implements PaywallService {
  PaywallStatus status = const PaywallStatus(isConfigured: false, isPremium: false);

  @override
  Future<PaywallStatus> initialize() async => status;

  @override
  Future<void> manageSubscription() async {}

  @override
  Future<PaywallStatus> purchase() async => status;

  @override
  Future<PaywallStatus> refresh() async => status;

  @override
  Future<PaywallStatus> restore() async => status;
}

class _FakeVoiceIn implements VoiceInputService {
  @override
  Future<bool> initialize() async => true;

  @override
  Future<VoiceInputState> startListening() async =>
      const VoiceInputState(text: 'hello', isListening: false);

  @override
  Future<void> stopListening() async {}
}

class _FakeVoiceOut implements VoiceOutputService {
  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}

void main() {
  test('initialize starts on onboarding when consent incomplete', () async {
    final storage = _FakeStorage();
    final controller = AppController(
      storage: storage,
      ai: _FakeAi(),
      paywall: _FakePaywall(),
      voiceInput: _FakeVoiceIn(),
      voiceOutput: _FakeVoiceOut(),
    );
    await controller.initialize();
    expect(controller.state.screen, AppScreen.onboarding);
  });

  test('premium gating routes locked persona to paywall', () async {
    final storage = _FakeStorage()
      ..data = const PersistedAppData(
        onboardingComplete: true,
        quiz: <String, String>{'struggle': 'flow'},
        personaId: 'maya',
        moduleId: 'opener',
        completedModules: <String>[],
        lastScore: null,
        adaptiveNudgeSeen: false,
      );

    final controller = AppController(
      storage: storage,
      ai: _FakeAi(),
      paywall: _FakePaywall(),
      voiceInput: _FakeVoiceIn(),
      voiceOutput: _FakeVoiceOut(),
    );

    await controller.initialize();
    await controller.selectPersona(controller.personasList.firstWhere((p) => p.id == 'sofia'));

    expect(controller.state.screen, AppScreen.paywall);
    expect(controller.state.lockedReason, isNotNull);
  });

  test('endSession stores score and opens score screen', () async {
    final storage = _FakeStorage()
      ..data = const PersistedAppData(
        onboardingComplete: true,
        quiz: <String, String>{'struggle': 'starting'},
        personaId: 'maya',
        moduleId: 'opener',
        completedModules: <String>[],
        lastScore: null,
        adaptiveNudgeSeen: false,
      );

    final controller = AppController(
      storage: storage,
      ai: _FakeAi(),
      paywall: _FakePaywall(),
      voiceInput: _FakeVoiceIn(),
      voiceOutput: _FakeVoiceOut(),
    );

    await controller.initialize();
    await controller.endSession(
      messages: const <ChatMessage>[ChatMessage(id: '1', role: MessageRole.user, text: 'hey')],
      voiceUsed: true,
    );

    expect(controller.state.screen, AppScreen.score);
    expect(controller.state.activeScore, isNotNull);
    expect(controller.state.lastScore, isNotNull);
  });
}
