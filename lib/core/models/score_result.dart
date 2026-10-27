class ScoreResult {
  const ScoreResult({
    required this.score,
    required this.feedback,
    required this.deliveryNote,
  });

  final int score;
  final List<String> feedback;
  final String? deliveryNote;

  Map<String, dynamic> toJson() => {
        'score': score,
        'feedback': feedback,
        'deliveryNote': deliveryNote,
      };

  factory ScoreResult.fromJson(Map<String, dynamic> json) {
    final feedbackRaw = json['feedback'];
    final feedback = feedbackRaw is List
        ? feedbackRaw.map((e) => e.toString()).take(3).toList()
        : <String>[];
    final safeFeedback = feedback.length == 3
        ? feedback
        : <String>[
            'You stayed engaged and practiced with intent.',
            'Add one specific detail to make your next reply easier to build on.',
            'Ask one curious follow-up to keep momentum going.',
          ];
    return ScoreResult(
      score: ((json['score'] as num?) ?? 72).round().clamp(0, 100),
      feedback: safeFeedback,
      deliveryNote: json['delivery_note']?.toString() ??
          json['deliveryNote']?.toString(),
    );
  }

  static ScoreResult fallback({required bool voiceUsed}) {
    return ScoreResult(
      score: 72,
      feedback: const <String>[
        'You practiced the module focus with a genuine answer.',
        'Try adding one specific detail to make your next reply easier to build on.',
        'A curious follow-up is a reliable way to keep things flowing.',
      ],
      deliveryNote: voiceUsed
          ? 'Try a relaxed pace and leave a short beat before responding.'
          : null,
    );
  }
}
