import '../../../shared/models/pronunciation_result.dart';

/// Normalizes and compares expected vs recognized speech text.
class PronunciationComparator {
  const PronunciationComparator();

  /// Compare [expected] with [recognized] and return a full result.
  PronunciationResult compare({
    required String expected,
    required String recognized,
  }) {
    final normalizedExpected = _normalize(expected);
    final normalizedRecognized = _normalize(recognized);

    final expectedWords = _tokenize(normalizedExpected);
    final recognizedWords = _tokenize(normalizedRecognized);

    final score = _similarityScore(normalizedExpected, normalizedRecognized);
    final wordMatches = _alignWords(expectedWords, recognizedWords);

    final missingWords = <String>[];
    final extraWords = <String>[];
    final incorrectWords = <String>[];

    for (final match in wordMatches) {
      switch (match.status) {
        case WordMatchStatus.missing:
          if (match.expected != null) missingWords.add(match.expected!);
        case WordMatchStatus.extra:
          if (match.recognized != null) extraWords.add(match.recognized!);
        case WordMatchStatus.incorrect:
          if (match.expected != null) incorrectWords.add(match.expected!);
        case WordMatchStatus.correct:
          break;
      }
    }

    final rating = PronunciationRating.fromScore(score);

    return PronunciationResult(
      expectedText: expected,
      recognizedText: recognized,
      score: score,
      wordMatches: wordMatches,
      missingWords: missingWords,
      extraWords: extraWords,
      incorrectWords: incorrectWords,
      isCorrect: score >= 90,
      rating: rating,
    );
  }

  String _normalize(String input) {
    final lower = input.toLowerCase();
    final noPunctuation = lower.replaceAll(
      RegExp(r'[^\p{L}\p{N}\s]', unicode: true),
      ' ',
    );
    return noPunctuation.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String> _tokenize(String normalized) {
    if (normalized.isEmpty) return const [];
    return normalized.split(' ');
  }

  int _similarityScore(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 100;
    if (a.isEmpty || b.isEmpty) return 0;

    final distance = _levenshtein(a, b);
    final maxLen = a.length > b.length ? a.length : b.length;
    final similarity = (1 - distance / maxLen) * 100;
    return similarity.round().clamp(0, 100);
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final rows = a.length + 1;
    final cols = b.length + 1;
    final matrix = List.generate(rows, (_) => List<int>.filled(cols, 0));

    for (var i = 0; i < rows; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j < cols; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i < rows; i++) {
      for (var j = 1; j < cols; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = _min3(
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        );
      }
    }

    return matrix[a.length][b.length];
  }

  int _min3(int a, int b, int c) {
    if (a <= b && a <= c) return a;
    if (b <= a && b <= c) return b;
    return c;
  }

  List<WordMatch> _alignWords(List<String> expected, List<String> recognized) {
    if (expected.isEmpty && recognized.isEmpty) return const [];

    final rows = expected.length + 1;
    final cols = recognized.length + 1;
    final matrix = List.generate(rows, (_) => List<int>.filled(cols, 0));

    for (var i = 0; i < rows; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j < cols; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i < rows; i++) {
      for (var j = 1; j < cols; j++) {
        final cost = expected[i - 1] == recognized[j - 1] ? 0 : 1;
        matrix[i][j] = _min3(
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        );
      }
    }

    final aligned = <WordMatch>[];
    var i = expected.length;
    var j = recognized.length;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final cost = expected[i - 1] == recognized[j - 1] ? 0 : 1;
        if (matrix[i][j] == matrix[i - 1][j - 1] + cost) {
          if (cost == 0) {
            aligned.add(
              WordMatch(
                status: WordMatchStatus.correct,
                expected: expected[i - 1],
                recognized: recognized[j - 1],
              ),
            );
          } else {
            aligned.add(
              WordMatch(
                status: WordMatchStatus.incorrect,
                expected: expected[i - 1],
                recognized: recognized[j - 1],
              ),
            );
          }
          i--;
          j--;
          continue;
        }
      }

      if (i > 0 &&
          (j == 0 || matrix[i - 1][j] + 1 == matrix[i][j])) {
        aligned.add(
          WordMatch(
            status: WordMatchStatus.missing,
            expected: expected[i - 1],
          ),
        );
        i--;
        continue;
      }

      aligned.add(
        WordMatch(
          status: WordMatchStatus.extra,
          recognized: recognized[j - 1],
        ),
      );
      j--;
    }

    return aligned.reversed.toList();
  }
}
