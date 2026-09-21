class QuizAttempt {
  const QuizAttempt({
    required this.setId,
    required this.selectedIndexes,
    required this.submittedAt,
    required this.correctCount,
    required this.totalCount,
  });

  final String setId;
  final Map<String, int> selectedIndexes;
  final DateTime submittedAt;
  final int correctCount;
  final int totalCount;

  double get scorePercent =>
      totalCount == 0 ? 0 : (correctCount / totalCount) * 100;
}
