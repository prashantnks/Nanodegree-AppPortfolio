import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizforge/data/sample_content.dart';
import 'package:quizforge/services/content_loader.dart';
import 'package:quizforge/state/quiz_controller.dart';
import 'package:quizforge/theme.dart';
import 'package:quizforge/widgets/layout.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, this.loader = const ContentLoader()});

  final ContentLoader loader;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  String? _error;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    final controller = context.read<QuizController>();
    _titleController = TextEditingController(text: controller.contentTitle);
    _bodyController = TextEditingController(text: controller.contentBody);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final loaded = await widget.loader.pickTextFile();
      if (loaded == null || !mounted) {
        return;
      }
      _titleController.text = loaded.title;
      _bodyController.text = loaded.body;
    } catch (error) {
      setState(() => _error = 'Could not read that file. Try a .txt or .md file.');
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  void _useSample(SampleLesson lesson) {
    _titleController.text = lesson.title;
    _bodyController.text = lesson.body.trim();
    setState(() => _error = null);
  }

  void _continue() {
    final body = _bodyController.text.trim();
    if (body.length < 80) {
      setState(() => _error = 'Please add a longer passage so QuizForge can create useful questions.');
      return;
    }
    context.read<QuizController>().setContent(
      title: _titleController.text,
      body: body,
    );
    Navigator.of(context).pushReplacementNamed('/generate');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload content')),
      body: AppScaffold(
        child: ListView(
          children: [
            const SectionLabel('Study material'),
            const SizedBox(height: 8),
            Text(
              'Paste notes, upload a text file, or start from a sample lesson. QuizForge works without an account.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Chapter 4 — Photosynthesis',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('content_body_field'),
              controller: _bodyController,
              minLines: 10,
              maxLines: 18,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Content',
                hintText: 'Paste the passage you want to be quizzed on…',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _picking ? null : _pickFile,
                  icon: _picking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: const Text('Upload .txt or .md'),
                ),
                for (final lesson in sampleLessons)
                  OutlinedButton(
                    onPressed: () => _useSample(lesson),
                    child: Text('Use ${lesson.title} sample'),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: QuizForgeTheme.wrong, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            key: const Key('continue_upload_button'),
            onPressed: _continue,
            child: const Text('Continue to generate questions'),
          ),
        ),
      ),
    );
  }
}
