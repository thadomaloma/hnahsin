import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../src/controller.dart';
import '../../../src/data.dart';
import '../../../src/game_session.dart';
import '../../../src/game_text.dart';
import '../../../src/game_words.dart';
import '../../../src/meaning_round.dart';
import '../../../src/theme.dart';
import '../../../src/widgets.dart';
import '../application/game_runtime.dart';
import '../engine/game_engine.dart';
import '../../../src/app_text.dart';

enum _Face { word, picture, gloss }

class _KawpCard {
  const _KawpCard({required this.id, required this.pairId, required this.face, required this.entry});

  final String id;
  final String pairId;
  final _Face face;
  final WordEntry entry;
}

/// Thumal Kawp — a memory game: flip cards and match each Mizo word with its
/// picture (levels 1–2) or its English meaning (level 3 up). The first look
/// at a card is free; only forgetting a partner you've already seen counts
/// as a miss, so the score reflects memory and vocabulary, not luck.
class ThumalKawpGame extends StatefulWidget {
  const ThumalKawpGame({super.key, required this.controller, this.mode = GameMode.standard});

  static const gameId = 'thumal_kawp';

  final QuestController controller;
  final GameMode mode;

  @override
  State<ThumalKawpGame> createState() => _ThumalKawpGameState();
}

class _ThumalKawpGameState extends State<ThumalKawpGame> {
  late final GameRuntime runtime;
  GameSession get session => runtime.session;

  List<_KawpCard> cards = const <_KawpCard>[];
  final Set<String> matched = <String>{};
  final Set<String> seen = <String>{};
  final List<String> flipped = <String>[];
  Set<String> peeking = const <String>{};
  bool busy = false;
  bool finishing = false;
  int turns = 0;

  int get pairCount => cards.length ~/ 2;

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: ThumalKawpGame.gameId,
      mode: widget.mode,
      onChanged: () {
        if (mounted) setState(() {});
      },
      onTimedOut: _timedOut,
    );
    _buildBoard();
    unawaited(
      runtime.initialize(
        currentIndex: () => matched.length,
        readPayload: () => <String, Object?>{
          'matched': matched.toList(),
          'seen': seen.toList(),
          'turns': turns,
        },
        restorePayload: (snapshot) {
          _buildBoard();
          final validPairs = cards.map((card) => card.pairId).toSet();
          final validCards = cards.map((card) => card.id).toSet();
          matched
            ..clear()
            ..addAll((snapshot.payload['matched'] as List<Object?>? ?? const <Object?>[])
                .whereType<String>()
                .where(validPairs.contains));
          seen
            ..clear()
            ..addAll((snapshot.payload['seen'] as List<Object?>? ?? const <Object?>[])
                .whereType<String>()
                .where(validCards.contains));
          turns = (snapshot.payload['turns'] as num?)?.toInt() ?? 0;
        },
      ),
    );
  }

  void _buildBoard() {
    final random = session.random;
    final rating = widget.controller.gameSkill(ThumalKawpGame.gameId);
    final pairs = rating < 2 ? 4 : (rating < 3.5 ? 5 : 6);
    final playable = widget.controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .where((entry) => entry.supportsGame(ThumalKawpGame.gameId))
        .toList();

    // Each pair must be unambiguous: one word per spelling, and no partner
    // that could also belong to another word on the board.
    List<WordEntry> unique(Iterable<WordEntry> pool, Set<String> Function(WordEntry) partnerKeys) {
      final words = <String>{};
      final partners = <String>{};
      final kept = <WordEntry>[];
      for (final entry in pool) {
        final keys = partnerKeys(entry);
        if (words.contains(foldMizo(entry.word)) || keys.any(partners.contains)) continue;
        words.add(foldMizo(entry.word));
        partners.addAll(keys);
        kept.add(entry);
      }
      return kept;
    }

    // The picture a card actually shows, in WordPicture's order.
    Set<String> pictureOf(WordEntry entry) => {
          entry.hasUploadedPicture ? 'upload:${entry.imageChecksum}' : (illustrationFor(entry) ?? entry.emoji.trim()),
        };
    // “fun / happiness” and “happiness” would both match a happiness card.
    Set<String> sensesOf(WordEntry entry) => glossSenses(entry.englishGloss);

    final pictures = rating < 3 ? unique(playable.where(hasWordPicture), pictureOf) : const <WordEntry>[];
    final glosses = unique(
      playable.where((entry) => entry.englishGloss.trim().isNotEmpty && entry.englishGloss.trim().length <= 22),
      sensesOf,
    );
    // Pictures at levels 1–2 when there are enough; otherwise meanings, or
    // whichever of the two can fill more of the board.
    final usePictures = pictures.length >= pairs || (pictures.length > glosses.length);
    final face = usePictures ? _Face.picture : _Face.gloss;
    final pool = usePictures ? pictures : glosses;
    final chosen = pickWordsForLevel(widget.controller, ThumalKawpGame.gameId, pool, pairs, random);
    // A single pair is no memory game; the page says there aren't enough words.
    if (chosen.length < 2) {
      cards = const <_KawpCard>[];
      return;
    }
    cards = [
      for (final entry in chosen) ...[
        _KawpCard(id: '${entry.id}#w', pairId: entry.id, face: _Face.word, entry: entry),
        _KawpCard(id: '${entry.id}#p', pairId: entry.id, face: face, entry: entry),
      ],
    ]..shuffle(random);
  }

  bool _faceUp(_KawpCard card) =>
      matched.contains(card.pairId) || flipped.contains(card.id) || peeking.contains(card.id);

  Future<void> _tap(_KawpCard card) async {
    if (!runtime.ready || busy || finishing || _faceUp(card)) return;
    setState(() => flipped.add(card.id));
    if (flipped.length < 2) return;

    final first = cards.firstWhere((c) => c.id == flipped[0]);
    final second = cards.firstWhere((c) => c.id == flipped[1]);
    turns += 1;
    if (first.pairId == second.pairId) {
      HapticFeedback.selectionClick();
      setState(() {
        matched.add(first.pairId);
        flipped.clear();
        seen.addAll([first.id, second.id]);
        runtime.answer(true, wordId: first.entry.id, word: first.entry.word);
      });
      if (matched.length == pairCount) {
        await _finish();
      }
      return;
    }

    // A miss only counts if the first card's partner had already been seen:
    // the learner could have turned it. Turning a new second card whose
    // partner was seen earlier is just discovering it, not forgetting.
    String partnerOf(_KawpCard c) => cards.firstWhere((o) => o.pairId == c.pairId && o.id != c.id).id;
    final forgot = seen.contains(partnerOf(first));
    seen.addAll([first.id, second.id]);
    busy = true;
    if (forgot) {
      HapticFeedback.lightImpact();
      runtime.answer(false, wordId: first.entry.id, word: first.entry.word);
    } else {
      unawaited(runtime.persist());
    }
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() {
      flipped.clear();
      busy = false;
    });
    if (!session.hasHearts) await _finish(reason: GameEndReason.heartsExhausted);
  }

  Future<void> _useHint() async {
    if (!runtime.ready || busy || finishing || matched.length == pairCount) return;
    // With one card turned, the hint shows where its partner is.
    final pair = flipped.isNotEmpty
        ? cards.firstWhere((card) => card.id == flipped.first).pairId
        : cards.firstWhere((card) => !matched.contains(card.pairId)).pairId;
    await runtime.revealHint();
    if (!mounted) return;
    setState(() => peeking = cards.where((card) => card.pairId == pair).map((card) => card.id).toSet());
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => peeking = const <String>{});
  }

  Future<void> _finish({GameEndReason? reason}) async {
    if (finishing) return;
    finishing = true;
    final result = await runtime.finish(baseXp: 45, reason: reason);
    if (!mounted) return;
    await showGameResult(context, widget.controller, ThumalKawpGame.gameId, result);
  }

  Future<void> _timedOut() => _finish(reason: GameEndReason.timedOut);

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => QuestPage(
        title: GameText.of(ThumalKawpGame.gameId).title,
        subtitle: GameText.of(ThumalKawpGame.gameId).subtitle,
        hud: GameHud(
          session: session,
          progress: pairCount == 0 ? 0 : matched.length / pairCount,
          secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null,
        ),
        child: Column(children: [
          if (runtime.restoredSession) const GameResumeBanner(),
          Row(children: [
            Expanded(
              child: Text(
                AppText.of('kawp.progress', {'found': matched.length, 'pairs': pairCount, 'turns': turns}),
                style: const TextStyle(fontWeight: FontWeight.w700, color: QuestColors.slate),
              ),
            ),
            GameHintButton(
                revealed: runtime.hintRevealed || peeking.isNotEmpty, onPressed: pairCount < 2 ? null : _useHint),
          ]),
          if (pairCount < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                AppText.of('kawp.notEnough'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, color: QuestColors.slate),
              ),
            ),
          const SizedBox(height: 10),
          LayoutBuilder(builder: (context, constraints) {
            final columns = cards.length <= 8 ? 4 : (constraints.maxWidth >= 520 ? 6 : 4);
            const gap = 10.0;
            final size = (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: size,
                    height: size * 1.18,
                    child: _CardTile(
                      card: card,
                      faceUp: _faceUp(card),
                      matched: matched.contains(card.pairId),
                      onTap: () => _tap(card),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Text(
            GameText.of(ThumalKawpGame.gameId).prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(color: QuestColors.slate, fontWeight: FontWeight.w600),
          ),
        ]),
      );
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.faceUp, required this.matched, required this.onTap});

  final _KawpCard card;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = !faceUp
        ? AppText.of('kawp.hiddenSpoken')
        : switch (card.face) {
            _Face.word => card.entry.word,
            _Face.gloss => card.entry.englishGloss,
            _Face.picture => AppText.of('kawp.pictureSpoken', {'gloss': card.entry.englishGloss}),
          };
    return Semantics(
      button: !faceUp,
      label: matched ? AppText.of('kawp.matchedSpoken', {'card': label}) : label,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: faceUp ? 1 : 0),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            builder: (context, t, _) {
              final showFront = t >= .5;
              final angle = (showFront ? 1 - t : t) * 3.1416;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, .0012)
                  ..rotateY(angle),
                child: showFront ? _front() : _back(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _back() => Container(
        decoration: BoxDecoration(
          gradient: QuestGradients.hero,
          borderRadius: BorderRadius.circular(18),
          boxShadow: QuestShadows.card,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.auto_awesome_rounded, color: QuestColors.gold, size: 26),
      );

  Widget _front() {
    final Widget content = switch (card.face) {
      _Face.picture => WordPicture(entry: card.entry, size: 46),
      _Face.word => Text(
          card.entry.word,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: QuestColors.navy),
        ),
      _Face.gloss => Text(
          card.entry.englishGloss,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: QuestColors.tealDark),
        ),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: matched ? const Color(0xFFE6F5E2) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: matched ? QuestColors.success : const Color(0xFFD6E6F2), width: matched ? 2 : 1.5),
        boxShadow: matched ? QuestShadows.glow(QuestColors.success) : QuestShadows.card,
      ),
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 90), child: content)),
    );
  }
}
