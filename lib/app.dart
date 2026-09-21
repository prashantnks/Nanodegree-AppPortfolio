import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizforge/screens/generate_screen.dart';
import 'package:quizforge/screens/home_screen.dart';
import 'package:quizforge/screens/quiz_screen.dart';
import 'package:quizforge/screens/review_screen.dart';
import 'package:quizforge/screens/settings_screen.dart';
import 'package:quizforge/screens/upload_screen.dart';
import 'package:quizforge/state/quiz_controller.dart';
import 'package:quizforge/theme.dart';

class QuizForgeApp extends StatelessWidget {
  const QuizForgeApp({super.key, this.controller});

  final QuizController? controller;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'QuizForge',
      debugShowCheckedModeBanner: false,
      theme: QuizForgeTheme.light(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/upload': (_) => const UploadScreen(),
        '/generate': (_) => const GenerateScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/review': (_) => const ReviewScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );

    if (controller != null) {
      return ChangeNotifierProvider<QuizController>.value(
        value: controller!,
        child: app,
      );
    }

    return ChangeNotifierProvider(
      create: (_) {
        final quizController = QuizController();
        quizController.loadSettings();
        return quizController;
      },
      child: app,
    );
  }
}
