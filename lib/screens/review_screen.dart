import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizforge/models/question.dart';
import 'package:quizforge/state/quiz_controller.dart';
import 'package:quizforge/theme.dart';
import 'package:quizforge/widgets/layout.dart';
import 'package:quizforge/widgets/option_tile.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuizController>();
    final set = controller.activeSet;
    final attempt = controller.lastAttempt;

    if (set == null || attempt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(child: Text('Submit a quiz to see the review.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Review answers')),
      body: AppScaffold(
        child: ListView(
          children: [
            SoftCard(
              color: QuizForgeTheme.pine,
              child: Row(
                children: [
                  _ScoreRing(
                    correct: attempt.correctCount,
                    total: attempt.totalCount,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${attempt.correctCount} of ${attempt.totalCount} correct',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Selected answers are shown beside the correct answers for every question.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < set.questions.length; i++) ...[
              _ReviewCard(
                number: i + 1,
                question: set.questions[i],
                selectedIndex: attempt.selectedIndexes[set.questions[i].id],
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                controller.startQuiz(set);
                Navigator.of(context).pushReplacementNamed('/quiz');
              },
              child: const Text('Retake this set'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/generate', ModalRoute.withName('/')),
              child: const Text('Generate another set'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.number,
    required this.question,
    required this.selectedIndex,
  });

  final int number;
  final Question question;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final correct = selectedIndex == question.correctIndex;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Question $number', style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              Text(
                correct ? 'Correct' : 'Incorrect',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: correct ? QuizForgeTheme.correct : QuizForgeTheme.wrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          for (var i = 0; i < question.options.length; i++) ...[
            OptionTile(
              label: String.fromCharCode(65 + i),
              optionText: question.options[i],
              selected: selectedIndex == i,
              isCorrect: i == question.correctIndex,
              showResult: true,
              onTap: null,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          _AnswerLine(
            label: 'Your answer',
            value: selectedIndex == null
                ? 'Not answered'
                : '${String.fromCharCode(65 + selectedIndex!)}. ${question.options[selectedIndex!]}',
            color: correct ? QuizForgeTheme.correct : QuizForgeTheme.wrong,
          ),
          const SizedBox(height: 6),
          _AnswerLine(
            label: 'Correct answer',
            value: '${String.fromCharCode(65 + question.correctIndex)}. ${question.correctAnswer}',
            color: QuizForgeTheme.correct,
          ),
          if (question.sourceSnippet.toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'From the notes: ${question.sourceSnippet}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: QuizForgeTheme.ink.withValues(alpha: 0.62),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: QuizForgeTheme.ink),
        children: [
          TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.correct, required this.total});

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : correct / total;
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 8,
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.24),
          ),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
