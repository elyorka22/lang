import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/vocabulary_item.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../vocabulary/application/vocabulary_controller.dart';

class MatchMeaningScreen extends ConsumerStatefulWidget {
  const MatchMeaningScreen({super.key});

  @override
  ConsumerState<MatchMeaningScreen> createState() => _MatchMeaningScreenState();
}

class _MatchMeaningScreenState extends ConsumerState<MatchMeaningScreen> {
  late List<VocabularyItem> _words;
  late List<String> _meanings;
  final _pairs = <String, String>{};
  String? _selectedWord;
  String? _selectedMeaning;
  var _score = 0;
  var _done = false;
  var _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final deck = ref.read(vocabularyProvider).deck;
    final rnd = Random();
    _words = (List.of(deck)..shuffle(rnd)).take(6).toList();
    _meanings = _words.map((e) => e.translation).toList()..shuffle(rnd);
    _ready = true;
  }

  void _tapWord(String word) {
    if (_done || _pairs.containsKey(word)) return;
    setState(() => _selectedWord = word);
    _tryMatch();
  }

  void _tapMeaning(String meaning) {
    if (_done || _pairs.containsValue(meaning)) return;
    setState(() => _selectedMeaning = meaning);
    _tryMatch();
  }

  void _tryMatch() {
    final w = _selectedWord;
    final m = _selectedMeaning;
    if (w == null || m == null) return;
    final item = _words.firstWhere((e) => e.word == w);
    final correct = item.translation == m;
    setState(() {
      if (correct) {
        _pairs[w] = m;
        _score += 1;
      }
      _selectedWord = null;
      _selectedMeaning = null;
      if (_pairs.length == _words.length) _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.gameMatchMeaning),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${s.score}: $_score/${_words.length}',
                style: context.textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: _done
          ? _Result(score: _score, total: _words.length)
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        for (final w in _words)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _Tile(
                              label: w.word,
                              selected: _selectedWord == w.word,
                              matched: _pairs.containsKey(w.word),
                              onTap: () => _tapWord(w.word),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final m in _meanings)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _Tile(
                              label: m,
                              selected: _selectedMeaning == m,
                              matched: _pairs.containsValue(m),
                              onTap: () => _tapMeaning(m),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.selected,
    required this.matched,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: matched ? null : onTap,
      color: matched
          ? AppColors.primarySurface
          : selected
              ? AppColors.primary.withOpacity(0.15)
              : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: matched ? AppColors.primaryDark : null,
            ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.score, required this.total});
  final int score;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: AppColors.xpGold),
            const SizedBox(height: 12),
            Text(s.sessionComplete, style: context.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${s.score}: $score / $total'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.done),
            ),
          ],
        ),
      ),
    );
  }
}
