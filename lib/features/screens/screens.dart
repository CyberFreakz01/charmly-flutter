import 'package:flutter/material.dart';

import '../../core/data/catalog.dart';
import '../../core/models/assist_result.dart';
import '../../core/models/message.dart';
import '../../core/models/module.dart';
import '../../core/models/persona.dart';
import '../../core/models/quiz_question.dart';
import '../../core/models/score_result.dart';
import '../../core/services/voice_service.dart';
import '../../core/theme/charmly_theme.dart';
import '../../features/foundation/app_controller.dart';
import '../../features/foundation/app_state.dart';
import '../widgets/charmly_widgets.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BrandMark(size: 52),
            SizedBox(height: 18),
            CircularProgressIndicator(color: CharmlyColors.primary),
          ],
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CharmlyColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CharmlyColors.destructive),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline, color: CharmlyColors.destructive, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool adult = false;
  bool terms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  BrandMark(size: 48),
                  SizedBox(width: 12),
                  Text('charmly', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 40),
              const Text('PRACTICE THE REAL THING',
                  style: TextStyle(color: CharmlyColors.primary, fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Text('Find your\nnatural charm.', style: TextStyle(fontSize: 46, height: 1.1, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              const Text(
                'A private space to practice conversation, build confidence, and get better at being you.',
                style: TextStyle(fontSize: 16, color: CharmlyColors.mutedForeground),
              ),
              const Spacer(),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: adult,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => adult = v ?? false),
                title: const Text('I confirm I am 18 years or older'),
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: terms,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => terms = v ?? false),
                title: const Text('I agree to the Terms of Service and Privacy Policy'),
              ),
              PrimaryButton(
                label: 'Let’s get started',
                icon: Icons.north_east,
                enabled: adult && terms,
                onPressed: widget.onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.onComplete});

  final ValueChanged<Map<String, String>> onComplete;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int step = 0;
  final Map<String, String> answers = <String, String>{};

  QuizQuestion get question => quizQuestions[step];

  @override
  Widget build(BuildContext context) {
    final selected = answers[question.id];
    return Scaffold(
      appBar: AppBar(title: const Text('A little context')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: List<Widget>.generate(
                quizQuestions.length,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index == quizQuestions.length - 1 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: index <= step ? CharmlyColors.primary : CharmlyColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('QUESTION ${step + 1} OF ${quizQuestions.length}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: CharmlyColors.primary)),
            const SizedBox(height: 12),
            Text(question.question, style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final option = question.options[index];
                  final isSelected = selected == option.key;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? CharmlyColors.primary : CharmlyColors.border,
                      ),
                    ),
                    tileColor: isSelected ? CharmlyColors.primary : CharmlyColors.card,
                    title: Text(
                      option.value,
                      style: TextStyle(
                        color: isSelected ? CharmlyColors.primaryForeground : CharmlyColors.foreground,
                      ),
                    ),
                    trailing: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? CharmlyColors.primaryForeground : CharmlyColors.border,
                    ),
                    onTap: () => setState(() => answers[question.id] = option.key),
                  );
                },
              ),
            ),
            PrimaryButton(
              label: step == quizQuestions.length - 1 ? 'See my practice path' : 'Continue',
              enabled: selected != null,
              onPressed: () {
                if (step < quizQuestions.length - 1) {
                  setState(() => step += 1);
                } else {
                  widget.onComplete(Map<String, String>.from(answers));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PersonasScreen extends StatefulWidget {
  const PersonasScreen({
    super.key,
    required this.selectedId,
    required this.isPremium,
    required this.onSelect,
    required this.onBack,
  });

  final String selectedId;
  final bool isPremium;
  final ValueChanged<Persona> onSelect;
  final VoidCallback onBack;

  @override
  State<PersonasScreen> createState() => _PersonasScreenState();
}

class _PersonasScreenState extends State<PersonasScreen> {
  PersonaGender gender = PersonaGender.girl;

  @override
  Widget build(BuildContext context) {
    final visible = personas.where((p) => p.gender == gender).toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: const Text('Choose your partner'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          SegmentedButton<PersonaGender>(
            segments: const <ButtonSegment<PersonaGender>>[
              ButtonSegment<PersonaGender>(value: PersonaGender.girl, label: Text('Girl')),
              ButtonSegment<PersonaGender>(value: PersonaGender.boy, label: Text('Boy')),
            ],
            selected: <PersonaGender>{gender},
            onSelectionChanged: (set) => setState(() => gender = set.first),
          ),
          const SizedBox(height: 18),
          ...visible.map((persona) {
            final locked = !widget.isPremium && !persona.isEasy;
            final selected = widget.selectedId == persona.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(backgroundImage: AssetImage(persona.assetPath), radius: 30),
                tileColor: CharmlyColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                  side: BorderSide(
                    color: selected ? CharmlyColors.primary : CharmlyColors.border,
                  ),
                ),
                title: Text(persona.name),
                subtitle: Text(persona.description),
                trailing: Icon(
                  locked ? Icons.lock : selected ? Icons.check_circle : Icons.chevron_right,
                  color: selected ? CharmlyColors.primary : CharmlyColors.mutedForeground,
                ),
                onTap: () => widget.onSelect(persona),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({
    super.key,
    required this.completed,
    required this.isPremium,
    required this.selectedModule,
    required this.onSelect,
    required this.onAssist,
    required this.onBack,
  });

  final List<String> completed;
  final bool isPremium;
  final String selectedModule;
  final ValueChanged<CurriculumModule> onSelect;
  final VoidCallback onAssist;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('Your practice path'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: onAssist,
            icon: const Icon(Icons.message_outlined, color: CharmlyColors.primary),
            label: const Text('Assist', style: TextStyle(color: CharmlyColors.primary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          ...modules.map((module) {
            final complete = completed.contains(module.id);
            final active = selectedModule == module.id;
            final locked = module.premium && !isPremium;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                tileColor: active ? CharmlyColors.card : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: active ? CharmlyColors.border : Colors.transparent),
                ),
                leading: CircleAvatar(
                  backgroundColor: complete
                      ? CharmlyColors.accent
                      : active
                          ? CharmlyColors.primary
                          : CharmlyColors.secondary,
                  child: complete
                      ? const Icon(Icons.check, color: CharmlyColors.accentForeground)
                      : Text(
                          '${modules.indexOf(module) + 1}',
                          style: TextStyle(
                            color: active
                                ? CharmlyColors.primaryForeground
                                : CharmlyColors.mutedForeground,
                          ),
                        ),
                ),
                title: Text(module.name),
                subtitle: Text(module.goal),
                trailing: Icon(
                  locked ? Icons.lock : Icons.chevron_right,
                  color: CharmlyColors.mutedForeground,
                ),
                onTap: () => onSelect(module),
              ),
            );
          }),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CharmlyColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Premium opens every tier, module, voice delivery note, and Rizz Assist.',
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.controller,
    required this.persona,
    required this.module,
    required this.lastScore,
    required this.onBack,
    required this.onEnd,
  });

  final AppController controller;
  final Persona persona;
  final CurriculumModule module;
  final ScoreResult? lastScore;
  final VoidCallback onBack;
  final Future<void> Function(List<ChatMessage> messages, bool voiceUsed) onEnd;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController input = TextEditingController();
  final List<ChatMessage> messages = <ChatMessage>[welcomeMessage];
  bool isSending = false;
  bool isListening = false;
  bool isTalking = false;
  bool voiceUsed = false;
  String? error;
  String? retryText;

  Future<void> sendMessage(String text) async {
    setState(() {
      error = null;
      retryText = null;
      isSending = true;
      messages.add(ChatMessage.make(MessageRole.user, text));
      input.clear();
    });
    try {
      final reply = await widget.controller.getCoachReply(messages);
      setState(() => messages.add(ChatMessage.make(MessageRole.model, reply)));
      isTalking = true;
      await widget.controller.speak(reply);
      if (mounted) {
        setState(() => isTalking = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'I couldn’t connect right now. Please retry.';
          retryText = text;
        });
      }
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  Future<void> toggleListening() async {
    if (isListening) {
      await widget.controller.stopListening();
      setState(() => isListening = false);
      return;
    }
    final voiceState = await widget.controller.startListening();
    setState(() {
      isListening = voiceState.isListening;
      if (voiceState.text.isNotEmpty) {
        input.text = voiceState.text;
      }
      if (voiceState.error != null) {
        error = voiceState.error;
      } else {
        voiceUsed = true;
      }
    });
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: Row(
          children: <Widget>[
            CircleAvatar(backgroundImage: AssetImage(widget.persona.assetPath), radius: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.persona.name, style: const TextStyle(fontSize: 16)),
                  Text('${widget.module.name} · ${widget.persona.tier.name.toUpperCase()}',
                      style: const TextStyle(fontSize: 11, color: CharmlyColors.mutedForeground)),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => widget.onEnd(messages, voiceUsed),
            child: const Text('End', style: TextStyle(color: CharmlyColors.primary)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  if (widget.lastScore != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          'Last session score: ${widget.lastScore!.score}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: CharmlyColors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  ...messages.map((message) {
                    final user = message.role == MessageRole.user;
                    return Align(
                      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: user ? CharmlyColors.primary : CharmlyColors.card,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: user ? CharmlyColors.primary : CharmlyColors.border,
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: user ? CharmlyColors.primaryForeground : CharmlyColors.foreground,
                          ),
                        ),
                      ),
                    );
                  }),
                  if (isSending)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text('Typing…', style: TextStyle(color: CharmlyColors.mutedForeground)),
                      ),
                    ),
                  if (isTalking)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text('Speaking…', style: TextStyle(color: CharmlyColors.mutedForeground)),
                      ),
                    ),
                ],
              ),
            ),
            if (error != null)
              ErrorBanner(
                message: error!,
                actionLabel: retryText == null ? null : 'Retry',
                onAction: retryText == null ? null : () => sendMessage(retryText!),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: input,
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: isListening
                            ? 'Listening...'
                            : 'Type or speak your reply...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor:
                          isListening ? CharmlyColors.primary : CharmlyColors.secondary,
                    ),
                    onPressed: toggleListening,
                    icon: Icon(
                      isListening ? Icons.stop : Icons.mic,
                      color: isListening
                          ? CharmlyColors.primaryForeground
                          : CharmlyColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: CharmlyColors.primary,
                    ),
                    onPressed: isSending || input.text.trim().isEmpty
                        ? null
                        : () => sendMessage(input.text.trim()),
                    icon: const Icon(Icons.arrow_upward,
                        color: CharmlyColors.primaryForeground),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Voice stays on-device. Take your time.',
                style: TextStyle(fontSize: 10, color: CharmlyColors.mutedForeground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({
    super.key,
    required this.result,
    required this.persona,
    required this.module,
    required this.isPremium,
    required this.showNudge,
    required this.onPracticeAgain,
    required this.onNext,
    required this.onPaywall,
  });

  final ScoreResult result;
  final Persona persona;
  final CurriculumModule module;
  final bool isPremium;
  final bool showNudge;
  final VoidCallback onPracticeAgain;
  final VoidCallback onNext;
  final VoidCallback onPaywall;

  @override
  Widget build(BuildContext context) {
    final label = result.score >= 80
        ? 'Strong natural flow'
        : result.score >= 60
            ? 'Good foundation'
            : 'Room to grow';
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            const Row(
              children: <Widget>[
                BrandMark(size: 42),
                SizedBox(width: 12),
                Text('Session complete', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            if (showNudge)
              Container(
                margin: const EdgeInsets.only(top: 18),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: CharmlyColors.secondary,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: CharmlyColors.primary),
                ),
                child: const Text('You handled that well — ready for a more guarded persona next?'),
              ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: <Widget>[
                  Text('YOUR ${module.name.toUpperCase()} SCORE', style: const TextStyle(fontSize: 11, color: CharmlyColors.primary, fontWeight: FontWeight.w700)),
                  Text('${result.score}', style: const TextStyle(fontSize: 86, height: 1.1, fontWeight: FontWeight.w700)),
                  Text(label, style: const TextStyle(color: CharmlyColors.accent, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Notes for next time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...result.feedback.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: CharmlyColors.secondary,
                      child: Text('${entry.key + 1}', style: const TextStyle(color: CharmlyColors.primary, fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(entry.value, style: const TextStyle(color: CharmlyColors.mutedForeground))),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: const BorderSide(color: CharmlyColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Voice delivery', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      isPremium
                          ? result.deliveryNote ?? 'Your spoken delivery appears here after a voice session.'
                          : 'Unlock Premium for pacing, filler-word, and talk-time feedback.',
                      style: const TextStyle(color: CharmlyColors.mutedForeground),
                    ),
                    if (!isPremium)
                      TextButton(onPressed: onPaywall, child: const Text('Unlock Premium')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Practice again', icon: Icons.refresh, onPressed: onPracticeAgain),
            const SizedBox(height: 8),
            SecondaryButton(label: 'Next module', icon: Icons.arrow_forward, onPressed: onNext),
          ],
        ),
      ),
    );
  }
}

class AssistScreen extends StatefulWidget {
  const AssistScreen({
    super.key,
    required this.controller,
    required this.isPremium,
    required this.onBack,
    required this.onPaywall,
  });

  final AppController controller;
  final bool isPremium;
  final VoidCallback onBack;
  final VoidCallback onPaywall;

  @override
  State<AssistScreen> createState() => _AssistScreenState();
}

class _AssistScreenState extends State<AssistScreen> {
  final TextEditingController transcript = TextEditingController();
  AssistResult? result;
  bool loading = false;
  String? error;

  Future<void> review() async {
    if (transcript.text.trim().isEmpty) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await widget.controller.reviewAssist(transcript.text.trim());
      if (mounted) {
        setState(() => result = data);
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'I couldn’t review that right now. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    transcript.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: const Text('Rizz Assist'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CharmlyColors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Review a real conversation.', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text(
                  'Paste an exchange and your coach will point out what’s working, what to say next, and one thing to watch.',
                  style: TextStyle(color: CharmlyColors.mutedForeground),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!widget.isPremium)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('A premium coaching layer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Rizz Assist is built for your real conversations, not pickup lines.'),
                    const SizedBox(height: 10),
                    PrimaryButton(label: 'Unlock Rizz Assist', icon: Icons.north_east, onPressed: widget.onPaywall),
                  ],
                ),
              ),
            )
          else ...<Widget>[
            const Text('Paste the exchange', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: transcript,
              minLines: 8,
              maxLines: 12,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Paste a conversation here...'),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, style: const TextStyle(color: CharmlyColors.destructive)),
              ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: loading ? 'Reviewing...' : 'Review with my coach',
              icon: Icons.north_east,
              enabled: !loading && transcript.text.trim().isNotEmpty,
              onPressed: review,
            ),
            if (result != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: <Widget>[
                    _assistCard('What’s working', result!.working, Icons.check_circle_outline),
                    _assistCard('What to say next', result!.next, Icons.turn_right),
                    _assistCard('One thing to watch', result!.watch, Icons.remove_red_eye_outlined),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _assistCard(String title, String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CharmlyColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CharmlyColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: CharmlyColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(text, style: const TextStyle(color: CharmlyColors.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({
    super.key,
    required this.state,
    required this.onClose,
    required this.onRestore,
    required this.onManage,
    required this.onPurchase,
  });

  final AppState state;
  final VoidCallback onClose;
  final VoidCallback onRestore;
  final VoidCallback onManage;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
                const BrandMark(size: 42),
              ],
            ),
            const SizedBox(height: 18),
            const Text('UNLOCK YOUR NEXT LEVEL', style: TextStyle(fontSize: 11, color: CharmlyColors.primary, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
            const SizedBox(height: 8),
            const Text('More practice.\nMore progress.', style: TextStyle(fontSize: 40, height: 1.06, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text('Premium keeps the core chat free and opens the structured coaching around it.', style: TextStyle(color: CharmlyColors.mutedForeground)),
            const SizedBox(height: 16),
            ...<String>[
              'All 6 conversation personas',
              'All 5 curriculum modules',
              'Full voice delivery feedback',
              'Rizz Assist for real conversations',
            ].map((text) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle, color: CharmlyColors.accent),
                  title: Text(text),
                )),
            if (!state.paywallConfigured)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CharmlyColors.secondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'RevenueCat is not configured. Add CHARMLY_REVENUECAT_PUBLIC_KEY for live plans and purchases.',
                  style: TextStyle(fontSize: 11, color: CharmlyColors.mutedForeground),
                ),
              ),
            if (state.cancelled)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Purchase cancelled.', style: TextStyle(color: CharmlyColors.mutedForeground)),
              ),
            if (state.error != null)
              ErrorBanner(message: state.error!),
            const SizedBox(height: 10),
            PrimaryButton(
              label: state.paywallConfigured ? 'Start Premium' : 'Set up Premium first',
              icon: Icons.north_east,
              onPressed: onPurchase,
              enabled: !state.busy,
            ),
            const SizedBox(height: 8),
            SecondaryButton(label: 'Restore purchases', icon: Icons.restore, onPressed: onRestore),
            TextButton(onPressed: onManage, child: const Text('Manage or cancel a subscription')),
          ],
        ),
      ),
    );
  }
}
