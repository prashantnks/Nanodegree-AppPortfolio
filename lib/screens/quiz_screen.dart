import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizforge/models/generation_result.dart';
import 'package:quizforge/state/quiz_controller.dart';
import 'package:quizforge/theme.dart';
import 'package:quizforge/widgets/layout.dart';
import 'package:quizforge/widgets/option_tile.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;

  void _submit() {
    final controller = context.read<QuizController>();
    try {
      controller.submit();
      Navigator.of(context).pushReplacementNamed('/review');
    } on GenerationException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuizController>();
    final set = controller.activeSet;

    if (set == null || set.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Generate a question set first.')),
      );
    }

    final question = set.questions[_index];
    final selected = controller.selections[question.id];
    final progress = controller.answeredCount / set.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(set.title),
      ),
      body: AppScaffold(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
              color: QuizForgeTheme.pine,
              backgroundColor: QuizForgeTheme.ink.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Question ${_index + 1} of ${set.length}  ·  ${controller.answeredCount} answered',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  SoftCard(
                    child: Text(
                      question.prompt,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.25),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < question.options.length; i++) ...[
                    OptionTile(
                      key: Key('option_$i'),
                      label: String.fromCharCode(65 + i),
                      optionText: question.options[i],
                      selected: selected == i,
                      onTap: () => controller.selectAnswer(question.id, i),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _index == 0 ? null : () => setState(() => _index--),
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 10),
                if (_index < set.length - 1)
                  Expanded(
                    child: FilledButton(
                      onPressed: () => setState(() => _index++),
                      child: const Text('Next'),
                    ),
                  )
                else
                  Expanded(
                    child: FilledButton(
                      key: const Key('submit_quiz'),
                      onPressed: controller.allQuestionsAnswered ? _submit : null,
                      child: const Text('Submit'),
                    ),
                  ),
              ],
            ),
            if (!controller.allQuestionsAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Answer every question to enable Submit.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: QuizForgeTheme.ink.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
