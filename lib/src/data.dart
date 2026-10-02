import 'game_text.dart';
import 'app_text.dart';

enum LearningTrack { beginner, explorer, master }

extension LearningTrackText on LearningTrack {
  String get title => switch (this) {
        LearningTrack.beginner => AppText.of('track.beginner'),
        LearningTrack.explorer => AppText.of('track.explorer'),
        LearningTrack.master => AppText.of('track.master'),
      };
  String get audience => switch (this) {
        LearningTrack.beginner => AppText.of('track.beginner.note'),
        LearningTrack.explorer => AppText.of('track.explorer.note'),
        LearningTrack.master => AppText.of('track.master.note'),
      };
  String get symbol => switch (this) {
        LearningTrack.beginner => '🌱',
        LearningTrack.explorer => '🧭',
        LearningTrack.master => '🏔️',
      };
}

enum WordCategory { chhungkua, sikul, nungcha, khawvel, nunphung, thiltih }

enum ContentReview { draft, prototypeChecked, approved, reviewRequired }

/// Public builds can opt into the release gate with
/// `--dart-define=HNAHSIN_PRODUCTION=true` (THUMAL_QUEST_PRODUCTION, its name
/// before the rename, still works). Until qualified reviewers approve the
/// corpus, that build fails closed instead of serving draft text.
abstract final class ContentPolicy {
  static const isProduction = bool.fromEnvironment(
    'HNAHSIN_PRODUCTION',
    defaultValue: bool.fromEnvironment('THUMAL_QUEST_PRODUCTION'),
  );

  static bool get releaseReady =>
      wordEntries
              .where((entry) => entry.review == ContentReview.approved)
              .length >=
          20 &&
      oldWordQuestions
              .where((item) => item.review == ContentReview.approved)
              .length >=
          5;

  static bool playable(ContentReview review) => isProduction
      ? review == ContentReview.approved
      : review == ContentReview.approved ||
          review == ContentReview.prototypeChecked ||
          review == ContentReview.reviewRequired;
}

extension WordCategoryText on WordCategory {
  String get label => switch (this) {
        WordCategory.chhungkua => AppText.of('category.chhungkua'),
        WordCategory.sikul => AppText.of('category.sikul'),
        WordCategory.nungcha => AppText.of('category.nungcha'),
        WordCategory.khawvel => AppText.of('category.khawvel'),
        WordCategory.nunphung => AppText.of('category.nunphung'),
        WordCategory.thiltih => AppText.of('category.thiltih'),
      };
}

class WordEntry {
  const WordEntry(
      {required this.id,
      required this.word,
      required this.meaningMizo,
      required this.englishGloss,
      required this.exampleMizo,
      required this.emoji,
      required this.category,
      this.difficulty = 1,
      this.review = ContentReview.prototypeChecked,
      this.gameModes = const <String>{},
      this.imageChecksum});
  final String id;
  final String word;
  final String meaningMizo;
  final String englishGloss;
  final String exampleMizo;
  final String emoji;
  final WordCategory category;
  final int difficulty;
  final ContentReview review;
  final Set<String> gameModes;

  /// SHA-256 of the picture from the content Sheet, if any.
  final String? imageChecksum;

  /// Untagged words (`gameModes.isEmpty`, e.g. the hardcoded prototype
  /// list or content not yet curated) stay playable everywhere. Tagged
  /// words only surface in the games curators picked for them.
  bool supportsGame(String gameId) =>
      gameModes.isEmpty || gameModes.contains(gameId);
}

class ChoiceQuestion {
  const ChoiceQuestion(
      {required this.prompt,
      required this.options,
      required this.answer,
      required this.explanation,
      this.emoji = '💬',
      this.review = ContentReview.prototypeChecked,
      this.difficulty = 1,
      this.contentId,
      this.word});
  final String prompt;
  final List<String> options;
  final String answer;
  final String explanation;
  final String emoji;
  final ContentReview review;
  final int difficulty;

  /// Stable id of the word or question this was built from.
  final String? contentId;

  /// The word asked about, for questions built from a word (null for
  /// written questions), so the game can remember how it went.
  final String? word;
}

class SpellingQuestion {
  const SpellingQuestion(
      {required this.masked,
      required this.options,
      required this.answer,
      required this.hint,
      this.gloss = '',
      this.contentId});
  final String masked;
  final List<String> options;
  final String answer;
  final String hint;

  /// English meaning, shown once the word is complete.
  final String gloss;

  /// The whole word, with the blank filled in.
  String get word => masked.replaceFirst('_', answer);

  /// Studio stable id of the word this was built from.
  final String? contentId;
}

/// Google Cloud settings for a future secure backend. Canonical Mizo text is
/// always kept in the reviewable offline corpus below.
abstract final class MizoCloudConfig {
  static const translationLanguageCode = 'lus';
  static const translationEnabled = true;
  static const speechToTextEnabled = false;
  static const textToSpeechEnabled = false;
  static const backendOnly = true;
}

const wordEntries = <WordEntry>[
  WordEntry(
      id: 'in',
      word: 'In',
      meaningMizo: 'Mihring chenna hmun',
      englishGloss: 'House',
      exampleMizo: 'Kan inah lo kal rawh.',
      emoji: '🏠',
      category: WordCategory.chhungkua),
  WordEntry(
      id: 'nu',
      word: 'Nu',
      meaningMizo: 'Fa neitu hmeichhia',
      englishGloss: 'Mother',
      exampleMizo: 'Ka nu chu a fel hle.',
      emoji: '👩',
      category: WordCategory.chhungkua),
  WordEntry(
      id: 'pa',
      word: 'Pa',
      meaningMizo: 'Fa neitu mipa',
      englishGloss: 'Father',
      exampleMizo: 'Ka pa chu lo a kal.',
      emoji: '👨',
      category: WordCategory.chhungkua),
  WordEntry(
      id: 'nau',
      word: 'Nau',
      meaningMizo: 'Kum la tlem mihring',
      englishGloss: 'Child',
      exampleMizo: 'Nau chu a nui.',
      emoji: '🧒',
      category: WordCategory.chhungkua),
  WordEntry(
      id: 'nula',
      word: 'Nula',
      meaningMizo: 'La innei lo hmeichhia',
      englishGloss: 'Young woman',
      exampleMizo: 'Nula chu sikul a kal.',
      emoji: '👧',
      category: WordCategory.chhungkua),
  WordEntry(
      id: 'lehkhabu',
      word: 'Lehkhabu',
      meaningMizo: 'Chhiar tura thu ziakna bu',
      englishGloss: 'Book',
      exampleMizo: 'Lehkhabu ka chhiar.',
      emoji: '📖',
      category: WordCategory.sikul),
  WordEntry(
      id: 'ziak',
      word: 'Ziak',
      meaningMizo: 'Thu emaw lem emaw siam',
      englishGloss: 'Write',
      exampleMizo: 'I hming ziak rawh.',
      emoji: '✍️',
      category: WordCategory.sikul),
  WordEntry(
      id: 'chhiar',
      word: 'Chhiar',
      meaningMizo: 'Thu ziak hriatthiam tuma en',
      englishGloss: 'Read',
      exampleMizo: 'Thu hi chhiar rawh.',
      emoji: '📘',
      category: WordCategory.sikul),
  WordEntry(
      id: 'zirtirtu',
      word: 'Zirtîrtu',
      meaningMizo: 'Mi dang zirtîrtu',
      englishGloss: 'Teacher',
      exampleMizo: 'Zirtîrtu chu class-ah a lut.',
      emoji: '🧑‍🏫',
      category: WordCategory.sikul),
  WordEntry(
      id: 'sikul',
      word: 'Sikul',
      meaningMizo: 'Zirna hmun',
      englishGloss: 'School',
      exampleMizo: 'Sikul ka kal.',
      emoji: '🏫',
      category: WordCategory.sikul),
  WordEntry(
      id: 'ar',
      word: 'Ar',
      meaningMizo: 'Ranvulh, arpui leh arpa ang chi',
      englishGloss: 'Chicken',
      exampleMizo: 'Ar chu in bulah a kal.',
      emoji: '🐔',
      category: WordCategory.nungcha),
  WordEntry(
      id: 'sava',
      word: 'Sava',
      meaningMizo: 'Thla nei a thlawk thei nungcha',
      englishGloss: 'Bird',
      exampleMizo: 'Sava chu a thlawk chho.',
      emoji: '🐦',
      category: WordCategory.nungcha),
  WordEntry(
      id: 'ui',
      word: 'Ui',
      meaningMizo: 'In veng tura vulh ṭhin nungcha',
      englishGloss: 'Dog',
      exampleMizo: 'Ui chu a tlan chak.',
      emoji: '🐕',
      category: WordCategory.nungcha),
  WordEntry(
      id: 'sakei',
      word: 'Sakei',
      meaningMizo: 'Ramsa lian leh chak tak',
      englishGloss: 'Tiger',
      exampleMizo: 'Sakei chu ramhnuai-ah a awm.',
      emoji: '🐅',
      category: WordCategory.nungcha),
  WordEntry(
      id: 'sangha',
      word: 'Sangha',
      meaningMizo: 'Tui chhunga nungcha',
      englishGloss: 'Fish',
      exampleMizo: 'Lui-ah sangha a awm.',
      emoji: '🐟',
      category: WordCategory.nungcha),
  WordEntry(
      id: 'thing',
      word: 'Thing',
      meaningMizo: 'Lei aṭanga ṭhang thingkung',
      englishGloss: 'Tree',
      exampleMizo: 'Thing hnuaiah kan chawl.',
      emoji: '🌳',
      category: WordCategory.khawvel),
  WordEntry(
      id: 'tui',
      word: 'Tui',
      meaningMizo: 'In leh silfai nana kan hman',
      englishGloss: 'Water',
      exampleMizo: 'Tui thianghlim in rawh.',
      emoji: '💧',
      category: WordCategory.khawvel),
  WordEntry(
      id: 'ni',
      word: 'Ni',
      meaningMizo: 'Khawvêl engtu arsi',
      englishGloss: 'Sun',
      exampleMizo: 'Ni a eng.',
      emoji: '☀️',
      category: WordCategory.khawvel),
  WordEntry(
      id: 'thla',
      word: 'Thla',
      meaningMizo: 'Zan lama kan hmuh ṭhin van thil',
      englishGloss: 'Moon',
      exampleMizo: 'Thla a eng mawi.',
      emoji: '🌙',
      category: WordCategory.khawvel),
  WordEntry(
      id: 'lui',
      word: 'Lui',
      meaningMizo: 'Tui luang lian',
      englishGloss: 'River',
      exampleMizo: 'Lui tui chu a vawt.',
      emoji: '🌊',
      category: WordCategory.khawvel),
  WordEntry(
      id: 'tlang',
      word: 'Tlang',
      meaningMizo: 'Lei sang chho hmun',
      englishGloss: 'Mountain',
      exampleMizo: 'Tlang chhipah kan lawn.',
      emoji: '⛰️',
      category: WordCategory.khawvel),
  WordEntry(
      id: 'ram',
      word: 'Ram',
      meaningMizo: 'Hnam emaw sorkar emaw awpna hmun',
      englishGloss: 'Land',
      exampleMizo: 'Kan ram chu a mawi.',
      emoji: '🌄',
      category: WordCategory.khawvel),
  WordEntry(
      id: 'par',
      word: 'Par',
      meaningMizo: 'Thingkung leh hnim pâr',
      englishGloss: 'Flower',
      exampleMizo: 'Par a vul mawi.',
      emoji: '🌼',
      category: WordCategory.khawvel),
  WordEntry(
      id: 'zai',
      word: 'Zai',
      meaningMizo: 'Hla sa',
      englishGloss: 'Sing',
      exampleMizo: 'Kan za ho.',
      emoji: '🎤',
      category: WordCategory.thiltih),
  WordEntry(
      id: 'kal',
      word: 'Kal',
      meaningMizo: 'Hmun dang pan',
      englishGloss: 'Go',
      exampleMizo: 'Sikul lamah kal rawh.',
      emoji: '🚶',
      category: WordCategory.thiltih),
  WordEntry(
      id: 'tlan',
      word: 'Tlan',
      meaningMizo: 'Ke hmanga kal chak',
      englishGloss: 'Run',
      exampleMizo: 'A tlan chak hle.',
      emoji: '🏃',
      category: WordCategory.thiltih),
  WordEntry(
      id: 'ei',
      word: 'Ei',
      meaningMizo: 'Chaw ei',
      englishGloss: 'Eat',
      exampleMizo: 'Chaw ei rawh.',
      emoji: '🍚',
      category: WordCategory.thiltih),
  WordEntry(
      id: 'hlim',
      word: 'Hlim',
      meaningMizo: 'Lungawi leh lawm',
      englishGloss: 'Happy',
      exampleMizo: 'Naupangte chu an hlim.',
      emoji: '😊',
      category: WordCategory.nunphung),
  WordEntry(
      id: 'mawi',
      word: 'Mawi',
      meaningMizo: 'Hmuh nuam leh nalh',
      englishGloss: 'Beautiful',
      exampleMizo: 'Par chu a mawi.',
      emoji: '✨',
      category: WordCategory.nunphung),
  WordEntry(
      id: 'thian',
      word: 'Ṭhian',
      meaningMizo: 'Inhmangaih leh inpawh mi',
      englishGloss: 'Friend',
      exampleMizo: 'Ka ṭhiante nen kan inkhel.',
      emoji: '🫂',
      category: WordCategory.nunphung),
  WordEntry(
      id: 'tlawmngaihna',
      word: 'Tlawmngaihna',
      meaningMizo: 'Mahni hmasial lova mi dangte ngaihsakna',
      englishGloss: 'Selflessness',
      exampleMizo: 'Tlawmngaihna hi kan nunphung hlu tak a ni.',
      emoji: '🤝',
      category: WordCategory.nunphung,
      difficulty: 3,
      review: ContentReview.reviewRequired),
];

const oldWordQuestions = <ChoiceQuestion>[
  ChoiceQuestion(
      prompt: '“Tlawmngaihna” tih hian eng nge a kawh?',
      options: [
        'Mahni hmasial lova mi dangte ngaihsakna',
        'Sum leh pai ngahna',
        'Mi dang hlauhna',
        'Thu sawi thiamna'
      ],
      answer: 'Mahni hmasial lova mi dangte ngaihsakna',
      explanation:
          'Tlawmngaihna chu mahni hmasial lova mi dangte ṭanpui leh ngaihsakna rilru a ni.',
      emoji: '🤝',
      review: ContentReview.reviewRequired),
  ChoiceQuestion(
      prompt: '“Zawlbuk” tih hian eng nge a kawh?',
      options: [
        'Hmanlai tlangvalte awmkhawmna in',
        'Buh sengna hmun',
        'Chawhmeh chi khat',
        'Khuang chi khat'
      ],
      answer: 'Hmanlai tlangvalte awmkhawmna in',
      explanation:
          'Zawlbuk chu hmanlai Mizo khuaa tlangvalte awmkhawmna leh mikhual thlenna in a ni.',
      emoji: '🏡',
      review: ContentReview.reviewRequired),
  ChoiceQuestion(
      prompt: '“Hnial” tih hian eng nge a kawh?',
      options: ['Mi thusawi pawm lova dodal', 'Hla sak', 'Tlan chak', 'Chaw ei'],
      answer: 'Mi thusawi pawm lova dodal',
      explanation: 'Hnial tih chu mi thusawi pawm lova dodal tihna a ni.',
      emoji: '🗣️',
      review: ContentReview.reviewRequired),
  ChoiceQuestion(
      prompt: '“Tlawh” tih hian eng nge a kawh?',
      options: [
        'Mi emaw hmun emaw va kan',
        'Mut',
        'In lam pan',
        'Lehkha ziak'
      ],
      answer: 'Mi emaw hmun emaw va kan',
      explanation: 'Tlawh tih chu mi emaw hmun emaw va kan tihna a ni.',
      emoji: '📍',
      review: ContentReview.reviewRequired),
  ChoiceQuestion(
      prompt: '“Thufing” tih hian eng nge a kawh?',
      options: ['Finna thu tawi', 'Thawnthu sei', 'Hla thu', 'Thu hriattîrna'],
      answer: 'Finna thu tawi',
      explanation: 'Thufing chu nun kawng zirtîrna leh finna thu tawi a ni.',
      emoji: '💡',
      review: ContentReview.reviewRequired),
];

const spellingQuestions = <SpellingQuestion>[
  SpellingQuestion(
      masked: 'T_AWMNGAIHNA',
      options: ['L', 'R', 'H', 'K'],
      answer: 'L',
      hint: 'Mahni hmasial lova mi dangte ngaihsakna.'),
  SpellingQuestion(
      masked: 'LEHK_ABU',
      options: ['H', 'K', 'T', 'M'],
      answer: 'H',
      hint: 'Kan chhiar ṭhin.'),
  SpellingQuestion(
      masked: 'N_LA',
      options: ['U', 'I', 'A', 'E'],
      answer: 'U',
      hint: 'La innei lo hmeichhia.'),
  SpellingQuestion(
      masked: 'Z_RTÎRTU',
      options: ['I', 'A', 'E', 'U'],
      answer: 'I',
      hint: 'Sikula mi dangte zirtîrtu.'),
  SpellingQuestion(
      masked: 'S_NGHA',
      options: ['A', 'I', 'E', 'O'],
      answer: 'A',
      hint: 'Tui chhunga nungcha.'),
  SpellingQuestion(
      masked: 'KH_VÊL',
      options: ['AW', 'A', 'E', 'U'],
      answer: 'AW',
      hint: 'Kan chenna ram pum.'),
];

const chainDictionary = <String>{
  'aizawl',
  'ar',
  'awm',
  'chaw',
  'chhiar',
  'ei',
  'eng',
  'hlim',
  'hming',
  'hnam',
  'in',
  'inkhêl',
  'kal',
  'lal',
  'lehkhabu',
  'lui',
  'lunglei',
  'mawi',
  'mi',
  'mizo',
  'nau',
  'ni',
  'nula',
  'nu',
  'pa',
  'pâr',
  'ram',
  'sakei',
  'sangha',
  'sava',
  'sikul',
  'ṭhian',
  'thing',
  'thla',
  'tlâng',
  'tlawmngaihna',
  'tlân',
  'tui',
  'ui',
  'upa',
  'zai',
  'ziak',
  'zirtîrtu',
};

/// Optional custom illustration for Picture Match, keyed by normalized
/// Mizo word text (not id, since delivered/synced ids may differ from the
/// local prototype ids). Falls back to WordEntry.emoji when a word has no
/// entry here. See docs/IMAGE_SOURCING_PLAN.md for sourcing rationale --
/// this covers only the words that had no usable single-emoji match.
const wordIllustrations = <String, String>{
  'sawmkhat': 'assets/illustrations/word.sawmkhat.png',
  'sawmhnih': 'assets/illustrations/word.sawmhnih.png',
  'lu': 'assets/illustrations/word.lu.png',
  'sam': 'assets/illustrations/word.sam.png',
  'bekang': 'assets/illustrations/word.bekang.png',
  'sawhchiar': 'assets/illustrations/word.sawhchiar.png',
  'puan': 'assets/illustrations/word.puan.png',
};

/// Open-licence icons for specific delivered words, keyed by stable id so
/// homonyms (e.g. `fu` sugarcane vs `fu-2` flour) get the right picture.
/// Sources and licences: assets/illustrations/ATTRIBUTION.md.
const wordIllustrationsById = <String, String>{
  'word.buhtun': 'assets/illustrations/word.buhtun.png',
  'word.dawhkan': 'assets/illustrations/word.dawhkan.png',
  'word.dawhkan-2': 'assets/illustrations/word.dawhkan-2.png',
  'word.favah': 'assets/illustrations/word.favah.png',
  'word.darkhuang': 'assets/illustrations/word.darkhuang.png',
  'word.darbu': 'assets/illustrations/word.darbu.png',
  'word.darmang': 'assets/illustrations/word.darmang.png',
  'word.thingtuai': 'assets/illustrations/word.thingtuai.png',
  'word.zampher': 'assets/illustrations/word.zampher.png',
  'word.thingrem': 'assets/illustrations/word.thingrem.png',
  'word.hringei': 'assets/illustrations/word.hringei.png',
  'word.chini': 'assets/illustrations/word.chini.png',
  'word.fu': 'assets/illustrations/word.fu.png',
  'word.fu-2': 'assets/illustrations/word.fu-2.png',
  'word.mu': 'assets/illustrations/word.mu.png',
  'word.nawlhbawk': 'assets/illustrations/word.nawlhbawk.png',
  'word.vamur': 'assets/illustrations/word.vamur.png',
  'word.pumpui': 'assets/illustrations/word.pumpui.png',
  'word.kawt': 'assets/illustrations/word.kawt.png',
  'word.kawtzawl': 'assets/illustrations/word.kawtzawl.png',
  'word.len': 'assets/illustrations/word.len.png',
};

/// SHA-256 of the reviewed picture from the content Sheet, if any.
extension WordEntryPicture on WordEntry {
  bool get hasUploadedPicture => WordImages.of(imageChecksum) != null;
}

String? illustrationFor(WordEntry entry) =>
    wordIllustrationsById[entry.id] ?? wordIllustrations[normalizeMizo(entry.word)];

/// True when the word has a picture that actually depicts it, so picture
/// games never ask learners to name a word from an unrelated symbol.
bool hasWordPicture(WordEntry entry) =>
    entry.hasUploadedPicture ||
    entry.emoji.trim().isNotEmpty ||
    illustrationFor(entry) != null;

String normalizeMizo(String value) => value.trim().toLowerCase();

const _plainLetters = <String, String>{
  'â': 'a',
  'ê': 'e',
  'î': 'i',
  'ô': 'o',
  'û': 'u',
  'ṭ': 't',
};

/// [clue] with every spelling of [word] in it blanked out, so a definition
/// such as “Bauh chu ui au dan a ni.” doesn't give its own answer away.
String maskWordInClue(String clue, String word) {
  final answer = foldMizo(word);
  return clue.replaceAllMapped(RegExp(r'\p{L}+', unicode: true),
      (match) => foldMizo(match[0]!) == answer ? '……' : match[0]!);
}

/// A definition of [word] ready to show without naming it. Definitions that
/// open with the word (“Bilh tih hi puan …”, “Bauh chu ui …”) lose that
/// opening; anywhere else the word is blanked out.
String meaningWithoutWord(String meaning, String word) {
  var text = meaning.trim();
  final tokens = RegExp(r'\p{L}+', unicode: true).allMatches(text).toList();
  final parts = foldMizo(word).split(RegExp(r'\s+'));
  final opensWithWord = tokens.length > parts.length + 1 &&
      [for (var i = 0; i < parts.length; i++) foldMizo(tokens[i][0]!) == parts[i]]
          .every((same) => same);
  if (opensWithWord) {
    var next = parts.length;
    if (foldMizo(tokens[next][0]!) == 'tih') next += 1;
    if (next < tokens.length && const {'chu', 'hi'}.contains(foldMizo(tokens[next][0]!))) {
      final rest = text.substring(tokens[next].end).trimLeft().replaceFirst(RegExp(r'^[,:]\s*'), '');
      if (rest.isNotEmpty) text = '${rest[0].toUpperCase()}${rest.substring(1)}';
    }
  }
  return maskWordInClue(text, word);
}

/// [normalizeMizo] without circumflexes or the dot in ṭ, for matching what a
/// learner types on a keyboard that lacks them.
String foldMizo(String value) => normalizeMizo(value)
    .split('')
    .map((letter) => _plainLetters[letter] ?? letter)
    .join();

/// The two-letter letters of the Mizo alphabet (A AW B CH D E F G NG H I J
/// K L M N O P R S T Ṭ U V Z). Clusters such as th, kh or hm are two
/// letters, as a learner reading the alphabet would count them.
const _mizoDigraphs = <String>['aw', 'ch', 'ng'];

/// [value] (lower-cased) split into Mizo alphabet letters, keeping
/// circumflexes: “bâwng” → b, âw, ng.
List<String> mizoLetters(String value) {
  final text = normalizeMizo(value);
  final plain = text
      .split('')
      .map((letter) => letter == 'ṭ' ? letter : (_plainLetters[letter] ?? letter))
      .join();
  final letters = <String>[];
  var index = 0;
  while (index < text.length) {
    final digraph = _mizoDigraphs
        .where((candidate) => plain.startsWith(candidate, index))
        .firstOrNull;
    final length = digraph?.length ?? 1;
    letters.add(text.substring(index, index + length));
    index += length;
  }
  return letters;
}

/// [value] split into Mizo alphabet letters for comparing: circumflexes are
/// dropped (â is still the letter a, and âw is still aw); ṭ stays its own
/// letter.
List<String> mizoUnits(String value) => [
      for (final letter in mizoLetters(value))
        letter
            .split('')
            .map((char) => char == 'ṭ' ? char : (_plainLetters[char] ?? char))
            .join(),
    ];

String firstMizoUnit(String value) {
  final units = mizoUnits(value);
  return units.isEmpty ? '' : units.first;
}

String lastMizoUnit(String value) {
  final units = mizoUnits(value);
  return units.isEmpty ? '' : units.last;
}
