import 'package:equatable/equatable.dart';

/// How a single token aligned between expected and recognized speech.
enum WordMatchStatus {
  correct,
  incorrect,
  missing,
  extra,
}

/// One aligned word from pronunciation comparison.
class WordMatch extends Equatable {
  const WordMatch({
    required this.status,
    this.expected,
    this.recognized,
  });

  final WordMatchStatus status;
  final String? expected;
  final String? recognized;

  String get displayWord => expected ?? recognized ?? '';

  @override
  List<Object?> get props => [status, expected, recognized];
}

/// Overall rating bucket for pronunciation score.
enum PronunciationRating {
  excellent,
  good,
  needsPractice,
}

extension PronunciationRatingX on PronunciationRating {
  String get label {
    switch (this) {
      case PronunciationRating.excellent:
        return 'Excellent';
      case PronunciationRating.good:
        return 'Good';
      case PronunciationRating.needsPractice:
        return 'Needs Practice';
    }
  }

  static PronunciationRating fromScore(int score) {
    if (score >= 90) return PronunciationRating.excellent;
    if (score >= 75) return PronunciationRating.good;
    return PronunciationRating.needsPractice;
  }
}

/// Result of comparing expected lesson text with recognized speech.
class PronunciationResult extends Equatable {
  const PronunciationResult({
    required this.expectedText,
    required this.recognizedText,
    required this.score,
    required this.wordMatches,
    required this.missingWords,
    required this.extraWords,
    required this.incorrectWords,
    required this.isCorrect,
    required this.rating,
  });

  final String expectedText;
  final String recognizedText;
  final int score;
  final List<WordMatch> wordMatches;
  final List<String> missingWords;
  final List<String> extraWords;
  final List<String> incorrectWords;
  final bool isCorrect;
  final PronunciationRating rating;

  @override
  List<Object?> get props => [
        expectedText,
        recognizedText,
        score,
        wordMatches,
        missingWords,
        extraWords,
        incorrectWords,
        isCorrect,
        rating,
      ];
}
