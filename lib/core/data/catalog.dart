import '../models/message.dart';
import '../models/module.dart';
import '../models/persona.dart';
import '../models/quiz_question.dart';

const Map<String, String> storageKeys = <String, String>{
  'onboarding': '@charmly/onboarding-complete',
  'ageConfirmed': '@charmly/age-confirmed',
  'termsAgreed': '@charmly/terms-agreed',
  'quiz': '@charmly/quiz',
  'persona': '@charmly/persona',
  'module': '@charmly/module',
  'completed': '@charmly/completed-modules',
  'score': '@charmly/last-score',
  'adaptiveNudge': '@charmly/adaptive-nudge-seen',
};

const ChatMessage welcomeMessage = ChatMessage(
  id: 'welcome',
  role: MessageRole.model,
  text:
      'Hey, I’m glad you’re here. Start with a simple hello, or tell me what you’ve been into lately.',
);

const String personaSafetyPrompt = '''
You are Charmly, a warm and realistic conversation-practice partner for adults.
This is communication skill-building, never dating, matchmaking, or a companion relationship.
Keep replies to 1-3 concise sentences because they may be read aloud.
Never use sexual content, romantic escalation, physical intimacy, abuse, demeaning language,
or emotional manipulation. If the user pushes toward explicit or romantic-roleplay content,
redirect naturally to a normal conversation without being preachy.
Difficulty means the effort required, never hostility or cruelty.
''';

const List<Persona> personas = <Persona>[
  Persona(
    id: 'maya',
    name: 'Maya',
    gender: PersonaGender.girl,
    tier: PersonaTier.easy,
    description: 'Warm, bubbly, and gives you room to relax.',
    assetPath: 'assets/images/persona-maya.png',
  ),
  Persona(
    id: 'sofia',
    name: 'Sofia',
    gender: PersonaGender.girl,
    tier: PersonaTier.medium,
    description: 'Witty and a little reserved. Rewards genuine effort.',
    assetPath: 'assets/images/persona-sofia.png',
  ),
  Persona(
    id: 'elena',
    name: 'Elena',
    gender: PersonaGender.girl,
    tier: PersonaTier.hard,
    description: 'Guarded and sharp. You earn the longer replies.',
    assetPath: 'assets/images/persona-elena.png',
  ),
  Persona(
    id: 'jake',
    name: 'Jake',
    gender: PersonaGender.boy,
    tier: PersonaTier.easy,
    description: 'Friendly, outgoing, and easy to talk with.',
    assetPath: 'assets/images/persona-jake.png',
  ),
  Persona(
    id: 'ethan',
    name: 'Ethan',
    gender: PersonaGender.boy,
    tier: PersonaTier.medium,
    description: 'Dry humor and low-effort replies until you engage him.',
    assetPath: 'assets/images/persona-ethan.png',
  ),
  Persona(
    id: 'marcus',
    name: 'Marcus',
    gender: PersonaGender.boy,
    tier: PersonaTier.hard,
    description: 'Confident and guarded. He challenges you to keep pace.',
    assetPath: 'assets/images/persona-marcus.png',
  ),
];

const List<CurriculumModule> modules = <CurriculumModule>[
  CurriculumModule(
    id: 'opener',
    name: 'The Opener',
    goal: 'Start a conversation naturally, without generic lines.',
    focus: 'opener naturalness and confidence',
    premium: false,
  ),
  CurriculumModule(
    id: 'flow',
    name: 'Keeping the Flow',
    goal: 'Ask good follow-ups and avoid one-word exchanges.',
    focus: 'follow-up quality and active listening',
    premium: true,
  ),
  CurriculumModule(
    id: 'signals',
    name: 'Reading the Signals',
    goal: 'Notice shifts in tone and adjust your approach.',
    focus: 'reading tone and adjusting naturally',
    premium: true,
  ),
  CurriculumModule(
    id: 'banter',
    name: 'Banter & Callbacks',
    goal: 'Build playful rapport with humor and memory.',
    focus: 'light humor and thoughtful callbacks',
    premium: true,
  ),
  CurriculumModule(
    id: 'awkward',
    name: 'Handling Awkward Moments',
    goal: 'Recover gracefully from a pause or mild rebuff.',
    focus: 'resilience and recovery',
    premium: true,
  ),
];

const List<QuizQuestion> quizQuestions = <QuizQuestion>[
  QuizQuestion(
    id: 'struggle',
    question: 'What feels hardest right now?',
    options: <MapEntry<String, String>>[
      MapEntry<String, String>('starting', 'Starting conversations'),
      MapEntry<String, String>('flow', 'Keeping the conversation going'),
      MapEntry<String, String>('signals', 'Reading the other person’s energy'),
      MapEntry<String, String>('overthinking', 'Overthinking what to say'),
    ],
  ),
  QuizQuestion(
    id: 'confidence',
    question: 'How would you describe your confidence?',
    options: <MapEntry<String, String>>[
      MapEntry<String, String>('nervous', 'Very nervous'),
      MapEntry<String, String>('awkward', 'A bit awkward'),
      MapEntry<String, String>('inconsistent', 'Decent but inconsistent'),
      MapEntry<String, String>('confident', 'Pretty confident already'),
    ],
  ),
  QuizQuestion(
    id: 'practice',
    question: 'What would make practice feel useful?',
    options: <MapEntry<String, String>>[
      MapEntry<String, String>('opening', 'A natural first message'),
      MapEntry<String, String>('momentum', 'Never running out of things to say'),
      MapEntry<String, String>('presence', 'Feeling more present and relaxed'),
      MapEntry<String, String>('recovery', 'Staying composed when it gets awkward'),
    ],
  ),
];
