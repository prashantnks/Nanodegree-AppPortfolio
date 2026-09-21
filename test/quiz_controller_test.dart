import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/data/sample_content.dart';
import 'package:quizforge/models/generation_result.dart';
import 'package:quizforge/services/question_generator.dart';
import 'package:quizforge/state/quiz_controller.dart';

void main() {
  late QuizController controller;

  setUp(() {
    controller = QuizController(
      generator: QuestionGenerator(random: Random(11)),
    );
    controller.setContent(
      title: samplePhotosynthesis.title,
      body: samplePhotosynthesis.body,
    );
  });

  tearDown(() => controller.dispose());

  test('submit is blocked until every question is answered', () async {
    await controller.generateSet(questionCount: 4, allowOverlap: false);
    expect(controller.allQuestionsAnswered, isFalse);
    expect(() => controller.submit(), throwsA(isA<GenerationException>()));

    for (final question in controller.activeSet!.questions) {
      controller.selectAnswer(question.id, 0);
    }
    expect(controller.allQuestionsAnswered, isTrue);

    final attempt = controller.submit();
    expect(attempt.totalCount, 4);
    expect(attempt.correctCount, inInclusiveRange(0, 4));
  });

  test('review data includes selected and correct answers', () async {
    await controller.generateSet(questionCount: 3, allowOverlap: false);
    final questions = controller.activeSet!.questions;
    controller.selectAnswer(questions[0].id, questions[0].correctIndex);
    controller.selectAnswer(questions[1].id, (questions[1].correctIndex + 1) % 4);
    controller.selectAnswer(questions[2].id, questions[2].correctIndex);

    final attempt = controller.submit();
    expect(attempt.correctCount, 2);
    expect(attempt.selectedIndexes[questions[1].id], isNot(questions[1].correctIndex));
  });

  test('second set can be generated without overlapping questions', () async {
    final first = await controller.generateSet(questionCount: 5, allowOverlap: false);
    final second = await controller.generateSet(questionCount: 5, allowOverlap: false);

    expect(controller.sets, hasLength(2));
    expect(
      second.questionSet.fingerprints.intersection(first.questionSet.fingerprints),
      isEmpty,
    );
  });
}
