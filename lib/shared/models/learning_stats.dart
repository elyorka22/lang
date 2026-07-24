import 'package:equatable/equatable.dart';

class DailyGoal extends Equatable {
  const DailyGoal({
    this.wordsTarget = 10,
    this.wordsDone = 0,
    this.reviewsTarget = 15,
    this.reviewsDone = 0,
  });

  final int wordsTarget;
  final int wordsDone;
  final int reviewsTarget;
  final int reviewsDone;

  double get overallProgress {
    final parts = [
      wordsDone / wordsTarget,
      reviewsDone / reviewsTarget,
    ];
    final avg = parts.map((e) => e.clamp(0.0, 1.0)).reduce((a, b) => a + b) /
        parts.length;
    return avg.clamp(0.0, 1.0);
  }

  bool get isComplete => overallProgress >= 1.0;

  @override
  List<Object?> get props => [wordsDone, reviewsDone];
}

class LearningStats extends Equatable {
  const LearningStats({
    this.weeklyMinutes = const [],
    this.monthlyXp = const [],
    this.totalXp = 0,
    this.totalWords = 0,
    this.totalMessages = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.level = 1,
  });

  final List<int> weeklyMinutes;
  final List<int> monthlyXp;
  final int totalXp;
  final int totalWords;
  final int totalMessages;
  final int currentStreak;
  final int longestStreak;
  final int level;

  @override
  List<Object?> get props => [totalXp, currentStreak, level];
}

class VoiceAnalysisResult extends Equatable {
  const VoiceAnalysisResult({
    required this.pronunciationScore,
    required this.fluency,
    required this.accent,
    required this.speakingSpeed,
    required this.naturalness,
    this.mispronouncedWords = const [],
    this.suggestions = const [],
  });

  final double pronunciationScore;
  final double fluency;
  final String accent;
  final double speakingSpeed;
  final double naturalness;
  final List<String> mispronouncedWords;
  final List<String> suggestions;

  @override
  List<Object?> get props => [pronunciationScore, fluency];
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.payload,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? payload;

  @override
  List<Object?> get props => [id, isRead];
}
