import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizforge/state/quiz_controller.dart';
import 'package:quizforge/widgets/layout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: context.read<QuizController>().apiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI settings')),
      body: AppScaffold(
        child: ListView(
          children: [
            const SectionLabel('Optional cloud AI'),
            const SizedBox(height: 8),
            const Text(
              'QuizForge generates objective questions on-device by default, so you can use the app without logging in. Paste an OpenAI API key if you want cloud-generated questions instead.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'OpenAI API key',
                hintText: 'sk-…',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await context.read<QuizController>().saveApiKey(_apiKeyController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved. The key stays on this device.')),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save key'),
            ),
          ],
        ),
      ),
    );
  }
}
