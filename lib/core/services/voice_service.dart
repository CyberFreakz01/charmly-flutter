import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

abstract class VoiceInputService {
  Future<bool> initialize();
  Future<VoiceInputState> startListening();
  Future<void> stopListening();
}

class VoiceInputState {
  const VoiceInputState({
    required this.text,
    required this.isListening,
    this.error,
    this.cancelled = false,
  });

  final String text;
  final bool isListening;
  final String? error;
  final bool cancelled;
}

class SpeechToTextVoiceInputService implements VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  String _latestText = '';
  bool _listening = false;
  String? _error;

  @override
  Future<bool> initialize() {
    return _speech.initialize(
      onError: _onError,
      onStatus: _onStatus,
    );
  }

  void _onStatus(String status) {
    _listening = status == 'listening';
  }

  void _onError(SpeechRecognitionError error) {
    _error = error.errorMsg;
    _listening = false;
  }

  @override
  Future<VoiceInputState> startListening() async {
    final available = await initialize();
    if (!available) {
      return const VoiceInputState(
        text: '',
        isListening: false,
        error: 'Voice input is unavailable on this device.',
      );
    }
    _error = null;
    _latestText = '';
    await _speech.listen(
      localeId: 'en_US',
      partialResults: true,
      cancelOnError: false,
      onResult: _onResult,
      listenFor: const Duration(seconds: 20),
    );
    _listening = true;
    return VoiceInputState(text: _latestText, isListening: _listening);
  }

  void _onResult(SpeechRecognitionResult result) {
    _latestText = result.recognizedWords.trim();
    if (result.finalResult) {
      _listening = false;
    }
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
    _listening = false;
  }
}

abstract class VoiceOutputService {
  Future<void> speak(String text);
  Future<void> stop();
}

class FlutterTtsVoiceOutputService implements VoiceOutputService {
  FlutterTtsVoiceOutputService() {
    _tts.setSpeechRate(0.48);
    _tts.setVolume(1);
  }

  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> speak(String text) {
    return _tts.speak(text);
  }

  @override
  Future<void> stop() {
    return _tts.stop();
  }
}
