import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/question.dart';
import 'question_generator.dart';

class RemoteQuestionGenerator {
  RemoteQuestionGenerator({
    http.Client? client,
    this.endpoint = 'https://api.openai.com/v1/chat/completions',
    this.model = 'gpt-4o-mini',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String endpoint;
  final String model;
  final _uuid = const Uuid();

  Future<List<Question>> generate({
    required String apiKey,
    required String content,
    required int count,
    required Set<String> excludeFingerprints,
    bool allowOverlap = true,
  }) async {
    final overlapRule = allowOverlap
        ? 'Questions may cover similar facts.'
        : 'Do not repeat any previously used question fingerprints: ${excludeFingerprints.join(', ')}';

    final response = await _client.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'temperature': 0.4,
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content':
                'You generate objective multiple-choice questions from study content. '
                'Return JSON: {"questions":[{"prompt":"...","options":["A","B","C","D"],"correctIndex":0,"sourceSnippet":"..."}]}. '
                'Each question must have exactly 4 options and one correctIndex. '
                'Base every question only on the provided content.',
          },
          {
            'role': 'user',
            'content':
                'Create $count objective questions.\n$overlapRule\n\nCONTENT:\n$content',
          },
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AI request failed (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final contentText =
        (decoded['choices'] as List).first['message']['content'] as String;
    final parsed = jsonDecode(contentText) as Map<String, dynamic>;
    final items = (parsed['questions'] as List).cast<dynamic>();

    final questions = <Question>[];
    for (final item in items.take(count)) {
      final map = item as Map<String, dynamic>;
      final options = (map['options'] as List).map((e) => e.toString()).toList();
      if (options.length < 2) {
        continue;
      }
      final correctIndex = (map['correctIndex'] as num).toInt();
      if (correctIndex < 0 || correctIndex >= options.length) {
        continue;
      }
      final prompt = map['prompt'].toString();
      final snippet = (map['sourceSnippet'] ?? '').toString();
      final fingerprint = QuestionGenerator.fingerprintFor(
        snippet.isEmpty ? prompt : snippet,
        options[correctIndex],
      );
      if (!allowOverlap && excludeFingerprints.contains(fingerprint)) {
        continue;
      }
      questions.add(
        Question(
          id: _uuid.v4(),
          prompt: prompt,
          options: options,
          correctIndex: correctIndex,
          fingerprint: fingerprint,
          sourceSnippet: snippet,
        ),
      );
    }
    return questions;
  }
}
