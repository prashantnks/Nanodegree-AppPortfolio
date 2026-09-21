class Question {
  const Question({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.fingerprint,
    this.sourceSnippet = '',
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String fingerprint;
  final String sourceSnippet;

  String get correctAnswer => options[correctIndex];

  Question copyWithShuffledOptions(List<String> newOptions, int newCorrectIndex) {
    return Question(
      id: id,
      prompt: prompt,
      options: newOptions,
      correctIndex: newCorrectIndex,
      fingerprint: fingerprint,
      sourceSnippet: sourceSnippet,
    );
  }
}
