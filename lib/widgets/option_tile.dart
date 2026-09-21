import 'package:flutter/material.dart';
import 'package:quizforge/theme.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.optionText,
    required this.selected,
    required this.onTap,
    this.showResult = false,
    this.isCorrect = false,
  });

  final String label;
  final String optionText;
  final bool selected;
  final VoidCallback? onTap;
  final bool showResult;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    Color border = QuizForgeTheme.ink.withValues(alpha: 0.12);
    Color background = QuizForgeTheme.cream;
    Color badge = QuizForgeTheme.pine;

    if (showResult && isCorrect) {
      border = QuizForgeTheme.correct;
      background = const Color(0xFFE4F3EA);
      badge = QuizForgeTheme.correct;
    } else if (showResult && selected && !isCorrect) {
      border = QuizForgeTheme.wrong;
      background = const Color(0xFFF8E4E2);
      badge = QuizForgeTheme.wrong;
    } else if (selected) {
      border = QuizForgeTheme.pine;
      background = const Color(0xFFE7F3EC);
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: selected || showResult ? 1.8 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: badge,
                foregroundColor: Colors.white,
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  optionText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.35,
                    color: QuizForgeTheme.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showResult && isCorrect)
                const Icon(Icons.check_circle, color: QuizForgeTheme.correct)
              else if (showResult && selected)
                const Icon(Icons.cancel, color: QuizForgeTheme.wrong)
              else if (selected)
                const Icon(Icons.radio_button_checked, color: QuizForgeTheme.pine)
              else
                Icon(Icons.circle_outlined, color: QuizForgeTheme.ink.withValues(alpha: 0.25)),
            ],
          ),
        ),
      ),
    );
  }
}
