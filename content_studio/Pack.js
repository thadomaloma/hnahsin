/**
 * Hnahsin content pack builder: turns the rows of the Google Sheet into the
 * content pack the app downloads (docs/API_CONTENT_PACK_V1.md), and checks
 * every row first, with the problems written in simple English for the editor.
 *
 * Plain JavaScript with no Google services, so the same file runs in Apps
 * Script (Code.js calls it) and in Node (test/pack.test.mjs).
 */

/** Tab names, as the editor sees them. */
var TABS = {
  words: 'Words',
  questions: 'Questions',
  sentences: 'Sentences',
  chapters: 'Chapters',
  storyLines: 'Story lines',
  gameText: 'Game text',
  appText: 'App text',
  help: 'Help',
};

/** The games a word can be ticked for: [app id, column heading]. */
var GAMES = [
  ['picture_match', 'Picture Match'],
  ['spelling', 'Spelling'],
  ['word_search', 'Word Search'],
  ['word_chain', 'Word Chain'],
  ['tawng_upa', 'Tawng Upa'],
  ['crossword', 'Crossword'],
  ['sentence_builder', 'Sentence Builder'],
];

/** Word topics: [app id, what the editor picks]. The app's own Mizo names. */
var CATEGORIES = [
  ['chhungkua', 'Chhungkua'],
  ['sikul', 'Sikul'],
  ['nungcha', 'Nungcha'],
  ['khawvel', 'Khawvel'],
  ['nunphung', 'Nunphung'],
  ['thiltih', 'Thiltih'],
];

/** Status: only “Live” rows reach the app. */
var STATUS = { live: 'Live', review: 'In review', dropped: 'Removed' };

/** Game text rows: the games plus `common` for the shared feedback. */
var GAME_TEXT_IDS = GAMES.map(function (game) { return game[0]; }).concat(['common']);

/**
 * Columns of every tab: key used in code → heading in the sheet. Code.js
 * finds columns by heading, so the editor can move them around.
 */
var COLUMNS = {
  words: [
    ['id', 'ID'],
    ['word', 'Word'],
    ['meaning', 'Meaning (Mizo)'],
    ['english', 'English'],
    ['example', 'Example (Mizo)'],
    ['emoji', 'Emoji'],
    ['picture', 'Picture'],
    ['category', 'Category'],
    ['level', 'Level'],
  ].concat(GAMES).concat([
    ['status', 'Status'],
    ['note', 'Note'],
  ]),
  questions: [
    ['id', 'ID'],
    ['prompt', 'Question (Mizo)'],
    ['option1', 'Answer 1'],
    ['option2', 'Answer 2'],
    ['option3', 'Answer 3'],
    ['option4', 'Answer 4'],
    ['answer', 'Right answer (1-4)'],
    ['explanation', 'Explanation (Mizo)'],
    ['emoji', 'Emoji'],
    ['level', 'Level'],
    ['status', 'Status'],
    ['note', 'Note'],
  ],
  sentences: [
    ['id', 'ID'],
    ['text', 'Sentence (Mizo)'],
    ['english', 'English'],
    ['level', 'Level'],
    ['status', 'Status'],
    ['note', 'Note'],
  ],
  // The journey's story: one row per chapter, and its lines (what someone
  // says and the replies to choose from) on Story lines.
  chapters: [
    ['id', 'ID'],
    ['chapter', 'Chapter'],
    ['title', 'Title (Mizo)'],
    ['english_title', 'Title (English)'],
    ['emoji', 'Emoji'],
    ['intro', 'Intro (Mizo)'],
    ['english_intro', 'Intro (English)'],
    ['words', 'Words'],
    ['cards', 'Cards needed'],
    ['culture', 'Culture note (Mizo)'],
    ['english_culture', 'Culture note (English)'],
    ['status', 'Status'],
    ['note', 'Note'],
  ],
  storyLines: [
    ['id', 'ID'],
    ['chapter', 'Chapter'],
    ['line', 'Line'],
    ['speaker', 'Speaker'],
    ['says', 'Says (Mizo)'],
    ['english_says', 'Says (English)'],
    ['right', 'Right reply (Mizo)'],
    ['english_right', 'Right reply (English)'],
    ['right_answer', 'Answer to right reply (Mizo)'],
    ['wrong1', 'Wrong reply 1 (Mizo)'],
    ['english_wrong1', 'Wrong reply 1 (English)'],
    ['wrong1_answer', 'Answer to wrong reply 1 (Mizo)'],
    ['wrong2', 'Wrong reply 2 (Mizo)'],
    ['english_wrong2', 'Wrong reply 2 (English)'],
    ['wrong2_answer', 'Answer to wrong reply 2 (Mizo)'],
    ['status', 'Status'],
    ['note', 'Note'],
  ],
  gameText: [
    ['id', 'ID'],
    ['game', 'Game'],
    ['title', 'Title'],
    ['subtitle', 'Subtitle'],
    ['prompt', 'Question'],
    ['hint', 'Hint'],
    ['step1', 'How to play 1'],
    ['step2', 'How to play 2'],
    ['step3', 'How to play 3'],
    ['correct_feedback', 'When right'],
    ['retry_feedback', 'When wrong'],
    ['status', 'Status'],
    ['note', 'Note'],
  ],
  // Every label, button and message in the app. The rows come from the app
  // (lib/src/app_text.dart); “Built-in text” is its own wording.
  appText: [
    ['id', 'ID'],
    ['where', 'Where'],
    ['default', 'Built-in text'],
    ['text', 'Text'],
    ['note', 'Note'],
  ],
};

/** The app ignores a pack with fewer words than this (lib/src/controller.dart). */
var MINIMUM_WORDS = 20;
var MINIMUM_BEGINNER_WORDS = 5;
var MAXIMUM_PICTURE_BYTES = 512 * 1024;
var PICTURE_TYPES = ['image/png', 'image/jpeg', 'image/webp'];

/**
 * JSON with object keys sorted, exactly as the app's canonicalJson
 * (lib/features/content_sync/domain/delivery_models.dart) writes it, so the
 * SHA-256 checksums match.
 */
function canonicalJson(value) {
  return JSON.stringify(sortKeys(value));
}

function sortKeys(value) {
  if (Array.isArray(value)) return value.map(sortKeys);
  if (value !== null && typeof value === 'object') {
    var sorted = {};
    Object.keys(value).sort().forEach(function (key) { sorted[key] = sortKeys(value[key]); });
    return sorted;
  }
  return value;
}

function text(value) {
  return value === null || value === undefined ? '' : String(value).trim();
}

/** A whole number from a cell (“3”, 3, 3.0), or NaN. */
function wholeNumber(value) {
  var number = Number(text(value));
  return text(value) !== '' && Number.isInteger(number) ? number : NaN;
}

/** Lower case without circumflexes, to compare Mizo spellings. */
function fold(value) {
  return text(value).toLowerCase()
    .replace(/[âäà]/g, 'a').replace(/[êëè]/g, 'e').replace(/[îïì]/g, 'i')
    .replace(/[ôöò]/g, 'o').replace(/[ûüù]/g, 'u').replace(/ṭ/g, 't');
}

function ticked(value) {
  return value === true || /^(true|yes|x|✓|✔)$/i.test(text(value));
}

/**
 * A new stable ID from the row's text: “word.” + the word without
 * circumflexes or spaces, made unique with -2, -3 … like the Studio's ids.
 */
function newId(prefix, source, taken) {
  var base = text(source).toLowerCase()
    .replace(/[âäà]/g, 'a').replace(/[êëè]/g, 'e').replace(/[îïì]/g, 'i')
    .replace(/[ôöò]/g, 'o').replace(/[ûüù]/g, 'u').replace(/ṭ/g, 't')
    .replace(/[^a-z0-9]+/g, '').slice(0, 40) || 'item';
  var id = prefix + '.' + base;
  for (var n = 2; taken[id]; n++) id = prefix + '.' + base + '-' + n;
  taken[id] = true;
  return id;
}

/**
 * Checks every tab and builds the pack.
 *
 * tabs: {words, questions, sentences, chapters, storyLines, gameText, appText}: arrays of row objects keyed
 *   as in COLUMNS, each with `row` (its row number in the sheet).
 * options.sha256Hex(string): hex SHA-256 of a string's UTF-8 bytes.
 * options.picture(name): {checksum, content_type, byte_size} for a picture in
 *   the Drive folder, or {error: '…'} / null when there is none.
 * options.version, options.id, options.now (ISO time): the pack's identity.
 *
 * Returns {problems: [{tab, row, message}], newIds: [{tab, row, id}],
 *   envelope, pictures: [{name, checksum}], counts}. Rows without an ID get
 *   one (listed in newIds for Code.js to write back). When there are
 *   problems the envelope is null.
 */
function buildPack(tabs, options) {
  var problems = [];
  var newIds = [];
  var items = [];
  var pictures = [];
  var counts = { words: 0, questions: 0, sentences: 0, chapters: 0, gameText: 0, appText: 0 };
  var taken = {};

  function problem(tab, row, message) { problems.push({ tab: TABS[tab], row: row, message: message }); }

  // Every ID in every tab is unique, published or not.
  Object.keys(COLUMNS).forEach(function (tab) {
    (tabs[tab] || []).forEach(function (row) {
      var id = text(row.id);
      if (!id) return;
      if (taken[id]) problem(tab, row.row, 'ID “' + id + '” is already used by another row. Every ID must be different.');
      taken[id] = true;
    });
  });

  function idFor(tab, prefix, row, source) {
    var id = text(row.id);
    if (id) return id;
    id = newId(prefix, source, taken);
    newIds.push({ tab: TABS[tab], row: row.row, id: id });
    return id;
  }

  function statusOf(tab, row) {
    var status = text(row.status);
    if (status === STATUS.live || status === STATUS.review || status === STATUS.dropped) return status;
    if (status === '' && Object.keys(row).every(function (key) { return key === 'row' || text(row[key]) === '' || row[key] === false; })) {
      return null; // an empty row
    }
    problem(tab, row.row, 'Status must be “' + STATUS.live + '”, “' + STATUS.review + '” or “' + STATUS.dropped + '”.');
    return null;
  }

  function level(tab, row) {
    var value = wholeNumber(row.level);
    if (value >= 1 && value <= 7) return value;
    problem(tab, row.row, 'Level must be a number from 1 to 7.');
    return null;
  }

  function required(tab, row, key, heading) {
    var value = text(row[key]);
    if (!value) problem(tab, row.row, '“' + heading + '” is empty. Please fill it in.');
    return value;
  }

  function add(id, type, body) {
    items.push({ stable_id: id, content_type: type, checksum: options.sha256Hex(canonicalJson(body)), body: body });
  }

  var categoryIds = {};
  CATEGORIES.forEach(function (category) { categoryIds[category[1].toLowerCase()] = category[0]; categoryIds[category[0]] = category[0]; });

  var beginners = 0;
  (tabs.words || []).forEach(function (row) {
    if (statusOf('words', row) !== STATUS.live) return;
    var before = problems.length;
    var word = required('words', row, 'word', 'Word');
    var body = {
      word: word,
      meaning_mizo: required('words', row, 'meaning', 'Meaning (Mizo)'),
      english_gloss: required('words', row, 'english', 'English'),
      example_mizo: required('words', row, 'example', 'Example (Mizo)'),
      emoji: text(row.emoji),
      category: categoryIds[text(row.category).toLowerCase()] || null,
      difficulty: level('words', row),
      game_modes: GAMES.filter(function (game) { return ticked(row[game[0]]); }).map(function (game) { return game[0]; }),
    };
    if (!body.category) {
      problem('words', row.row, 'Category must be one of: ' + CATEGORIES.map(function (c) { return c[1]; }).join(', ') + '.');
    }
    var pictureName = text(row.picture);
    if (pictureName) {
      var picture = options.picture(pictureName);
      if (!picture) {
        problem('words', row.row, 'Picture “' + pictureName + '” is not in the “Hnahsin thlalak” (pictures) folder.');
      } else if (picture.error) {
        problem('words', row.row, 'Picture “' + pictureName + '”: ' + picture.error);
      } else if (PICTURE_TYPES.indexOf(picture.content_type) < 0) {
        problem('words', row.row, 'Picture “' + pictureName + '” must be a PNG, JPEG or WebP file.');
      } else if (picture.byte_size > MAXIMUM_PICTURE_BYTES) {
        problem('words', row.row, 'Picture “' + pictureName + '” is too big (over 512 KB). Please use a smaller one.');
      } else {
        body.image = { checksum: picture.checksum, content_type: picture.content_type, byte_size: picture.byte_size };
        pictures.push({ name: pictureName, checksum: picture.checksum });
      }
    }
    if (problems.length > before) return;
    add(idFor('words', 'word', row, word), 'word', body);
    counts.words += 1;
    if (body.difficulty === 1) beginners += 1;
  });

  (tabs.questions || []).forEach(function (row) {
    if (statusOf('questions', row) !== STATUS.live) return;
    var before = problems.length;
    var prompt = required('questions', row, 'prompt', 'Question (Mizo)');
    var options4 = [1, 2, 3, 4].map(function (n) { return required('questions', row, 'option' + n, 'Answer ' + n); });
    var distinct = options4.filter(function (option, index) { return option && options4.indexOf(option) === index; });
    if (distinct.length === 4 || options4.some(function (option) { return !option; })) {
      // empty options are already reported
    } else {
      problem('questions', row.row, 'The 4 answers must all be different.');
    }
    var answer = wholeNumber(row.answer);
    if (!(answer >= 1 && answer <= 4)) problem('questions', row.row, '“Right answer” must be 1, 2, 3 or 4.');
    var body = {
      prompt_mizo: prompt,
      options: options4,
      answer: options4[answer - 1],
      explanation_mizo: required('questions', row, 'explanation', 'Explanation (Mizo)'),
      // Tawng upa need no picture: an empty Emoji shows none.
      emoji: text(row.emoji),
      difficulty: level('questions', row),
    };
    if (problems.length > before) return;
    add(idFor('questions', 'question', row, prompt), 'question', body);
    counts.questions += 1;
  });

  (tabs.sentences || []).forEach(function (row) {
    if (statusOf('sentences', row) !== STATUS.live) return;
    var before = problems.length;
    var sentence = required('sentences', row, 'text', 'Sentence (Mizo)');
    if (sentence && sentence.split(/\s+/).length < 2) problem('sentences', row.row, 'A sentence needs at least 2 words.');
    var body = {
      content: { text_mizo: sentence, english_support: required('sentences', row, 'english', 'English') },
      learning: { difficulty: level('sentences', row) },
    };
    if (problems.length > before) return;
    add(idFor('sentences', 'sentence', row, sentence), 'sentence', body);
    counts.sentences += 1;
  });

  // Live words by ID and by spelling, for a chapter's Words.
  var liveWordIds = {};
  var wordIdsBySpelling = {};
  items.forEach(function (item) {
    if (item.content_type !== 'word') return;
    liveWordIds[item.stable_id] = true;
    var spelling = fold(item.body.word);
    (wordIdsBySpelling[spelling] = wordIdsBySpelling[spelling] || []).push(item.stable_id);
  });

  // Each Live chapter's Live lines, in Line order.
  var linesByChapter = {};
  (tabs.storyLines || []).forEach(function (row) {
    if (statusOf('storyLines', row) !== STATUS.live) return;
    var before = problems.length;
    var chapter = wholeNumber(row.chapter);
    if (!(chapter >= 1)) problem('storyLines', row.row, '“Chapter” must be the number of a chapter on the Chapters tab (1, 2, 3 …).');
    var says = required('storyLines', row, 'says', 'Says (Mizo)');
    var right = required('storyLines', row, 'right', 'Right reply (Mizo)');
    required('storyLines', row, 'wrong1', 'Wrong reply 1 (Mizo)');
    var replies = [{ mizo: right, english: text(row.english_right), answer_mizo: text(row.right_answer), right: true }];
    [1, 2].forEach(function (n) {
      var wrong = text(row['wrong' + n]);
      if (!wrong) return;
      if (fold(wrong) === fold(right)) problem('storyLines', row.row, '“Wrong reply ' + n + '” is the same as the right reply.');
      replies.push({ mizo: wrong, english: text(row['english_wrong' + n]), answer_mizo: text(row['wrong' + n + '_answer']), right: false });
    });
    idFor('storyLines', 'line', row, says);
    if (problems.length > before) return;
    (linesByChapter[chapter] = linesByChapter[chapter] || []).push({
      order: wholeNumber(row.line), row: row.row,
      line: { speaker: text(row.speaker), mizo: says, english: text(row.english_says), replies: replies },
    });
  });

  var seenChapters = {};
  (tabs.chapters || []).forEach(function (row) {
    if (statusOf('chapters', row) !== STATUS.live) return;
    var before = problems.length;
    var chapter = wholeNumber(row.chapter);
    if (!(chapter >= 1)) {
      problem('chapters', row.row, '“Chapter” must be a number: 1 for the first chapter, 2 for the next …');
    } else if (seenChapters[chapter]) {
      problem('chapters', row.row, 'There is already a chapter ' + chapter + '.');
    }
    seenChapters[chapter] = true;
    var title = required('chapters', row, 'title', 'Title (Mizo)');
    var cards = text(row.cards) === '' ? 0 : wholeNumber(row.cards);
    if (!(cards >= 0)) problem('chapters', row.row, '“Cards needed” must be a number (0 or more), or empty.');
    var wordIds = [];
    text(row.words).split(/[,;\n]/).map(text).filter(Boolean).forEach(function (word) {
      if (liveWordIds[word]) return wordIds.push(word);
      var ids = wordIdsBySpelling[fold(word)] || [];
      if (!ids.length) {
        problem('chapters', row.row, 'Word “' + word + '” is not a “' + STATUS.live + '” word on the Words tab.');
      } else if (ids.length > 1) {
        problem('chapters', row.row, '“' + word + '” is on the Words tab more than once. Write the ID of the one you mean instead: ' + ids.join(', ') + '.');
      } else {
        wordIds.push(ids[0]);
      }
    });
    var lines = (linesByChapter[chapter] || []).slice().sort(function (a, b) {
      return (a.order || 0) - (b.order || 0) || a.row - b.row;
    });
    if (chapter >= 1 && !lines.length) problem('chapters', row.row, 'Chapter ' + chapter + ' has no “' + STATUS.live + '” rows on the Story lines tab.');
    if (problems.length > before) return;
    add(idFor('chapters', 'chapter', row, title), 'story_chapter', {
      order: chapter,
      title_mizo: title,
      title_english: text(row.english_title),
      emoji: text(row.emoji),
      intro_mizo: text(row.intro),
      intro_english: text(row.english_intro),
      word_ids: wordIds,
      cards_needed: cards,
      culture_note_mizo: text(row.culture),
      culture_note_english: text(row.english_culture),
      lines: lines.map(function (entry) { return entry.line; }),
    });
    counts.chapters += 1;
  });
  Object.keys(linesByChapter).forEach(function (chapter) {
    if (seenChapters[chapter]) return;
    linesByChapter[chapter].forEach(function (entry) {
      problem('storyLines', entry.row, 'There is no “' + STATUS.live + '” chapter ' + chapter + ' on the Chapters tab.');
    });
  });

  var seenGames = {};
  (tabs.gameText || []).forEach(function (row) {
    if (statusOf('gameText', row) !== STATUS.live) return;
    var game = text(row.game);
    if (GAME_TEXT_IDS.indexOf(game) < 0) {
      problem('gameText', row.row, '“Game” must be one of: ' + GAME_TEXT_IDS.join(', ') + '.');
      return;
    }
    if (seenGames[game]) {
      problem('gameText', row.row, 'There is already a row for “' + game + '”.');
      return;
    }
    seenGames[game] = true;
    // Empty cells keep the app's built-in text.
    var body = { game_id: game };
    ['title', 'subtitle', 'prompt', 'hint', 'correct_feedback', 'retry_feedback'].forEach(function (key) {
      if (text(row[key])) body[key] = text(row[key]);
    });
    body.instructions = ['step1', 'step2', 'step3'].map(function (key) { return text(row[key]); }).filter(Boolean);
    add(idFor('gameText', 'game', row, game), 'game_copy', body);
    counts.gameText += 1;
  });

  // A row reaches the app only when its Text differs from the built-in text.
  (tabs.appText || []).forEach(function (row) {
    var id = text(row.id);
    var wording = text(row.text);
    var builtIn = text(row['default']);
    if (!id || !wording || wording === builtIn) return;
    if (!builtIn) {
      problem('appText', row.row, 'The app has no text with ID “' + id + '”. Rows must come from the app\'s list (its “Built-in text” is empty).');
      return;
    }
    var want = placeholders(builtIn);
    var have = placeholders(wording);
    if (want.join(' ') !== have.join(' ')) {
      problem('appText', row.row, want.length
        ? '“Text” must have exactly these, as in “Built-in text”: ' + want.map(function (p) { return '{' + p + '}'; }).join(', ') + '. The app puts a number or word there.'
        : '“Text” cannot have {…}: “Built-in text” has none.');
      return;
    }
    add('app.' + id, 'app_text', { text_id: id, text: wording });
    counts.appText += 1;
  });

  // Only once the rows are right: rows with problems aren't counted yet.
  if (!problems.length && (counts.words < MINIMUM_WORDS || beginners < MINIMUM_BEGINNER_WORDS)) {
    problems.push({
      tab: TABS.words,
      row: null,
      message: 'The app needs at least ' + MINIMUM_WORDS + ' “' + STATUS.live + '” words, with at least ' + MINIMUM_BEGINNER_WORDS +
        ' of them Level 1 (now ' + counts.words + ' words, ' + beginners + ' at Level 1).',
    });
  }

  if (problems.length) return { problems: problems, newIds: newIds, envelope: null, pictures: pictures, counts: counts };

  items.sort(function (a, b) { return a.stable_id < b.stable_id ? -1 : a.stable_id > b.stable_id ? 1 : 0; });
  var manifest = {
    schema_version: '1.0',
    language: 'lus',
    pack_version: options.version,
    generated_at: options.now,
    items: items,
  };
  return {
    problems: problems,
    newIds: newIds,
    pictures: pictures,
    counts: counts,
    envelope: {
      id: options.id,
      version: options.version,
      checksum: options.sha256Hex(canonicalJson(manifest)),
      published_at: options.now,
      manifest: manifest,
    },
  };
}

/** The distinct `{name}` placeholders in a text, sorted. */
function placeholders(value) {
  var found = {};
  (value.match(/\{\w+\}/g) || []).forEach(function (match) { found[match.slice(1, -1)] = true; });
  return Object.keys(found).sort();
}

/** A pack version from the publish time: 2.YYYYMMDD.HHMMSS (UTC). */
function packVersion(date) {
  var pad = function (n) { return (n < 10 ? '0' : '') + n; };
  return '2.' + date.getUTCFullYear() + pad(date.getUTCMonth() + 1) + pad(date.getUTCDate()) + '.' +
    pad(date.getUTCHours()) + pad(date.getUTCMinutes()) + pad(date.getUTCSeconds());
}

if (typeof module !== 'undefined') {
  module.exports = {
    TABS: TABS, GAMES: GAMES, CATEGORIES: CATEGORIES, STATUS: STATUS, COLUMNS: COLUMNS, GAME_TEXT_IDS: GAME_TEXT_IDS,
    canonicalJson: canonicalJson, buildPack: buildPack, packVersion: packVersion, newId: newId,
  };
}
