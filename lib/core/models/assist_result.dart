class AssistResult {
  const AssistResult({
    required this.working,
    required this.next,
    required this.watch,
  });

  final String working;
  final String next;
  final String watch;

  factory AssistResult.fromJson(Map<String, dynamic> json) {
    final working = json['working']?.toString().trim();
    final next = json['next']?.toString().trim();
    final watch = json['watch']?.toString().trim();
    if (working == null || next == null || watch == null) {
      return AssistResult.fallback();
    }
    return AssistResult(working: working, next: next, watch: watch);
  }

  static AssistResult fallback() {
    return const AssistResult(
      working:
          'Look for the moments where both people contribute a specific detail.',
      next:
          'Try responding to one detail already present before adding a new topic.',
      watch: 'Avoid editing every sentence in your head before you send it.',
    );
  }
}
