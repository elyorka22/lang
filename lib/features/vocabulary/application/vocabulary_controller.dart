import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/vocab_deck.dart';
import '../../../shared/models/vocabulary_item.dart';
import 'srs_scheduler.dart';

class VocabularyState {
  const VocabularyState({
    this.items = const [],
    this.isLoading = true,
    this.query = '',
    this.categoryFilter,
    this.cefrFilter,
    this.learnedToday = 0,
    this.reviewsToday = 0,
    this.correctToday = 0,
    this.pronunciationScores = const [],
  });

  final List<VocabularyItem> items;
  final bool isLoading;
  final String query;
  final String? categoryFilter;
  final CefrLevel? cefrFilter;
  final int learnedToday;
  final int reviewsToday;
  final int correctToday;
  final List<int> pronunciationScores;

  List<VocabularyItem> get deck => items.where((e) => e.inDeck).toList();

  List<VocabularyItem> get filtered {
    var list = deck;
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (e) =>
                e.word.toLowerCase().contains(q) ||
                e.translationUz.toLowerCase().contains(q) ||
                e.translationRu.toLowerCase().contains(q) ||
                e.definition.toLowerCase().contains(q),
          )
          .toList();
    }
    if (categoryFilter != null) {
      list = list.where((e) => e.category == categoryFilter).toList();
    }
    if (cefrFilter != null) {
      list = list.where((e) => e.cefrLevel == cefrFilter).toList();
    }
    return list;
  }

  List<VocabularyItem> get dueQueue {
    final due = deck.where((e) => e.isDue).toList()
      ..sort((a, b) {
        final aTime = a.nextReviewAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.nextReviewAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });
    return due;
  }

  List<VocabularyItem> get newWords =>
      deck.where((e) => e.srsStatus == SrsStatus.newWord).toList();

  List<VocabularyItem> get learning =>
      deck.where((e) => e.srsStatus == SrsStatus.learning).toList();

  List<VocabularyItem> get review =>
      deck.where((e) => e.srsStatus == SrsStatus.review).toList();

  List<VocabularyItem> get mastered =>
      deck.where((e) => e.srsStatus == SrsStatus.mastered).toList();

  int get dueCount => dueQueue.length;
  int get masteredCount => mastered.length;

  double get accuracyToday {
    if (reviewsToday == 0) return 0;
    return (correctToday / reviewsToday).clamp(0.0, 1.0);
  }

  double get avgPronunciation {
    if (pronunciationScores.isEmpty) return 0;
    final sum = pronunciationScores.fold<int>(0, (a, b) => a + b);
    return sum / pronunciationScores.length;
  }

  VocabularyState copyWith({
    List<VocabularyItem>? items,
    bool? isLoading,
    String? query,
    String? categoryFilter,
    CefrLevel? cefrFilter,
    bool clearCategory = false,
    bool clearCefr = false,
    int? learnedToday,
    int? reviewsToday,
    int? correctToday,
    List<int>? pronunciationScores,
  }) {
    return VocabularyState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      categoryFilter:
          clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      cefrFilter: clearCefr ? null : (cefrFilter ?? this.cefrFilter),
      learnedToday: learnedToday ?? this.learnedToday,
      reviewsToday: reviewsToday ?? this.reviewsToday,
      correctToday: correctToday ?? this.correctToday,
      pronunciationScores: pronunciationScores ?? this.pronunciationScores,
    );
  }
}

final vocabularyProvider =
    StateNotifierProvider<VocabularyController, VocabularyState>((ref) {
  return VocabularyController()..load();
});

class VocabularyController extends StateNotifier<VocabularyState> {
  VocabularyController({SrsScheduler? scheduler})
      : _scheduler = scheduler ?? const SrsScheduler(),
        super(const VocabularyState());

  final SrsScheduler _scheduler;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    state = state.copyWith(
      items: List.of(VocabDeck.words),
      isLoading: false,
    );
  }

  void setQuery(String value) => state = state.copyWith(query: value);

  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryFilter: category);
    }
  }

  void setCefr(CefrLevel? level) {
    if (level == null) {
      state = state.copyWith(clearCefr: true);
    } else {
      state = state.copyWith(cefrFilter: level);
    }
  }

  void toggleFavorite(String id) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id)
            item.copyWith(isFavorite: !item.isFavorite)
          else
            item,
      ],
    );
  }

  void setInDeck(String id, bool inDeck) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id) item.copyWith(inDeck: inDeck) else item,
      ],
    );
  }

  void review(String id, ReviewGrade grade) {
    final before = state.items.firstWhere((e) => e.id == id);
    final updated = _scheduler.applyReview(before, grade);
    final wasNew = before.srsStatus == SrsStatus.newWord;
    final correct = grade == ReviewGrade.good || grade == ReviewGrade.easy;

    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id) updated else item,
      ],
      learnedToday: state.learnedToday + (wasNew ? 1 : 0),
      reviewsToday: state.reviewsToday + 1,
      correctToday: state.correctToday + (correct ? 1 : 0),
    );
  }

  void recordPronunciationScore(int score) {
    state = state.copyWith(
      pronunciationScores: [...state.pronunciationScores, score.clamp(0, 100)],
    );
  }

  VocabularyItem? byId(String id) {
    for (final item in state.items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
