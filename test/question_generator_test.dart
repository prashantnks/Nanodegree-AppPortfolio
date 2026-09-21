import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/data/sample_content.dart';
import 'package:quizforge/services/question_generator.dart';

void main() {
  late QuestionGenerator generator;

  setUp(() {
    generator = QuestionGenerator(random: Random(7));
  });

  test('splits content into sentences', () {
    final sentences = QuestionGenerator.splitSentences(samplePhotosynthesis.body);
    expect(sentences.length, greaterThanOrEqualTo(8));
    expect(sentences.first, contains('Photosynthesis'));
  });

  test('creates multiple-choice questions from study content', () {
    final questions = generator.generate(
      content: samplePhotosynthesis.body,
      count: 8,
    );

    expect(questions.length, greaterThanOrEqualTo(6));
    for (final question in questions) {
      expect(question.options, hasLength(4));
      expect(question.options.toSet(), hasLength(4));
      expect(question.correctIndex, inInclusiveRange(0, 3));
      expect(question.prompt, isNotEmpty);
      expect(question.correctAnswer, isNotEmpty);
    }
  });

  test('avoids excluded fingerprints when overlap is not allowed', () {
    final first = generator.generate(
      content: samplePhotosynthesis.body,
      count: 6,
    );
    expect(first, isNotEmpty);

    final excluded = first.map((question) => question.fingerprint).toSet();
    final second = generator.generate(
      content: samplePhotosynthesis.body,
      count: 6,
      excludeFingerprints: excluded,
    );

    expect(second, isNotEmpty);
    expect(
      second.map((question) => question.fingerprint).toSet().intersection(excluded),
      isEmpty,
    );
  });

  test('can reuse questions when overlap is allowed', () {
    final first = generator.generate(
      content: samplePhotosynthesis.body,
      count: 4,
    );
    final overlapping = generator.generate(
      content: samplePhotosynthesis.body,
      count: 20,
    );

    final reused = overlapping
        .map((question) => question.fingerprint)
        .toSet()
        .intersection(first.map((question) => question.fingerprint).toSet());
    expect(reused, isNotEmpty);
  });

  test('returns no questions for tiny content', () {
    expect(
      generator.generate(content: 'Too short.', count: 5),
      isEmpty,
    );
  });
}
