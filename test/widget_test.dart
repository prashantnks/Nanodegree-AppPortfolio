import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizforge/app.dart';
import 'package:quizforge/data/sample_content.dart';
import 'package:quizforge/services/question_generator.dart';
import 'package:quizforge/state/quiz_controller.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> prepareSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('home explains the no-login quiz flow', (tester) async {
    await prepareSurface(tester);
    await tester.pumpWidget(const QuizForgeApp());
    expect(find.text('QuizForge'), findsWidgets);
    expect(find.text('Upload study content'), findsOneWidget);
    expect(find.textContaining('No account needed'), findsOneWidget);
  });

  testWidgets('user can paste content, take a quiz, and review answers', (tester) async {
    await prepareSurface(tester);
    final controller = QuizController(
      generator: QuestionGenerator(random: Random(3)),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(QuizForgeApp(controller: controller));

    await tester.tap(find.text('Upload study content'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('content_body_field')), samplePhotosynthesis.body);
    await tester.ensureVisible(find.byKey(const Key('continue_upload_button')));
    await tester.tap(find.byKey(const Key('continue_upload_button')));
    await tester.pumpAndSettle();

    expect(find.text('Generate questions'), findsWidgets);
    await tester.tap(find.byKey(const Key('generate_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('option_0')), findsOneWidget);

    final set = controller.activeSet!;
    for (var i = 0; i < set.questions.length; i++) {
      final question = set.questions[i];
      await tester.tap(find.byKey(Key('option_${question.correctIndex}')));
      await tester.pump();
      if (i < set.questions.length - 1) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
    }

    await tester.tap(find.byKey(const Key('submit_quiz')));
    await tester.pumpAndSettle();

    expect(find.text('Review answers'), findsOneWidget);
    expect(find.text('${set.length} of ${set.length} correct'), findsOneWidget);
    expect(find.textContaining('Correct answer'), findsWidgets);
    expect(find.textContaining('Your answer'), findsWidgets);
  });

  testWidgets('submit stays disabled until every question is answered', (tester) async {
    await prepareSurface(tester);
    final controller = QuizController(
      generator: QuestionGenerator(random: Random(5)),
    );
    controller.setContent(
      title: samplePhotosynthesis.title,
      body: samplePhotosynthesis.body,
    );
    await controller.generateSet(questionCount: 3, allowOverlap: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(QuizForgeApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Practice this set'), 400);
    await tester.tap(find.text('Practice this set'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    final submit = tester.widget<FilledButton>(find.byKey(const Key('submit_quiz')));
    expect(submit.onPressed, isNull);
    expect(find.text('Answer every question to enable Submit.'), findsOneWidget);
  });
}
