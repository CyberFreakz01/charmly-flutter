import 'package:flutter/material.dart';

import 'app/charmly_app.dart';
import 'core/persistence/app_storage.dart';
import 'core/services/ai_backend_client.dart';
import 'core/services/paywall_service.dart';
import 'core/services/voice_service.dart';
import 'features/foundation/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController(
    storage: await AppStorage.create(),
    ai: AiBackendClient(),
    paywall: RevenueCatPaywallService(),
    voiceInput: SpeechToTextVoiceInputService(),
    voiceOutput: FlutterTtsVoiceOutputService(),
  );
  await controller.initialize();
  runApp(CharmlyApp(controller: controller));
}
