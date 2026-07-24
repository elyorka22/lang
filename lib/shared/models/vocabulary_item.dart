import 'package:equatable/equatable.dart';

enum SrsStatus { newWord, learning, review, mastered }

enum WordDifficulty { easy, medium, hard }

enum CefrLevel { a1, a2, b1, b2, c1, c2 }

/// Rich English vocabulary card with spaced-repetition state.
class VocabularyItem extends Equatable {
  const VocabularyItem({
    required this.id,
    required this.word,
    required this.ipa,
    required this.translationUz,
    required this.translationRu,
    required this.definition,
    required this.example,
    required this.category,
    this.audioUrl,
    this.imageUrl,
    this.difficulty = WordDifficulty.medium,
    this.cefrLevel = CefrLevel.a2,
    this.synonyms = const [],
    this.antonyms = const [],
    this.collocations = const [],
    this.verbForms = const [],
    this.isFavorite = false,
    this.inDeck = true,
    this.srsStatus = SrsStatus.newWord,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    this.lapses = 0,
    this.nextReviewAt,
    this.lastReviewedAt,
    this.createdAt,
  });

  final String id;
  final String word;
  final String ipa;
  final String? audioUrl;
  final String translationUz;
  final String translationRu;
  final String definition;
  final String example;
  final String? imageUrl;
  final String category;
  final WordDifficulty difficulty;
  final CefrLevel cefrLevel;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> collocations;
  final List<String> verbForms;
  final bool isFavorite;
  final bool inDeck;
  final SrsStatus srsStatus;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final int lapses;
  final DateTime? nextReviewAt;
  final DateTime? lastReviewedAt;
  final DateTime? createdAt;

  /// Primary translation shown in UI (Uzbek first, Russian fallback).
  String get translation =>
      translationUz.isNotEmpty ? translationUz : translationRu;

  String get cefrLabel => cefrLevel.name.toUpperCase();

  bool get isDue {
    if (srsStatus == SrsStatus.newWord) return true;
    if (srsStatus == SrsStatus.mastered) return false;
    final due = nextReviewAt;
    if (due == null) return true;
    return !due.isAfter(DateTime.now());
  }

  VocabularyItem copyWith({
    String? ipa,
    String? audioUrl,
    String? translationUz,
    String? translationRu,
    String? definition,
    String? example,
    String? imageUrl,
    String? category,
    WordDifficulty? difficulty,
    CefrLevel? cefrLevel,
    List<String>? synonyms,
    List<String>? antonyms,
    List<String>? collocations,
    List<String>? verbForms,
    bool? isFavorite,
    bool? inDeck,
    SrsStatus? srsStatus,
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    int? lapses,
    DateTime? nextReviewAt,
    DateTime? lastReviewedAt,
    bool clearNextReview = false,
  }) {
    return VocabularyItem(
      id: id,
      word: word,
      ipa: ipa ?? this.ipa,
      audioUrl: audioUrl ?? this.audioUrl,
      translationUz: translationUz ?? this.translationUz,
      translationRu: translationRu ?? this.translationRu,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      collocations: collocations ?? this.collocations,
      verbForms: verbForms ?? this.verbForms,
      isFavorite: isFavorite ?? this.isFavorite,
      inDeck: inDeck ?? this.inDeck,
      srsStatus: srsStatus ?? this.srsStatus,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      lapses: lapses ?? this.lapses,
      nextReviewAt:
          clearNextReview ? null : (nextReviewAt ?? this.nextReviewAt),
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      createdAt: createdAt,
    );
  }

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] as String,
      word: json['word'] as String,
      ipa: json['ipa'] as String? ?? json['pronunciation'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
      translationUz: json['translationUz'] as String? ??
          json['translation'] as String? ??
          '',
      translationRu: json['translationRu'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      example: json['example'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? 'General',
      difficulty: WordDifficulty.values.firstWhere(
        (d) => d.name == (json['difficulty'] as String? ?? 'medium'),
        orElse: () => WordDifficulty.medium,
      ),
      cefrLevel: CefrLevel.values.firstWhere(
        (c) => c.name == (json['cefrLevel'] as String? ?? 'a2'),
        orElse: () => CefrLevel.a2,
      ),
      synonyms: (json['synonyms'] as List?)?.cast<String>() ?? const [],
      antonyms: (json['antonyms'] as List?)?.cast<String>() ?? const [],
      collocations: (json['collocations'] as List?)?.cast<String>() ?? const [],
      verbForms: (json['verbForms'] as List?)?.cast<String>() ?? const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      inDeck: json['inDeck'] as bool? ?? true,
      srsStatus: SrsStatus.values.firstWhere(
        (s) =>
            s.name == (json['srsStatus'] as String? ?? 'newWord') ||
            (json['srsStatus'] == 'new' && s == SrsStatus.newWord),
        orElse: () => SrsStatus.newWord,
      ),
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: json['intervalDays'] as int? ?? 0,
      repetitions: json['repetitions'] as int? ?? 0,
      lapses: json['lapses'] as int? ?? 0,
      nextReviewAt: json['nextReviewAt'] != null
          ? DateTime.parse(json['nextReviewAt'] as String)
          : null,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'ipa': ipa,
        'audioUrl': audioUrl,
        'translationUz': translationUz,
        'translationRu': translationRu,
        'definition': definition,
        'example': example,
        'imageUrl': imageUrl,
        'category': category,
        'difficulty': difficulty.name,
        'cefrLevel': cefrLevel.name,
        'synonyms': synonyms,
        'antonyms': antonyms,
        'collocations': collocations,
        'verbForms': verbForms,
        'isFavorite': isFavorite,
        'inDeck': inDeck,
        'srsStatus': srsStatus.name,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'repetitions': repetitions,
        'lapses': lapses,
        'nextReviewAt': nextReviewAt?.toIso8601String(),
        'lastReviewedAt': lastReviewedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, word, srsStatus, nextReviewAt, isFavorite];
}

/// Review quality for SM-2 scheduling.
enum ReviewGrade { again, hard, good, easy }
