import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/memorizer_item.dart';

final memorizerProvider =
    StateNotifierProvider<MemorizerController, List<MemorizerItem>>((ref) {
  return MemorizerController()..load();
});

class MemorizerController extends StateNotifier<List<MemorizerItem>> {
  MemorizerController() : super(const []);

  final _uuid = const Uuid();

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    // Seed empty — users fill from chat. Optional demo clip:
    state = const [];
  }

  MemorizerKind _kindFor(String text) {
    final trimmed = text.trim();
    final words = trimmed.split(RegExp(r'\s+'));
    return words.length <= 1 ? MemorizerKind.word : MemorizerKind.phrase;
  }

  /// Save highlighted word/phrase from a chat message.
  Future<MemorizerItem?> saveFromChat({
    required String text,
    String? conversationId,
    String? messageId,
    String contextSentence = '',
    String translation = '',
    String note = '',
  }) async {
    final clipped = text.trim();
    if (clipped.isEmpty) return null;

    final exists = state.any(
      (e) => e.text.toLowerCase() == clipped.toLowerCase(),
    );
    if (exists) {
      return state.firstWhere(
        (e) => e.text.toLowerCase() == clipped.toLowerCase(),
      );
    }

    final item = MemorizerItem(
      id: _uuid.v4(),
      text: clipped,
      translation: translation.trim(),
      note: note.trim(),
      kind: _kindFor(clipped),
      sourceConversationId: conversationId,
      sourceMessageId: messageId,
      contextSentence: contextSentence.trim(),
      createdAt: DateTime.now(),
    );
    state = [item, ...state];
    return item;
  }

  void updateTranslation(String id, String translation) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(translation: translation.trim())
        else
          item,
    ];
  }

  void updateNote(String id, String note) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(note: note.trim()) else item,
    ];
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

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  List<MemorizerItem> get words =>
      state.where((e) => e.kind == MemorizerKind.word).toList();

  List<MemorizerItem> get phrases =>
      state.where((e) => e.kind == MemorizerKind.phrase).toList();
}
