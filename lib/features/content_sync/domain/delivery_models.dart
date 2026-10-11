import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';

enum DeliveryPackKind { content }

enum ContentSyncOutcome {
  bundledOnly,
  checking,
  upToDate,
  updated,
  offlinePreserved,
  invalidRejected,
}

class ContentSyncState {
  const ContentSyncState({
    this.outcome = ContentSyncOutcome.bundledOnly,
    this.contentVersion,
    this.lastAttemptAt,
    this.lastSuccessAt,
    this.message = '',
  });

  final ContentSyncOutcome outcome;
  final String? contentVersion;
  final DateTime? lastAttemptAt;
  final DateTime? lastSuccessAt;
  final String message;

  bool get isChecking => outcome == ContentSyncOutcome.checking;
  bool get hasRemotePack => contentVersion != null;

  ContentSyncState copyWith({
    ContentSyncOutcome? outcome,
    String? contentVersion,
    DateTime? lastAttemptAt,
    DateTime? lastSuccessAt,
    String? message,
  }) =>
      ContentSyncState(
        outcome: outcome ?? this.outcome,
        contentVersion: contentVersion ?? this.contentVersion,
        lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
        lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
        message: message ?? this.message,
      );
}

class PackEnvelope {
  const PackEnvelope({
    required this.id,
    required this.version,
    required this.checksum,
    required this.manifest,
  });

  final String id;
  final String version;
  final String checksum;
  final Map<String, Object?> manifest;

  factory PackEnvelope.parse(
    Map<String, Object?> payload, {
    required DeliveryPackKind kind,
  }) {
    final id = _requiredString(payload, 'id');
    final version = _requiredString(payload, 'version');
    final checksum = _requiredChecksum(payload, 'checksum');
    final rawManifest = payload['manifest'];
    if (rawManifest is! Map) {
      throw const FormatException('Pack manifest must be a JSON object.');
    }
    final manifest = Map<String, Object?>.from(rawManifest);
    if (_requiredString(manifest, 'schema_version') != '1.0') {
      throw const FormatException('Unsupported pack schema.');
    }
    if (_requiredString(manifest, 'language') != 'lus') {
      throw const FormatException('Only reviewed Mizo packs are accepted.');
    }
    if (_requiredString(manifest, 'pack_version') != version) {
      throw const FormatException('Pack version does not match its manifest.');
    }
    final expected =
        sha256.convert(utf8.encode(canonicalJson(manifest))).toString();
    if (expected != checksum) {
      throw const FormatException('Pack checksum does not match.');
    }
    switch (kind) {
      case DeliveryPackKind.content:
        _validateContentItems(manifest['items']);
    }
    return PackEnvelope(
        id: id, version: version, checksum: checksum, manifest: manifest);
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'version': version,
        'checksum': checksum,
        'manifest': manifest,
      };

  static void _validateContentItems(Object? value) {
    if (value is! List || value.isEmpty) {
      throw const FormatException('Content pack must contain items.');
    }
    final ids = <String>{};
    for (final raw in value) {
      if (raw is! Map)
        throw const FormatException('Content item must be an object.');
      final item = Map<String, Object?>.from(raw);
      final id = _requiredString(item, 'stable_id');
      if (!ids.add(id))
        throw const FormatException('Duplicate content stable ID.');
      final checksum = _requiredChecksum(item, 'checksum');
      if (item['body'] is! Map)
        throw const FormatException('Content body must be an object.');
      final body = Map<String, Object?>.from(item['body'] as Map);
      final expected =
          sha256.convert(utf8.encode(canonicalJson(body))).toString();
      if (checksum != expected) {
        throw const FormatException(
            'Content item checksum does not match its body.');
      }
    }
  }
}

class DeliveredWord {
  const DeliveredWord({
    required this.id,
    required this.word,
    required this.meaningMizo,
    required this.englishGloss,
    required this.exampleMizo,
    required this.emoji,
    required this.category,
    required this.difficulty,
    this.gameModes = const <String>{},
    this.image,
  });

  final String id;
  final String word;
  final String meaningMizo;
  final String englishGloss;
  final String exampleMizo;
  final String emoji;
  final String category;
  final int difficulty;

  /// The `learning.game_modes` tag set curators assigned this word (e.g.
  /// `picture_match` only for concrete, depictable nouns -- see
  /// `content/pilot/kumtluang/reports/*.md`). Empty means uncurated: the
  /// word hasn't been tagged for any particular game yet, so it stays
  /// visible everywhere rather than disappearing from every game.
  final Set<String> gameModes;

  /// Reviewed picture from the content Sheet, if any.
  final DeliveredImage? image;

  static const categories = <String>{
    'chhungkua',
    'sikul',
    'nungcha',
    'khawvel',
    'nunphung',
    'thiltih',
  };

  /// Maps a free-text `seed_category` (from the nested Content Schema V2
  /// shape the retired Rails Studio's importer produced, which packs
  /// published before the content Sheet still carry) down to one of the six
  /// fixed delivery categories above. Content in the flat delivery shape
  /// (everything the content Sheet publishes, which sets `category`
  /// explicitly) never consults this table.
  static const _seedCategoryFallback = <String, String>{
    // chhungkua -- family / home
    'family': 'chhungkua', 'home': 'chhungkua', 'household': 'chhungkua',
    'people': 'chhungkua', 'community': 'chhungkua',
    // sikul -- school / learning
    'school': 'sikul', 'learning': 'sikul',
    'grammar-term': 'sikul', 'grammar-time': 'sikul',
    // nungcha -- animals
    'animals': 'nungcha', 'nature-wildlife': 'nungcha',
    'culture-animal': 'nungcha',
    // khawvel -- nature / world
    'nature': 'khawvel', 'plants': 'khawvel', 'nature-plant': 'khawvel',
    'nature-food': 'khawvel', 'geography': 'khawvel', 'seasons': 'khawvel',
    'calendar': 'khawvel', 'time': 'khawvel', 'colors': 'khawvel',
    'body': 'khawvel', 'health': 'khawvel', 'numbers': 'khawvel',
    'objects': 'khawvel',
    // nunphung -- culture
    'culture': 'nunphung', 'culture-instrument': 'nunphung',
    'culture/folklore': 'nunphung', 'legend': 'nunphung',
    'traditional_dress': 'nunphung', 'culture-folklore': 'nunphung',
    'culture-tradition': 'nunphung', 'culture-object': 'nunphung',
    'culture-literature': 'nunphung', 'culture-sport': 'nunphung',
    'folktale/legend': 'nunphung', 'festival/culture': 'nunphung',
    'festivals': 'nunphung', 'crafts': 'nunphung', 'history': 'nunphung',
    'values': 'nunphung', 'abstract/values': 'nunphung',
    'abstract-value': 'nunphung', 'idiom': 'nunphung', 'manners': 'nunphung',
    'greetings': 'nunphung', 'clothing': 'nunphung',
    'clothing/traditional': 'nunphung', 'daily-life': 'nunphung',
    'daily_life': 'nunphung', 'occupations': 'nunphung',
    'feelings': 'nunphung', 'emotions': 'nunphung', 'abstract': 'nunphung',
    'abstract-noun': 'nunphung', 'abstract-action': 'nunphung',
    'abstract-emotion': 'nunphung', 'abstract-quality': 'nunphung',
    'qualities': 'nunphung', 'adjectives': 'nunphung',
    'adjective-size': 'nunphung', 'adjective-quality': 'nunphung',
    'adjective-distance': 'nunphung', 'adjective-temperature': 'nunphung',
    'adjective-quantity': 'nunphung', 'adjective-color': 'nunphung',
    'adjective-number': 'nunphung', 'transport': 'nunphung',
    'sport': 'nunphung', 'sport-action': 'nunphung',
    // thiltih -- actions
    'verbs': 'thiltih', 'actions': 'thiltih', 'adverbs': 'thiltih',
    // Added 2026-09-19 after the Kumtluang deeper-extraction pass
    // introduced seed_category values this table didn't cover yet --
    // without an entry here, `_flatten` leaves `category` null, so
    // `parseAll`'s `categories.contains(category)` check silently drops
    // the word from the delivered catalog even after full review and
    // publish. Found by diffing every seed_category value actually used
    // across pilot_candidates.csv/diaspora_expansion_candidates.csv/
    // kumtluang_vocab_master_deduped.csv/vartian_candidates.csv against
    // this table's keys (185 words were affected, most of them new).
    'body parts': 'khawvel', 'body_parts': 'khawvel', 'body/food': 'khawvel',
    'food': 'khawvel', 'food/body': 'khawvel', 'food/nature': 'khawvel',
    'directions': 'khawvel', 'places': 'khawvel', 'sounds': 'khawvel',
    'nature/objects': 'khawvel',
    'tools': 'nunphung', 'tools/nature': 'nunphung',
    'traditional_culture': 'nunphung', 'vehicles': 'nunphung',
    'verbs/craft': 'nunphung', 'people/abstract': 'nunphung',
  };

  /// Accepts either the flat delivery shape this parser was originally
  /// written for (`body['word']`, `body['category']`, ...) or the nested
  /// Content Schema V2 shape (`body['content']['canonical_form']`,
  /// `body['learning']['difficulty']`, ...) and returns a flat map either
  /// way. Flat fields win when both are present. Both shapes exist in the
  /// wild: the editorial web form's own placeholder already uses the flat
  /// shape, while the CSV/rake importer produces the nested one -- this
  /// keeps both paths deliverable without touching the stored body (and
  /// therefore without touching `ContentRevision#checksum`, which pack
  /// verification compares against the *stored*, unmodified body).
  static Map<String, Object?> _flatten(Map<String, Object?> body) {
    if (body['word'] is String) return body;

    final content = body['content'];
    final learning = body['learning'];
    if (content is! Map || learning is! Map) return body;

    final glosses = content['glosses'];
    final englishGloss = glosses is Map ? glosses['en'] : null;

    Object? category = body['category'];
    if (category is! String) {
      final seedCategories = learning['categories'];
      if (seedCategories is List) {
        for (final rawSeed in seedCategories) {
          final mapped = _seedCategoryFallback[rawSeed?.toString()];
          if (mapped != null) {
            category = mapped;
            break;
          }
        }
      }
    }

    return <String, Object?>{
      ...body,
      'word': content['canonical_form'],
      'meaning_mizo': content['definition_mizo'],
      'english_gloss': englishGloss,
      'example_mizo': content['example_mizo'],
      'emoji': content['emoji'] ?? body['emoji'],
      'category': category,
      'difficulty': learning['difficulty'],
      'game_modes': body['game_modes'] ?? learning['game_modes'],
      'image': content['image'] ?? body['image'],
    };
  }

  static List<DeliveredWord> parseAll(Object? value) {
    if (value is! List) return const <DeliveredWord>[];
    final words = <DeliveredWord>[];
    for (final raw in value) {
      if (raw is! Map) continue;
      final item = Map<String, Object?>.from(raw);
      if (item['content_type'] != 'word' || item['body'] is! Map) continue;
      final body = _flatten(Map<String, Object?>.from(item['body'] as Map));
      final difficulty = body['difficulty'];
      final category = body['category'];
      try {
        if (category is! String || !categories.contains(category)) continue;
        if (difficulty is! int || difficulty < 1 || difficulty > 7) continue;
        final rawGameModes = body['game_modes'];
        words.add(
          DeliveredWord(
            id: _requiredString(item, 'stable_id'),
            word: _requiredString(body, 'word'),
            meaningMizo: _requiredString(body, 'meaning_mizo'),
            englishGloss: _requiredString(body, 'english_gloss'),
            exampleMizo: _requiredString(body, 'example_mizo'),
            // Most curriculum words have no curated emoji yet; an empty
            // emoji must not drop an otherwise reviewed word from the catalog.
            emoji:
                body['emoji'] is String ? (body['emoji'] as String).trim() : '',
            category: category,
            difficulty: difficulty,
            gameModes: rawGameModes is List
                ? rawGameModes.whereType<String>().toSet()
                : const <String>{},
            image: DeliveredImage.tryParse(body['image']),
          ),
        );
      } on FormatException {
        continue;
      }
    }
    if (words.map((word) => word.id).toSet().length != words.length) {
      throw const FormatException('Duplicate delivered word ID.');
    }
    return List<DeliveredWord>.unmodifiable(words);
  }
}

/// Reference to a reviewed picture: bytes are fetched from
/// `/api/v1/word_images/<checksum>` and verified against the SHA-256.
class DeliveredImage {
  const DeliveredImage({required this.checksum, required this.contentType, required this.byteSize});

  static const maximumBytes = 512 * 1024;
  static const allowedTypes = <String>{'image/png', 'image/jpeg', 'image/webp'};

  final String checksum;
  final String contentType;
  final int byteSize;

  String get downloadPath => '/api/v1/word_images/$checksum';

  static DeliveredImage? tryParse(Object? value) {
    if (value is! Map) return null;
    final checksum = value['checksum'];
    final type = value['content_type'];
    final size = value['byte_size'];
    if (checksum is! String || !RegExp(r'^[0-9a-f]{64}$').hasMatch(checksum)) return null;
    if (type is! String || !allowedTypes.contains(type)) return null;
    if (size is! int || size < 1 || size > maximumBytes) return null;
    return DeliveredImage(checksum: checksum, contentType: type, byteSize: size);
  }
}

/// A reviewed Tawng Upa question from the content Sheet.
class DeliveredQuestion {
  const DeliveredQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.emoji,
    required this.difficulty,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final String answer;
  final String explanation;
  final String emoji;
  final int difficulty;

  static List<DeliveredQuestion> parseAll(Object? items) => [
        for (final item in _itemsOfType(items, 'question'))
          if (_question(item) case final question?) question,
      ];

  static DeliveredQuestion? _question(Map<String, Object?> item) {
    final body = item['body'] as Map;
    final options = body['options'];
    final answer = body['answer'];
    final prompt = body['prompt_mizo'];
    if (options is! List || options.length != 4) return null;
    final texts = options.whereType<String>().map((option) => option.trim()).toList();
    if (texts.length != 4 || texts.toSet().length != 4) return null;
    if (answer is! String || !texts.contains(answer.trim())) return null;
    if (prompt is! String || prompt.trim().isEmpty) return null;
    final difficulty = body['difficulty'];
    return DeliveredQuestion(
      id: item['stable_id'].toString(),
      prompt: prompt.trim(),
      options: List<String>.unmodifiable(texts),
      answer: answer.trim(),
      explanation: (body['explanation_mizo'] as String?)?.trim() ?? '',
      emoji: (body['emoji'] as String?)?.trim() ?? '',
      difficulty: difficulty is int ? difficulty.clamp(1, 7) : 1,
    );
  }
}

/// Reviewed Mizo text for one game (or `common` for shared feedback).
class DeliveredGameCopy {
  const DeliveredGameCopy({required this.gameId, required this.fields, this.instructions = const <String>[]});

  static const textFields = <String>{'title', 'subtitle', 'prompt', 'hint', 'correct_feedback', 'retry_feedback'};

  final String gameId;
  final Map<String, String> fields;
  final List<String> instructions;

  static Map<String, DeliveredGameCopy> parseAll(Object? items) {
    final copies = <String, DeliveredGameCopy>{};
    for (final item in _itemsOfType(items, 'game_copy')) {
      final body = item['body'] as Map;
      final gameId = body['game_id'];
      if (gameId is! String || gameId.isEmpty) continue;
      final fields = <String, String>{
        for (final key in textFields)
          if (body[key] is String && (body[key] as String).trim().isNotEmpty) key: (body[key] as String).trim(),
      };
      final rawInstructions = body['instructions'];
      copies[gameId] = DeliveredGameCopy(
        gameId: gameId,
        fields: Map<String, String>.unmodifiable(fields),
        instructions: rawInstructions is List
            ? List<String>.unmodifiable(rawInstructions.whereType<String>().where((line) => line.trim().isNotEmpty))
            : const <String>[],
      );
    }
    return Map<String, DeliveredGameCopy>.unmodifiable(copies);
  }
}

/// The content Sheet's “App text” tab: wording for the app's labels, buttons
/// and messages, by text ID (lib/src/app_text.dart).
abstract final class DeliveredAppText {
  static Map<String, String> parseAll(Object? items) {
    final texts = <String, String>{};
    for (final item in _itemsOfType(items, 'app_text')) {
      final body = item['body'] as Map;
      final id = body['text_id'];
      final text = body['text'];
      if (id is! String || id.isEmpty || text is! String || text.trim().isEmpty) continue;
      texts[id] = text.trim();
    }
    return Map<String, String>.unmodifiable(texts);
  }
}

/// A reviewed Sentence Builder sentence.
class DeliveredSentence {
  const DeliveredSentence({required this.id, required this.textMizo, required this.englishSupport, required this.difficulty});

  final String id;
  final String textMizo;
  final String englishSupport;
  final int difficulty;

  static List<DeliveredSentence> parseAll(Object? items) {
    final sentences = <DeliveredSentence>[];
    for (final item in _itemsOfType(items, 'sentence')) {
      final body = item['body'] as Map;
      final content = body['content'] is Map ? body['content'] as Map : body;
      final learning = body['learning'] is Map ? body['learning'] as Map : const <String, Object?>{};
      final text = content['text_mizo'];
      final english = content['english_support'];
      if (text is! String || text.trim().split(RegExp(r'\s+')).length < 2) continue;
      if (english is! String || english.trim().isEmpty) continue;
      final rawDifficulty = learning['difficulty'];
      final tq = int.tryParse(RegExp(r'\d+').firstMatch('${learning['tq_level'] ?? ''}')?.group(0) ?? '');
      sentences.add(DeliveredSentence(
        id: item['stable_id'].toString(),
        textMizo: text.trim(),
        englishSupport: english.trim(),
        difficulty: (rawDifficulty is int ? rawDifficulty : (tq ?? 0) + 1).clamp(1, 7),
      ));
    }
    return List<DeliveredSentence>.unmodifiable(sentences);
  }
}

/// A chapter of the journey's story, written in the content Sheet's
/// Chapters and Story lines tabs.
class DeliveredStoryChapter {
  const DeliveredStoryChapter({
    required this.id,
    required this.order,
    required this.titleMizo,
    required this.titleEnglish,
    required this.emoji,
    required this.introMizo,
    required this.introEnglish,
    required this.wordIds,
    required this.cardsNeeded,
    required this.cultureNoteMizo,
    required this.cultureNoteEnglish,
    required this.lines,
  });

  final String id;
  final int order;
  final String titleMizo;
  final String titleEnglish;
  final String emoji;
  final String introMizo;
  final String introEnglish;

  /// The chapter's words, as word IDs.
  final List<String> wordIds;

  /// Word cards to collect before the chapter opens.
  final int cardsNeeded;
  final String cultureNoteMizo;
  final String cultureNoteEnglish;
  final List<DeliveredStoryLine> lines;

  /// Chapters in order; one without a title or lines is left out.
  static List<DeliveredStoryChapter> parseAll(Object? items) {
    final chapters = <DeliveredStoryChapter>[];
    for (final item in _itemsOfType(items, 'story_chapter')) {
      final body = item['body'] as Map;
      String text(String key) => body[key] is String ? (body[key] as String).trim() : '';
      final lines = [
        for (final line in body['lines'] is List ? body['lines'] as List : const <Object?>[])
          if (DeliveredStoryLine.tryParse(line) case final parsed?) parsed,
      ];
      if (text('title_mizo').isEmpty || lines.isEmpty) continue;
      chapters.add(DeliveredStoryChapter(
        id: item['stable_id'].toString(),
        order: body['order'] is int ? body['order'] as int : 0,
        titleMizo: text('title_mizo'),
        titleEnglish: text('title_english'),
        emoji: text('emoji'),
        introMizo: text('intro_mizo'),
        introEnglish: text('intro_english'),
        wordIds: [
          for (final id in body['word_ids'] is List ? body['word_ids'] as List : const <Object?>[])
            if (id is String && id.isNotEmpty) id,
        ],
        cardsNeeded: body['cards_needed'] is int ? (body['cards_needed'] as int).clamp(0, 100000) : 0,
        cultureNoteMizo: text('culture_note_mizo'),
        cultureNoteEnglish: text('culture_note_english'),
        lines: List<DeliveredStoryLine>.unmodifiable(lines),
      ));
    }
    chapters.sort((a, b) => a.order.compareTo(b.order));
    return List<DeliveredStoryChapter>.unmodifiable(chapters);
  }
}

/// One thing a chapter's speaker says, and the replies to choose from.
class DeliveredStoryLine {
  const DeliveredStoryLine({
    required this.speaker,
    required this.mizo,
    required this.english,
    required this.replies,
  });

  final String speaker;
  final String mizo;
  final String english;
  final List<DeliveredStoryReply> replies;

  /// Null unless it has something said and exactly one right reply.
  static DeliveredStoryLine? tryParse(Object? value) {
    if (value is! Map) return null;
    String text(String key) => value[key] is String ? (value[key] as String).trim() : '';
    final replies = [
      for (final reply in value['replies'] is List ? value['replies'] as List : const <Object?>[])
        if (reply is Map && reply['mizo'] is String && (reply['mizo'] as String).trim().isNotEmpty)
          DeliveredStoryReply(
            mizo: (reply['mizo'] as String).trim(),
            english: reply['english'] is String ? (reply['english'] as String).trim() : '',
            answerMizo: reply['answer_mizo'] is String ? (reply['answer_mizo'] as String).trim() : '',
            right: reply['right'] == true,
          ),
    ];
    if (text('mizo').isEmpty || replies.where((reply) => reply.right).length != 1) return null;
    return DeliveredStoryLine(
      speaker: text('speaker'),
      mizo: text('mizo'),
      english: text('english'),
      replies: List<DeliveredStoryReply>.unmodifiable(replies),
    );
  }
}

class DeliveredStoryReply {
  const DeliveredStoryReply({
    required this.mizo,
    required this.english,
    required this.answerMizo,
    required this.right,
  });

  final String mizo;
  final String english;

  /// What the speaker says back to this reply.
  final String answerMizo;
  final bool right;
}

Iterable<Map<String, Object?>> _itemsOfType(Object? items, String type) sync* {
  if (items is! List) return;
  for (final raw in items) {
    if (raw is! Map || raw['content_type'] != type || raw['body'] is! Map) continue;
    yield Map<String, Object?>.from(raw);
  }
}

String canonicalJson(Object? value) => jsonEncode(_canonicalize(value));

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final sorted = SplayTreeMap<String, Object?>();
    value.forEach((key, item) => sorted[key.toString()] = _canonicalize(item));
    return sorted;
  }
  if (value is List) return value.map(_canonicalize).toList(growable: false);
  return value;
}

String _requiredString(Map<String, Object?> payload, String key) {
  final value = payload[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key is required.');
  }
  return value;
}

String _requiredChecksum(Map<String, Object?> payload, String key) {
  final value = _requiredString(payload, key);
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(value)) {
    throw FormatException('$key must be SHA-256.');
  }
  return value;
}
