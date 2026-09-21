import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/generation_result.dart';
import '../models/question_set.dart';
import '../models/quiz_attempt.dart';
import '../services/question_generator.dart';
import '../services/remote_question_generator.dart';

class QuizController extends ChangeNotifier {
  QuizController({
    QuestionGenerator? generator,
    RemoteQuestionGenerator? remoteGenerator,
    Uuid? uuid,
    this.prefsLoader,
  }) : _generator = generator ?? QuestionGenerator(),
       _remoteGenerator = remoteGenerator ?? RemoteQuestionGenerator(),
       _uuid = uuid ?? const Uuid();

  static const _apiKeyPref = 'quizforge.openai_api_key';

  final QuestionGenerator _generator;
  final RemoteQuestionGenerator _remoteGenerator;
  final Uuid _uuid;
  final Future<SharedPreferences> Function()? prefsLoader;

  String contentTitle = '';
  String contentBody = '';
  String apiKey = '';
  bool isGenerating = false;
  String? lastError;

  final List<QuestionSet> sets = [];
  QuestionSet? activeSet;
  final Map<String, int> selections = {};
  QuizAttempt? lastAttempt;

  bool get hasContent => contentBody.trim().length >= QuestionGenerator.minContentChars;

  bool get hasSets => sets.isNotEmpty;

  bool get allQuestionsAnswered {
    final current = activeSet;
    if (current == null || current.questions.isEmpty) {
      return false;
    }
    return current.questions.every((question) => selections.containsKey(question.id));
  }

  int get answeredCount => selections.length;

  Set<String> get usedFingerprints => {
    for (final set in sets) ...set.fingerprints,
  };

  Future<void> loadSettings() async {
    try {
      final prefs = await (prefsLoader?.call() ?? SharedPreferences.getInstance());
      apiKey = prefs.getString(_apiKeyPref) ?? '';
      notifyListeners();
    } catch (_) {
      // Settings are optional in the MVP; keep working without persistence.
    }
  }

  Future<void> saveApiKey(String value) async {
    apiKey = value.trim();
    try {
      final prefs = await (prefsLoader?.call() ?? SharedPreferences.getInstance());
      await prefs.setString(_apiKeyPref, apiKey);
    } catch (_) {
      // Ignore persistence errors; the key still lives in memory for this session.
    }
    notifyListeners();
  }

  void setContent({required String title, required String body}) {
    contentTitle = title.trim().isEmpty ? 'Untitled notes' : title.trim();
    contentBody = body.trim();
    sets.clear();
    activeSet = null;
    selections.clear();
    lastAttempt = null;
    lastError = null;
    notifyListeners();
  }

  void startQuiz(QuestionSet set) {
    activeSet = set;
    selections.clear();
    lastAttempt = null;
    notifyListeners();
  }

  void selectAnswer(String questionId, int optionIndex) {
    selections[questionId] = optionIndex;
    notifyListeners();
  }

  QuizAttempt submit() {
    final current = activeSet;
    if (current == null) {
      throw const GenerationException('No active question set.');
    }
    if (!allQuestionsAnswered) {
      throw const GenerationException('Answer every question before submitting.');
    }

    var correct = 0;
    for (final question in current.questions) {
      if (selections[question.id] == question.correctIndex) {
        correct++;
      }
    }

    lastAttempt = QuizAttempt(
      setId: current.id,
      selectedIndexes: Map<String, int>.from(selections),
      submittedAt: DateTime.now(),
      correctCount: correct,
      totalCount: current.questions.length,
    );
    notifyListeners();
    return lastAttempt!;
  }

  Future<GenerationResult> generateSet({
    required int questionCount,
    required bool allowOverlap,
  }) async {
    if (!hasContent) {
      throw const GenerationException(
        'Add a longer study passage before generating questions.',
      );
    }

    isGenerating = true;
    lastError = null;
    notifyListeners();

    try {
      final excluded = allowOverlap ? <String>{} : usedFingerprints;
      var usedRemoteAi = false;
      var questions = _generator.generate(
        content: contentBody,
        count: questionCount,
        excludeFingerprints: excluded,
      );

      if (apiKey.isNotEmpty) {
        try {
          final remoteQuestions = await _remoteGenerator.generate(
            apiKey: apiKey,
            content: contentBody,
            count: questionCount,
            excludeFingerprints: excluded,
            allowOverlap: allowOverlap,
          );
          if (remoteQuestions.isNotEmpty) {
            questions = remoteQuestions;
            usedRemoteAi = true;
          }
        } catch (error) {
          lastError =
              'Cloud AI was unavailable, so QuizForge used the on-device generator. ($error)';
        }
      }

      if (questions.isEmpty) {
        throw const GenerationException(
          'Could not create unique questions from this content. Add more detail or allow overlapping questions.',
        );
      }

      String? warning;
      if (questions.length < questionCount) {
        warning =
            'Only ${questions.length} unique question${questions.length == 1 ? '' : 's'} could be created from this content.';
      }

      final nextIndex = sets.length + 1;
      final set = QuestionSet(
        id: _uuid.v4(),
        title: 'Set $nextIndex · $contentTitle',
        questions: questions,
        createdAt: DateTime.now(),
        allowOverlap: allowOverlap,
        usedRemoteAi: usedRemoteAi,
      );
      sets.add(set);
      startQuiz(set);

      return GenerationResult(
        questionSet: set,
        warning: warning,
        usedRemoteAi: usedRemoteAi,
      );
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }
}
