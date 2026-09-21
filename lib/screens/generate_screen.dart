import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizforge/models/generation_result.dart';
import 'package:quizforge/state/quiz_controller.dart';
import 'package:quizforge/theme.dart';
import 'package:quizforge/widgets/layout.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  double _questionCount = 6;
  bool _allowOverlap = false;
  String? _message;

  Future<void> _generate() async {
    final controller = context.read<QuizController>();
    setState(() => _message = null);
    try {
      final result = await controller.generateSet(
        questionCount: _questionCount.round(),
        allowOverlap: controller.hasSets && _allowOverlap,
      );
      if (!mounted) {
        return;
      }
      final warning = [
        if (result.warning != null) result.warning!,
        if (controller.lastError != null) controller.lastError!,
      ].join('\n');
      if (warning.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(warning)));
      }
      Navigator.of(context).pushNamed('/quiz');
    } on GenerationException catch (error) {
      setState(() => _message = error.message);
    } catch (error) {
      setState(() => _message = 'Could not generate questions. $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuizController>();
    final previousSets = controller.sets.length;
    final overlapEnabled = previousSets > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Generate questions')),
      body: AppScaffold(
        child: ListView(
          children: [
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.contentTitle, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    controller.contentBody,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionLabel('Question set'),
            const SizedBox(height: 12),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_questionCount.round()} questions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    key: const Key('question_count_slider'),
                    min: 3,
                    max: 12,
                    divisions: 9,
                    value: _questionCount,
                    label: '${_questionCount.round()}',
                    onChanged: controller.isGenerating
                        ? null
                        : (value) => setState(() => _questionCount = value),
                  ),
                  SwitchListTile(
                    key: const Key('allow_overlap_switch'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Allow overlapping questions'),
                    subtitle: Text(
                      overlapEnabled
                          ? 'When off, new sets avoid questions already used in previous sets.'
                          : 'This is the first set, so every question is new.',
                    ),
                    value: overlapEnabled && _allowOverlap,
                    onChanged: !overlapEnabled || controller.isGenerating
                        ? null
                        : (value) => setState(() => _allowOverlap = value),
                  ),
                  if (controller.apiKey.isNotEmpty)
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.cloud_done_outlined, color: QuizForgeTheme.pine),
                      title: Text('Cloud AI key is saved'),
                      subtitle: Text('QuizForge will try the OpenAI API, then fall back on-device.'),
                    )
                  else
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.psychology_alt_outlined, color: QuizForgeTheme.pine),
                      title: Text('On-device AI generator'),
                      subtitle: Text('No login required. Add an optional API key in settings for cloud AI.'),
                    ),
                ],
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                style: const TextStyle(color: QuizForgeTheme.wrong, fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton.icon(
            key: const Key('generate_button'),
            onPressed: controller.isGenerating ? null : _generate,
            icon: controller.isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(controller.isGenerating ? 'Generating…' : 'Generate question set'),
          ),
        ),
      ),
    );
  }
}
