import 'dart:math';

import 'package:uuid/uuid.dart';

import '../models/question.dart';

class QuestionGenerator {
  QuestionGenerator({Random? random, Uuid? uuid})
    : _random = random ?? Random(),
      _uuid = uuid ?? const Uuid();

  final Random _random;
  final Uuid _uuid;

  static const int minContentChars = 80;
  static const int defaultOptionCount = 4;

  static const Set<String> _stopwords = {
    'a',
    'an',
    'the',
    'and',
    'or',
    'but',
    'if',
    'then',
    'so',
    'because',
    'as',
    'of',
    'in',
    'on',
    'at',
    'to',
    'for',
    'from',
    'by',
    'with',
    'about',
    'into',
    'through',
    'during',
    'before',
    'after',
    'above',
    'below',
    'between',
    'under',
    'again',
    'further',
    'once',
    'here',
    'there',
    'when',
    'where',
    'why',
    'how',
    'all',
    'each',
    'every',
    'both',
    'few',
    'more',
    'most',
    'other',
    'some',
    'such',
    'no',
    'nor',
    'not',
    'only',
    'own',
    'same',
    'than',
    'too',
    'very',
    'can',
    'will',
    'just',
    'should',
    'now',
    'also',
    'is',
    'are',
    'was',
    'were',
    'be',
    'been',
    'being',
    'have',
    'has',
    'had',
    'do',
    'does',
    'did',
    'this',
    'that',
    'these',
    'those',
    'it',
    'its',
    'they',
    'them',
    'their',
    'we',
    'our',
    'you',
    'your',
    'he',
    'she',
    'his',
    'her',
    'which',
    'who',
    'whom',
    'what',
    'while',
    'until',
    'over',
    'using',
    'used',
    'use',
    'mainly',
    'often',
    'called',
    'known',
    'named',
  };

  List<Question> generate({
    required String content,
    required int count,
    int optionsPerQuestion = defaultOptionCount,
    Set<String> excludeFingerprints = const {},
  }) {
    if (content.trim().length < minContentChars) {
      return const [];
    }

    final sentences = splitSentences(content);
    if (sentences.length < 2) {
      return const [];
    }

    final glossary = _buildGlossary(sentences);
    final pool = <Question>[];
    final seen = <String>{...excludeFingerprints};

    for (final sentence in sentences) {
      for (final candidate in _candidatesForSentence(
        sentence: sentence,
        glossary: glossary,
        optionCount: optionsPerQuestion,
      )) {
        if (seen.contains(candidate.fingerprint)) {
          continue;
        }
        seen.add(candidate.fingerprint);
        pool.add(_shuffleOptions(candidate));
      }
    }

    pool.shuffle(_random);
    if (pool.length <= count) {
      return pool;
    }
    return pool.take(count).toList(growable: false);
  }

  static List<String> splitSentences(String content) {
    final normalized = content
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAllMapped(RegExp(r'\s+([.!?])'), (match) => match.group(1)!)
        .trim();
    if (normalized.isEmpty) {
      return const [];
    }

    return normalized
        .split(RegExp(r'(?<=[.!?])\s+(?=[A-Z0-9])'))
        .map((sentence) => sentence.trim())
        .where((sentence) => sentence.length >= 24)
        .toList(growable: false);
  }

  static String fingerprintFor(String sourceSentence, String answer) {
    final normalizedSource = sourceSentence
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2)
        .take(12)
        .join(' ');
    final normalizedAnswer = answer.toLowerCase().trim();
    return '$normalizedSource|$normalizedAnswer';
  }

  List<String> _buildGlossary(List<String> sentences) {
    final terms = <String>{};
    for (final sentence in sentences) {
      terms.addAll(_extractKeyPhrases(sentence, includeLeading: true));
      final definition = _matchDefinition(sentence);
      if (definition != null) {
        terms.add(definition.term);
      }
    }
    return terms
        .where((term) => term.trim().length >= 3)
        .toList(growable: false);
  }

  Iterable<Question> _candidatesForSentence({
    required String sentence,
    required List<String> glossary,
    required int optionCount,
  }) sync* {
    final definition = _matchDefinition(sentence);
    if (definition != null) {
      final definitionQuestion = _buildQuestion(
        prompt: 'What is ${definition.term}?',
        answer: _truncate(definition.meaning, 90),
        distractorPool: glossary
            .where((term) => !_equalsIgnoreCase(term, definition.term))
            .map(_meaningForTerm)
            .whereType<String>()
            .toList(),
        extraDistractors: glossary
            .where((term) => !_equalsIgnoreCase(term, definition.term))
            .toList(),
        optionCount: optionCount,
        source: sentence,
        answerForFingerprint: definition.term,
      );
      if (definitionQuestion != null) {
        yield definitionQuestion;
      }
    }

    final location = _matchLocation(sentence);
    if (location != null) {
      final whereQuestion = _buildQuestion(
        prompt: 'Where does ${location.subject} occur or take place?',
        answer: location.place,
        distractorPool: glossary
            .where((term) => !_equalsIgnoreCase(term, location.place))
            .toList(),
        optionCount: optionCount,
        source: sentence,
        answerForFingerprint: location.place,
      );
      if (whereQuestion != null) {
        yield whereQuestion;
      }
    }

    final numeric = _firstMatch(
      sentence,
      RegExp(
        r'\b(\d+(?:\.\d+)?%?|\d{4})\b',
      ),
    );
    if (numeric != null) {
      final cloze = sentence.replaceFirst(numeric, '_____');
      if (cloze != sentence) {
        final numericQuestion = _buildQuestion(
          prompt: cloze.endsWith('.') ? cloze : '$cloze.',
          answer: numeric,
          distractorPool: _numericDistractors(numeric, glossary),
          optionCount: optionCount,
          source: sentence,
          answerForFingerprint: numeric,
        );
        if (numericQuestion != null) {
          yield numericQuestion;
        }
      }
    }

    final phrases = _extractKeyPhrases(sentence, includeLeading: false);
    phrases.sort((a, b) => b.length.compareTo(a.length));
    for (final phrase in phrases.take(2)) {
      if (phrase.length < 4) {
        continue;
      }
      final cloze = _replaceOnce(sentence, phrase, '_____');
      if (cloze == sentence) {
        continue;
      }
      final clozeQuestion = _buildQuestion(
        prompt: cloze.endsWith('.') ? cloze : '$cloze.',
        answer: phrase,
        distractorPool: glossary
            .where((term) => !_equalsIgnoreCase(term, phrase))
            .toList(),
        optionCount: optionCount,
        source: sentence,
        answerForFingerprint: phrase,
      );
      if (clozeQuestion != null) {
        yield clozeQuestion;
      }
    }
  }

  Question? _buildQuestion({
    required String prompt,
    required String answer,
    required List<String> distractorPool,
    List<String> extraDistractors = const [],
    required int optionCount,
    required String source,
    required String answerForFingerprint,
  }) {
    final uniqueDistractors = <String>[];
    for (final candidate in [...distractorPool, ...extraDistractors]) {
      final cleaned = candidate.trim();
      if (cleaned.isEmpty || _equalsIgnoreCase(cleaned, answer)) {
        continue;
      }
      if (uniqueDistractors.any((item) => _equalsIgnoreCase(item, cleaned))) {
        continue;
      }
      uniqueDistractors.add(_truncate(cleaned, 90));
    }

    uniqueDistractors.shuffle(_random);
    final needed = optionCount - 1;
    if (uniqueDistractors.length < needed) {
      return null;
    }

    final options = [
      _truncate(answer, 90),
      ...uniqueDistractors.take(needed),
    ];

    return Question(
      id: _uuid.v4(),
      prompt: prompt.trim(),
      options: options,
      correctIndex: 0,
      fingerprint: fingerprintFor(source, answerForFingerprint),
      sourceSnippet: source,
    );
  }

  Question _shuffleOptions(Question question) {
    final indexed = [
      for (var i = 0; i < question.options.length; i++)
        (option: question.options[i], isCorrect: i == question.correctIndex),
    ]..shuffle(_random);
    return question.copyWithShuffledOptions(
      [for (final item in indexed) item.option],
      indexed.indexWhere((item) => item.isCorrect),
    );
  }

  _Definition? _matchDefinition(String sentence) {
    final match = RegExp(
      r'^(.{3,70}?) (?:is|are|was|were) (?:a |an |the )?(.{8,140}?)(?:[.!?])?$',
      caseSensitive: false,
    ).firstMatch(sentence);
    if (match == null) {
      return null;
    }
    final term = match.group(1)!.trim();
    final meaning = match.group(2)!.trim();
    if (_stopwords.contains(term.toLowerCase()) ||
        RegExp(r'^(it|this|that|they|these|those)$', caseSensitive: false).hasMatch(term) ||
        meaning.split(' ').length < 3) {
      return null;
    }
    return _Definition(term: _stripLeadingArticles(term), meaning: meaning);
  }

  _Location? _matchLocation(String sentence) {
    final match = RegExp(
      r'(.{3,70}?) (?:occurs?|takes? place|happens?) (?:in|at|inside|within) (.{3,80}?)(?:[.!?])?$',
      caseSensitive: false,
    ).firstMatch(sentence);
    if (match == null) {
      return null;
    }
    final subject = _stripLeadingArticles(match.group(1)!.trim());
    if (RegExp(r'^(it|this|that|they)$', caseSensitive: false).hasMatch(subject)) {
      return null;
    }
    return _Location(
      subject: subject,
      place: match.group(2)!.trim(),
    );
  }

  List<String> _extractKeyPhrases(String sentence, {required bool includeLeading}) {
    final phrases = <String>{};
    final quoted = RegExp(r'"([^"]{3,60})"').allMatches(sentence);
    for (final match in quoted) {
      phrases.add(match.group(1)!.trim());
    }

    final words = sentence
        .replaceAll(RegExp(r'[^A-Za-z0-9%\-\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    var index = includeLeading ? 0 : 1;
    while (index < words.length) {
      if (_isProperStart(words[index])) {
        final buffer = <String>[words[index]];
        var cursor = index + 1;
        while (cursor < words.length && _isProperContinuation(words[cursor])) {
          buffer.add(words[cursor]);
          cursor++;
        }
        if (buffer.length >= 2 ||
            (buffer.length == 1 &&
                buffer.first.length >= 5 &&
                !_stopwords.contains(buffer.first.toLowerCase()))) {
          phrases.add(buffer.join(' '));
        }
        index = cursor;
        continue;
      }
      index++;
    }

    for (final word in words) {
      if (RegExp(r'^\d+(?:\.\d+)?%?$').hasMatch(word) ||
          (word.length >= 6 &&
              !_stopwords.contains(word.toLowerCase()) &&
              !word.contains('-') &&
              word == word.toLowerCase())) {
        phrases.add(word);
      }
    }

    return phrases.toList();
  }

  bool _isProperStart(String word) {
    return RegExp(r'^[A-Z][A-Za-z0-9\-]+$').hasMatch(word) &&
        !_stopwords.contains(word.toLowerCase());
  }

  bool _isProperContinuation(String word) {
    return RegExp(r'^[A-Z][A-Za-z0-9\-]+$').hasMatch(word) ||
        {'of', 'the', 'and'}.contains(word.toLowerCase());
  }

  List<String> _numericDistractors(String answer, List<String> glossary) {
    final numbers = glossary
        .where((term) => RegExp(r'\d').hasMatch(term) && term != answer)
        .toList();
    if (numbers.length >= 3) {
      return numbers;
    }

    final parsed = num.tryParse(answer.replaceAll('%', ''));
    if (parsed == null) {
      return numbers;
    }
    final generated = <String>{
      ...numbers,
      _formatNumber(parsed + 1, answer),
      _formatNumber(parsed + 5, answer),
      _formatNumber((parsed - 2).abs() + 1, answer),
      _formatNumber(parsed * 2, answer),
    }..remove(answer);
    return generated.toList();
  }

  String _formatNumber(num value, String template) {
    final isInt = template.contains('%') || value == value.roundToDouble();
    final raw = isInt ? value.round().toString() : value.toString();
    return template.contains('%') ? '$raw%' : raw;
  }

  String? _meaningForTerm(String term) {
    if (term.split(' ').length >= 4) {
      return term;
    }
    return null;
  }

  String _replaceOnce(String source, String target, String replacement) {
    final index = source.toLowerCase().indexOf(target.toLowerCase());
    if (index < 0) {
      return source;
    }
    return source.replaceRange(index, index + target.length, replacement);
  }

  String _stripLeadingArticles(String value) {
    return value.replaceFirst(RegExp(r'^(the|a|an)\s+', caseSensitive: false), '');
  }

  String _truncate(String value, int max) {
    if (value.length <= max) {
      return value;
    }
    return '${value.substring(0, max).trimRight()}…';
  }

  String? _firstMatch(String source, RegExp pattern) {
    return pattern.firstMatch(source)?.group(0);
  }

  bool _equalsIgnoreCase(String a, String b) => a.toLowerCase() == b.toLowerCase();
}

class _Definition {
  const _Definition({required this.term, required this.meaning});

  final String term;
  final String meaning;
}

class _Location {
  const _Location({required this.subject, required this.place});

  final String subject;
  final String place;
}
