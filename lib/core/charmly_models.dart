import 'package:flutter/material.dart';

enum Tier { easy, medium, hard }

class Persona {
  const Persona({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.assetPath,
  });

  final String id;
  final String name;
  final String description;
  final Tier tier;
  final String assetPath;
}

class CurriculumModule {
  const CurriculumModule({
    required this.id,
    required this.name,
    required this.goal,
    required this.premium,
  });

  final String id;
  final String name;
  final String goal;
  final bool premium;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  final String id;
  final String question;
  final List<(String, String)> options;
}

const personas = <Persona>[
  Persona(
    id: 'maya',
    name: 'Maya',
    description: 'Warm, bubbly, and gives you room to relax.',
    tier: Tier.easy,
    assetPath: 'assets/images/persona-maya.png',
  ),
  Persona(
    id: 'sofia',
    name: 'Sofia',
    description: 'Witty and a little reserved. Rewards genuine effort.',
    tier: Tier.medium,
    assetPath: 'assets/images/persona-sofia.png',
  ),
  Persona(
    id: 'elena',
    name: 'Elena',
    description: 'Guarded and sharp. You earn the longer replies.',
    tier: Tier.hard,
    assetPath: 'assets/images/persona-elena.png',
  ),
  Persona(
    id: 'jake',
    name: 'Jake',
    description: 'Friendly, outgoing, and easy to talk with.',
    tier: Tier.easy,
    assetPath: 'assets/images/persona-jake.png',
  ),
  Persona(
    id: 'ethan',
    name: 'Ethan',
    description: 'Dry humor and low-effort replies until you engage him.',
    tier: Tier.medium,
    assetPath: 'assets/images/persona-ethan.png',
  ),
  Persona(
    id: 'marcus',
    name: 'Marcus',
    description: 'Confident and guarded. He challenges you to keep pace.',
    tier: Tier.hard,
    assetPath: 'assets/images/persona-marcus.png',
  ),
];

const modules = <CurriculumModule>[
  CurriculumModule(
    id: 'opener',
    name: 'The Opener',
    goal: 'Start a conversation naturally, without generic lines.',
    premium: false,
  ),
  CurriculumModule(
    id: 'flow',
    name: 'Keeping the Flow',
    goal: 'Ask good follow-ups and avoid one-word exchanges.',
    premium: true,
  ),
  CurriculumModule(
    id: 'signals',
    name: 'Reading the Signals',
    goal: 'Notice shifts in tone and adjust your approach.',
    premium: true,
  ),
  CurriculumModule(
    id: 'banter',
    name: 'Banter & Callbacks',
    goal: 'Build playful rapport with humor and memory.',
    premium: true,
  ),
  CurriculumModule(
    id: 'awkward',
    name: 'Handling Awkward Moments',
    goal: 'Recover gracefully from a pause or mild rebuff.',
    premium: true,
  ),
];

const quizQuestions = <QuizQuestion>[
  QuizQuestion(
    id: 'struggle',
    question: 'What feels hardest right now?',
    options: [
      ('starting', 'Starting conversations'),
      ('flow', 'Keeping the conversation going'),
      ('signals', 'Reading the other person\'s energy'),
      ('overthinking', 'Overthinking what to say'),
    ],
  ),
  QuizQuestion(
    id: 'confidence',
    question: 'How would you describe your confidence?',
    options: [
      ('nervous', 'Very nervous'),
      ('awkward', 'A bit awkward'),
      ('inconsistent', 'Decent but inconsistent'),
      ('confident', 'Pretty confident already'),
    ],
  ),
  QuizQuestion(
    id: 'practice',
    question: 'What would make practice feel useful?',
    options: [
      ('opening', 'A natural first message'),
      ('momentum', 'Never running out of things to say'),
      ('presence', 'Feeling more present and relaxed'),
      ('recovery', 'Staying composed when it gets awkward'),
    ],
  ),
];

String tierLabel(Tier tier) => switch (tier) {
      Tier.easy => 'Easy',
      Tier.medium => 'Medium',
      Tier.hard => 'Hard',
    };

Color tierColor(Tier tier) => switch (tier) {
      Tier.easy => const Color(0xFFBBA1FF),
      Tier.medium => const Color(0xFFFF8A75),
      Tier.hard => const Color(0xFFFF8A75),
    };
