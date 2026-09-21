import 'question_set.dart';

class GenerationResult {
  const GenerationResult({
    required this.questionSet,
    this.warning,
    this.usedRemoteAi = false,
  });

  final QuestionSet questionSet;
  final String? warning;
  final bool usedRemoteAi;
}

class GenerationException implements Exception {
  const GenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}
