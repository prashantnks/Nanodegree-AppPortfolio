import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizforge/state/quiz_controller.dart';
import 'package:quizforge/theme.dart';
import 'package:quizforge/widgets/layout.dart';
import 'package:quizforge/widgets/question_set_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuizController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizForge'),
        actions: [
          IconButton(
            tooltip: 'AI settings',
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: AppScaffold(
        child: ListView(
          children: [
            SoftCard(
              color: QuizForgeTheme.pine,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Turn any notes into a quiz.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload study content, generate objective questions with AI, attempt a set, then review your answers against the correct ones. No account needed.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: QuizForgeTheme.clay,
                    ),
                    onPressed: () => Navigator.of(context).pushNamed('/upload'),
                    child: Text(controller.hasContent ? 'Replace content' : 'Upload study content'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionLabel('How it works'),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StepChip(number: '1', label: 'Upload or paste notes'),
                _StepChip(number: '2', label: 'Generate a question set'),
                _StepChip(number: '3', label: 'Answer every question'),
                _StepChip(number: '4', label: 'Review selected vs correct'),
              ],
            ),
            if (controller.hasContent) ...[
              const SizedBox(height: 32),
              const SectionLabel('Current content'),
              const SizedBox(height: 12),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.contentTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      controller.contentBody,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/generate'),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(controller.hasSets ? 'Generate another set' : 'Generate questions'),
                    ),
                  ],
                ),
              ),
            ],
            if (controller.hasSets) ...[
              const SizedBox(height: 32),
              const SectionLabel('Question sets'),
              const SizedBox(height: 12),
              ...[
                for (var i = 0; i < controller.sets.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QuestionSetCard(
                      set: controller.sets[i],
                      index: i,
                      onPractice: () {
                        controller.startQuiz(controller.sets[i]);
                        Navigator.of(context).pushNamed('/quiz');
                      },
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: QuizForgeTheme.cream,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: QuizForgeTheme.ink.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: QuizForgeTheme.pine,
            foregroundColor: Colors.white,
            child: Text(number, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
