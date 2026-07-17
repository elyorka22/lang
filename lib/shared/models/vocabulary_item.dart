import 'package:equatable/equatable.dart';

class VocabularyItem extends Equatable {
  const VocabularyItem({
    required this.id,
    required this.word,
    required this.translation,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.definition = '',
    this.example = '',
    this.pronunciation = '',
    this.audioUrl,
    this.isFavorite = false,
    this.nextReviewAt,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    this.createdAt,
  });

  final String id;
  final String word;
  final String translation;
  final String definition;
  final String example;
  final String pronunciation;
  final String? audioUrl;
  final String sourceLanguage;
  final String targetLanguage;
  final bool isFavorite;
  final DateTime? nextReviewAt;
  final double easeFactor;
  final int intervalDays;
  final DateTime? createdAt;

  VocabularyItem copyWith({
    bool? isFavorite,
    DateTime? nextReviewAt,
    double? easeFactor,
    int? intervalDays,
  }) {
    return VocabularyItem(
      id: id,
      word: word,
      translation: translation,
      definition: definition,
      example: example,
      pronunciation: pronunciation,
      audioUrl: audioUrl,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      isFavorite: isFavorite ?? this.isFavorite,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      createdAt: createdAt,
    );
  }

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      definition: json['definition'] as String? ?? '',
      example: json['example'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
      sourceLanguage: json['sourceLanguage'] as String? ?? 'en',
      targetLanguage: json['targetLanguage'] as String? ?? 'es',
      isFavorite: json['isFavorite'] as bool? ?? false,
      nextReviewAt: json['nextReviewAt'] != null
          ? DateTime.parse(json['nextReviewAt'] as String)
          : null,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: json['intervalDays'] as int? ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, word, isFavorite];
}
