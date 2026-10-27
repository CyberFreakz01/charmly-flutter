import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/runtime_config.dart';
import '../data/catalog.dart';
import '../models/assist_result.dart';
import '../models/message.dart';
import '../models/module.dart';
import '../models/persona.dart';
import '../models/score_result.dart';

abstract class AiCoachService {
  Future<String> getCoachReply({
    required List<ChatMessage> messages,
    required Persona persona,
    required CurriculumModule module,
  });

  Future<ScoreResult> scoreConversation({
    required List<ChatMessage> messages,
    required Persona persona,
    required CurriculumModule module,
    required bool voiceUsed,
  });

  Future<AssistResult> reviewTranscript({required String transcript});
}

class AiBackendClient implements AiCoachService {
  AiBackendClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  bool get _mockEnabled =>
      RuntimeConfig.mockAiMode || RuntimeConfig.backendBaseUrl.trim().isEmpty;

  Future<Map<String, dynamic>> _postWithRetry(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (_mockEnabled) {
      throw const _MockOnlyException();
    }

    final uri = Uri.parse('${RuntimeConfig.backendBaseUrl}$path');
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await _client
            .post(
              uri,
              headers: const <String, String>{
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 12));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        lastError = 'status:${response.statusCode}';
      } on TimeoutException {
        lastError = 'timeout';
      } catch (e) {
        lastError = e;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw Exception('Backend call failed: $lastError');
  }

  @override
  Future<String> getCoachReply({
    required List<ChatMessage> messages,
    required Persona persona,
    required CurriculumModule module,
  }) async {
    try {
      final payload = <String, dynamic>{
        'persona': persona.id,
        'module': module.id,
        'safety_prompt': personaSafetyPrompt,
        'messages': messages
            .map((m) => <String, String>{
                  'role': m.role.name,
                  'text': m.text,
                })
            .toList(),
      };
      final json = await _postWithRetry('/chat/reply', payload);
      final reply = json['reply']?.toString().trim();
      if (reply == null || reply.isEmpty) {
        throw Exception('empty_reply');
      }
      return reply;
    } catch (_) {
      return _mockReply(messages: messages, persona: persona, module: module);
    }
  }

  @override
  Future<ScoreResult> scoreConversation({
    required List<ChatMessage> messages,
    required Persona persona,
    required CurriculumModule module,
    required bool voiceUsed,
  }) async {
    try {
      final transcript = messages
          .map((m) => '${m.role == MessageRole.user ? 'User' : persona.name}: ${m.text}')
          .join('\n');
      final json = await _postWithRetry('/chat/score', <String, dynamic>{
        'persona': persona.id,
        'module': module.id,
        'voice_used': voiceUsed,
        'transcript': transcript,
      });
      final parsed = ScoreResult.fromJson(json);
      if (parsed.feedback.length != 3) {
        return ScoreResult.fallback(voiceUsed: voiceUsed);
      }
      return ScoreResult(
        score: parsed.score,
        feedback: parsed.feedback.take(3).toList(),
        deliveryNote: voiceUsed ? parsed.deliveryNote : null,
      );
    } catch (_) {
      return ScoreResult.fallback(voiceUsed: voiceUsed);
    }
  }

  @override
  Future<AssistResult> reviewTranscript({required String transcript}) async {
    try {
      final json = await _postWithRetry('/assist/review', <String, dynamic>{
        'transcript': transcript,
      });
      return AssistResult.fromJson(json);
    } catch (_) {
      return AssistResult.fallback();
    }
  }

  String _mockReply({
    required List<ChatMessage> messages,
    required Persona persona,
    required CurriculumModule module,
  }) {
    final userText = messages.isNotEmpty ? messages.last.text : 'Hey';
    return '${persona.name}: Nice. For ${module.name.toLowerCase()}, tell me one concrete detail about "$userText" so I can respond to it.';
  }
}

class _MockOnlyException implements Exception {
  const _MockOnlyException();
}
