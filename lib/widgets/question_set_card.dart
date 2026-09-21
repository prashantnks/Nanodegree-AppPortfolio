import 'package:flutter/material.dart';
import 'package:quizforge/models/question_set.dart';
import 'package:quizforge/theme.dart';
import 'package:quizforge/widgets/layout.dart';

class QuestionSetCard extends StatelessWidget {
  const QuestionSetCard({
    super.key,
    required this.set,
    required this.index,
    required this.onPractice,
  });

  final QuestionSet set;
  final int index;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: QuizForgeTheme.pine,
                foregroundColor: Colors.white,
                child: Text('${index + 1}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(set.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${set.length} questions · ${set.allowOverlap ? 'overlap allowed' : 'no overlap'} · ${set.usedRemoteAi ? 'cloud AI' : 'on-device AI'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: QuizForgeTheme.ink.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onPractice,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Practice this set'),
          ),
        ],
      ),
    );
  }
}
