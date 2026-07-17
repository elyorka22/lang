import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/mock_data.dart';
import '../../../shared/models/vocabulary_item.dart';

final vocabularyProvider =
    StateNotifierProvider<VocabularyController, List<VocabularyItem>>((ref) {
  return VocabularyController()..load();
});

class VocabularyController extends StateNotifier<List<VocabularyItem>> {
  VocabularyController() : super(const []);

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    state = List.of(MockData.vocabulary);
  }

  void toggleFavorite(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(isFavorite: !item.isFavorite)
        else
          item,
    ];
  }

  void review(String id, {required bool remembered}) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            intervalDays: remembered ? item.intervalDays * 2 : 1,
            nextReviewAt: DateTime.now().add(
              Duration(days: remembered ? item.intervalDays * 2 : 1),
            ),
          )
        else
          item,
    ];
  }
}
