import 'package:flutter/material.dart';

import 'app/charmly_app.dart';
import 'core/persistence/app_storage.dart';
import 'core/services/ai_backend_client.dart';
import 'core/services/paywall_service.dart';
import 'core/services/voice_service.dart';
import 'features/foundation/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await AppStorage.create();
  final ai = AiBackendClient();
  final paywall = RevenueCatPaywallService();
  final voiceInput = SpeechToTextVoiceInputService();
  final voiceOutput = FlutterTtsVoiceOutputService();
  final controller = AppController(
    storage: storage,
    ai: ai,
    paywall: paywall,
    voiceInput: voiceInput,
    voiceOutput: voiceOutput,
  );
  await controller.initialize();
  runApp(CharmlyApp(controller: controller));
}
