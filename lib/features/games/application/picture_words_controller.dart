import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/game_models.dart';

class PictureWordsState {
  const PictureWordsState({
    this.unlockedLevel = 1,
    this.completedLevelIds = const {},
    this.activeLevelId,
    this.foundWords = const [],
    this.lastFeedback,
    this.justCompleted = false,
  });

  final int unlockedLevel;
  final Set<String> completedLevelIds;
  final String? activeLevelId;
  final List<String> foundWords;
  final String? lastFeedback;
  final bool justCompleted;

  PictureWordLevel? get activeLevel {
    if (activeLevelId == null) return null;
    for (final l in PictureWordsCatalog.levels) {
      if (l.id == activeLevelId) return l;
    }
    return null;
  }

  bool isUnlocked(PictureWordLevel level) => level.level <= unlockedLevel;

  bool isCompleted(PictureWordLevel level) =>
      completedLevelIds.contains(level.id);

  int get foundCount => foundWords.length;

  PictureWordsState copyWith({
    int? unlockedLevel,
    Set<String>? completedLevelIds,
    String? activeLevelId,
    List<String>? foundWords,
    String? lastFeedback,
    bool? justCompleted,
    bool clearActive = false,
    bool clearFeedback = false,
  }) {
    return PictureWordsState(
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
      activeLevelId:
          clearActive ? null : (activeLevelId ?? this.activeLevelId),
      foundWords: foundWords ?? this.foundWords,
      lastFeedback:
          clearFeedback ? null : (lastFeedback ?? this.lastFeedback),
      justCompleted: justCompleted ?? this.justCompleted,
    );
  }
}

final pictureWordsControllerProvider =
    StateNotifierProvider<PictureWordsController, PictureWordsState>((ref) {
  return PictureWordsController();
});

class PictureWordsController extends StateNotifier<PictureWordsState> {
  PictureWordsController() : super(const PictureWordsState());

  void startLevel(String levelId) {
    PictureWordLevel? level;
    for (final l in PictureWordsCatalog.levels) {
      if (l.id == levelId) level = l;
    }
    if (level == null || !state.isUnlocked(level)) return;

    state = PictureWordsState(
      unlockedLevel: state.unlockedLevel,
      completedLevelIds: state.completedLevelIds,
      activeLevelId: level.id,
      foundWords: const [],
      lastFeedback: null,
      justCompleted: false,
    );
  }

  void leaveLevel() {
    state = state.copyWith(
      clearActive: true,
      foundWords: const [],
      clearFeedback: true,
      justCompleted: false,
    );
  }

  void clearJustCompleted() {
    state = state.copyWith(justCompleted: false);
  }

  /// Returns XP awarded (0 if not newly completed).
  int submitWord(String raw) {
    final level = state.activeLevel;
    if (level == null || state.justCompleted) return 0;

    final word = raw.trim().toLowerCase();
    if (word.isEmpty) {
      state = state.copyWith(lastFeedback: 'Type a word');
      return 0;
    }

    // Don't accept the picture title itself as an association.
    if (word == level.word.toLowerCase()) {
      state = state.copyWith(
        lastFeedback: 'Write words about “${level.word}”, not the name itself',
      );
      return 0;
    }

    if (state.foundWords.contains(word)) {
      state = state.copyWith(lastFeedback: 'Already used: $word');
      return 0;
    }

    if (!_isAccepted(word, level)) {
      state = state.copyWith(
        lastFeedback: '“$word” doesn’t fit this picture — try another',
      );
      return 0;
    }

    final nextFound = [...state.foundWords, word];
    final passed = nextFound.length >= level.minWords;
    final alreadyDone = state.completedLevelIds.contains(level.id);

    if (passed && !alreadyDone) {
      final unlocked = level.level + 1 > state.unlockedLevel
          ? level.level + 1
          : state.unlockedLevel;
      state = state.copyWith(
        foundWords: nextFound,
        lastFeedback: 'Nice! “$word” counts',
        completedLevelIds: {...state.completedLevelIds, level.id},
        unlockedLevel: unlocked,
        justCompleted: true,
      );
      return level.xpReward;
    }

    state = state.copyWith(
      foundWords: nextFound,
      lastFeedback: passed
          ? 'Great — level already cleared. Keep adding for practice!'
          : 'Nice! “$word” counts · ${nextFound.length}/${level.minWords}',
    );
    return 0;
  }

  bool _isAccepted(String word, PictureWordLevel level) {
    for (final a in level.acceptedWords) {
      if (a == word) return true;
      // simple stem: kick/kicked, play/playing
      if (word.startsWith(a) && word.length - a.length <= 3) return true;
      if (a.startsWith(word) && a.length - word.length <= 2 && word.length >= 4) {
        return true;
      }
    }
    return false;
  }
}
