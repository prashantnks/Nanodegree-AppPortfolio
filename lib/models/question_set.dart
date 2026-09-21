import 'question.dart';

class QuestionSet {
  const QuestionSet({
    required this.id,
    required this.title,
    required this.questions,
    required this.createdAt,
    required this.allowOverlap,
    required this.usedRemoteAi,
  });

  final String id;
  final String title;
  final List<Question> questions;
  final DateTime createdAt;
  final bool allowOverlap;
  final bool usedRemoteAi;

  int get length => questions.length;

  Set<String> get fingerprints =>
      questions.map((question) => question.fingerprint).toSet();
}
