import 'dart:convert';

import 'package:charmly_flutter/core/models/module.dart';
import 'package:charmly_flutter/core/models/persona.dart';
import 'package:charmly_flutter/core/models/score_result.dart';
import 'package:charmly_flutter/core/services/ai_backend_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('score parser clamps and returns exactly three feedbacks', () {
    final parsed = ScoreResult.fromJson(<String, dynamic>{
      'score': 141,
      'feedback': <String>['a', 'b', 'c', 'd'],
      'delivery_note': 'x',
    });

    expect(parsed.score, 100);
    expect(parsed.feedback.length, 3);
  });

  test('chat reply falls back in failure mode', () async {
    final client = AiBackendClient(
      client: MockClient((_) async => http.Response('bad', 500)),
    );

    const persona = Persona(
      id: 'maya',
      name: 'Maya',
      gender: PersonaGender.girl,
      tier: PersonaTier.easy,
      description: 'desc',
      assetPath: 'assets/images/persona-maya.png',
    );
    const module = CurriculumModule(
      id: 'opener',
      name: 'The Opener',
      goal: 'goal',
      focus: 'focus',
      premium: false,
    );
    final text =
        await client.getCoachReply(messages: const [], persona: persona, module: module);
    expect(text.isNotEmpty, true);
  });

  test('assist fallback returns safe fields on invalid json', () async {
    final client = AiBackendClient(
      client: MockClient((_) async => http.Response(jsonEncode(<String, dynamic>{'x': 'y'}), 200)),
    );

    final result = await client.reviewTranscript(transcript: 'x');
    expect(result.working.isNotEmpty, true);
    expect(result.next.isNotEmpty, true);
    expect(result.watch.isNotEmpty, true);
  });
}
