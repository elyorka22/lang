import 'package:equatable/equatable.dart';

enum MemorizerKind { word, phrase }

/// Clip saved from chat into Запоминалка (Saves).
class MemorizerItem extends Equatable {
  const MemorizerItem({
    required this.id,
    required this.text,
    required this.createdAt,
    this.translation = '',
    this.note = '',
    this.kind = MemorizerKind.word,
    this.sourceConversationId,
    this.sourceMessageId,
    this.contextSentence = '',
    this.isFavorite = false,
  });

  final String id;
  final String text;
  final String translation;
  final String note;
  final MemorizerKind kind;
  final String? sourceConversationId;
  final String? sourceMessageId;
  final String contextSentence;
  final bool isFavorite;
  final DateTime createdAt;

  MemorizerItem copyWith({
    String? translation,
    String? note,
    bool? isFavorite,
  }) {
    return MemorizerItem(
      id: id,
      text: text,
      translation: translation ?? this.translation,
      note: note ?? this.note,
      kind: kind,
      sourceConversationId: sourceConversationId,
      sourceMessageId: sourceMessageId,
      contextSentence: contextSentence,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, text, translation, isFavorite];
}
