import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/vocabulary_item.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../vocabulary/application/vocabulary_controller.dart';

class _Card {
  _Card({required this.id, required this.text, required this.pairId});
  final String id;
  final String text;
  final String pairId;
  bool faceUp = false;
  bool matched = false;
}

class MemoryCardsScreen extends ConsumerStatefulWidget {
  const MemoryCardsScreen({super.key});

  @override
  ConsumerState<MemoryCardsScreen> createState() => _MemoryCardsScreenState();
}

class _MemoryCardsScreenState extends ConsumerState<MemoryCardsScreen> {
  late List<_Card> _cards;
  final _flipped = <int>[];
  var _score = 0;
  var _moves = 0;
  var _done = false;
  var _ready = false;
  var _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final words =
        (List.of(ref.read(vocabularyProvider).deck)..shuffle(Random()))
            .take(6)
            .toList();
    final cards = <_Card>[];
    for (final w in words) {
      cards.add(_Card(id: '${w.id}-a', text: w.word, pairId: w.id));
      cards.add(_Card(id: '${w.id}-b', text: w.translation, pairId: w.id));
    }
    cards.shuffle(Random());
    _cards = cards;
    _ready = true;
  }

  Future<void> _tap(int index) async {
    if (_busy || _done) return;
    final card = _cards[index];
    if (card.faceUp || card.matched) return;
    setState(() {
      card.faceUp = true;
      _flipped.add(index);
    });
    if (_flipped.length < 2) return;

    _busy = true;
    _moves++;
    final a = _cards[_flipped[0]];
    final b = _cards[_flipped[1]];
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    if (a.pairId == b.pairId) {
      setState(() {
        a.matched = true;
        b.matched = true;
        _score++;
        _flipped.clear();
        _busy = false;
        if (_cards.every((c) => c.matched)) _done = true;
      });
    } else {
      setState(() {
        a.faceUp = false;
        b.faceUp = false;
        _flipped.clear();
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.gameMemoryCards),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('${s.score}: $_score · $_moves'),
            ),
          ),
        ],
      ),
      body: _done
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events,
                      size: 64, color: AppColors.xpGold),
                  Text(s.sessionComplete,
                      style: context.textTheme.headlineSmall),
                  Text('${s.score}: $_score · moves $_moves'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(s.done),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _cards.length,
              itemBuilder: (_, i) {
                final c = _cards[i];
                final show = c.faceUp || c.matched;
                return PremiumCard(
                  onTap: () => _tap(i),
                  color: c.matched
                      ? AppColors.primarySurface
                      : (show ? Colors.white : AppColors.primary),
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      show ? c.text : '?',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: show ? AppColors.textPrimary : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
