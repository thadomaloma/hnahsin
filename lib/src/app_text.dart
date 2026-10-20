/// Every label, button and message in the app, by ID, with the text it shows
/// unless the content Sheet's “App text” tab says otherwise. The Sheet's rows
/// are made from [appTextDefaults], so a new text here needs a new row there
/// (content_studio/README.md).
library;

import '../l10n/translations.dart';

/// One text's built-in wording and where in the app it shows.
class AppTextDefault {
  const AppTextDefault(this.where, this.text);

  /// The screen or part of the app, so an editor can find it.
  final String where;

  /// The English wording: what the Sheet's “Built-in text” shows. Other
  /// languages are in lib/l10n.
  final String text;
}

/// The `{name}` placeholders in [text], which the app fills in.
Set<String> appTextPlaceholders(String text) =>
    RegExp(r'\{(\w+)\}').allMatches(text).map((match) => match[1]!).toSet();

abstract final class AppText {
  static Map<String, String> _delivered = const <String, String>{};

  /// The Sheet's texts from the active content pack.
  static void update(Map<String, String> delivered) => _delivered = delivered;

  /// The language the labels are shown in ([AppLocale.code]): the phone's,
  /// or the one chosen in Profile.
  static String locale = 'en';

  /// [id]'s text in [locale], with its `{name}` placeholders filled from
  /// [values]. The Sheet edits the English wording; other languages use
  /// their translation (lib/l10n), or English where it has none. Sheet text
  /// and translations are used only with the built-in text's placeholders,
  /// so a typo can't show a raw `{name}` or drop a number.
  static String of(String id,
      [Map<String, Object?> values = const <String, Object?>{}]) {
    final english = appTextDefaults[id]?.text ?? id;
    final other = locale == 'en' ? _delivered[id] : translations[locale]?[id];
    final wanted = appTextPlaceholders(english);
    var text = other != null && _sameSet(appTextPlaceholders(other), wanted)
        ? other
        : english;
    values.forEach(
        (name, value) => text = text.replaceAll('{$name}', '${value ?? ''}'));
    return text;
  }

  /// Content written in both Mizo and English, such as the journey's story
  /// titles: the English (labels' languages have no Mizo), else the Mizo.
  static String pick({required String mizo, required String english}) =>
      english.isEmpty ? mizo : english;

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

const appTextDefaults = <String, AppTextDefault>{
  // Content review
  'review.title': AppTextDefault('Content review', 'Checking content'),
  'review.body': AppTextDefault('Content review',
      'Mizo experts are still checking this content. It will appear when it is ready.'),
  // Navigation
  'nav.home': AppTextDefault('Navigation', 'Home'),
  'nav.learn': AppTextDefault('Navigation', 'Learn'),
  'nav.games': AppTextDefault('Navigation', 'Games'),
  'nav.profile': AppTextDefault('Navigation', 'Profile'),
  // Profile • content
  'content.offline': AppTextDefault('Profile • content', 'Offline words'),
  'content.version': AppTextDefault('Profile • content', 'Content {version}'),
  'content.check': AppTextDefault('Profile • content', 'Check for new words'),
  'content.builtIn': AppTextDefault('Profile • content', 'Built-in words'),
  'sync.builtInReady':
      AppTextDefault('Profile • content', 'Words are ready to play offline.'),
  'sync.packsReady':
      AppTextDefault('Profile • content', 'Your words are ready offline.'),
  'sync.checking':
      AppTextDefault('Profile • content', 'Checking for new words…'),
  'sync.updated': AppTextDefault('Profile • content', 'New words added.'),
  'sync.upToDate':
      AppTextDefault('Profile • content', 'You have the latest words.'),
  'sync.rejected': AppTextDefault('Profile • content',
      'This update had a problem, so we skipped it. Your words still work. {error}'),
  'sync.unavailable': AppTextDefault('Profile • content',
      'Could not check for new words. Your words still work.'),
  // Content report
  'report.done': AppTextDefault('Content report', 'Issue reported'),
  'report.open': AppTextDefault('Content report', 'Report content issue'),
  'report.title': AppTextDefault('Content report', 'Report a content issue'),
  'report.privacy': AppTextDefault('Content report',
      'We don\'t collect personal messages. Your report stays on this device.'),
  'report.spelling':
      AppTextDefault('Content report', 'Mizo spelling or wording'),
  'report.meaning': AppTextDefault('Content report', 'Meaning or translation'),
  'report.picture': AppTextDefault('Content report', 'Picture does not match'),
  'report.culture': AppTextDefault('Content report', 'Cultural context'),
  'report.save': AppTextDefault('Content report', 'Save Report'),
  'report.saved': AppTextDefault('Content report', 'Report saved. Thank you!'),
  // Home
  'home.journey': AppTextDefault('Home', 'Mizo Journey'),
  'home.viewMap': AppTextDefault('Home', 'View Map'),
  'home.storyPath': AppTextDefault('Home', 'STORY PATH'),
  'home.journeyComplete': AppTextDefault('Home', 'Journey Complete'),
  'home.journeyContinue': AppTextDefault('Home', 'Continue Your Journey'),
  'home.journeyProgress':
      AppTextDefault('Home', '{done}/{total} story stops • Daily quests'),
  'home.greeting': AppTextDefault('Home', 'Chibai! 👋'),
  'app.name': AppTextDefault('Home', 'Hnahsin'),
  'home.xpLevel': AppTextDefault('Home', 'Lv {level}'),
  'home.todaysGame': AppTextDefault('Home', 'TODAY\'S GAME'),
  'home.best': AppTextDefault('Home', 'Best {score}'),
  'home.replay': AppTextDefault('Home', '{n} words to see again'),
  'home.roundsToday': AppTextDefault('Home', '{done}/{goal}\nROUNDS'),
  'home.rhythm': AppTextDefault('Home', 'Learning rhythm'),
  'home.streak': AppTextDefault('Home', '{n} day streak'),
  'home.startToday': AppTextDefault('Home', 'Start today'),
  'home.play': AppTextDefault('Home', 'Play'),
  'home.otherGame': AppTextDefault('Home', 'Play another game'),
  // Learn
  'learn.eyebrow': AppTextDefault('Learn', 'Your learning'),
  'learn.subtitleWords':
      AppTextDefault('Learn', "Your words, your story and today's lesson."),
  'settings.title': AppTextDefault('Settings', 'Settings'),
  "settings.photoCredits": AppTextDefault('Settings', "Photo credits"),
  "settings.photoCreditsNote": AppTextDefault('Settings',
      "Some words have photos from Wikimedia Commons. Thank you to the people who took and shared them."),
  'settings.note':
      AppTextDefault('Settings', "Daily goal, language, sound and more"),
  'learn.title': AppTextDefault('Learn', 'Learn'),
  'learn.library': AppTextDefault('Learn', 'Word Library'),
  'learn.libraryCount':
      AppTextDefault('Learn', '{words} words • {categories} topics'),
  'learn.due': AppTextDefault('Learn', 'TO REVIEW'),
  'learn.new': AppTextDefault('Learn', 'NEW'),
  'learn.mastered': AppTextDefault('Learn', 'MASTERED'),
  'learn.startLesson': AppTextDefault('Learn', 'Start today\'s lesson'),
  'learn.findLevel': AppTextDefault('Learn', 'Find your level'),
  'learn.retakeLevel': AppTextDefault('Learn', 'Check your level again'),
  'learn.continue': AppTextDefault('Learn', 'Keep learning'),
  // Games
  'games.eyebrow': AppTextDefault('Games', 'Practice arena'),
  'games.title': AppTextDefault('Games', 'Games'),
  'games.subtitle':
      AppTextDefault('Games', 'Pick a game and beat your best score.'),
  'games.played': AppTextDefault('Games', 'PLAYED'),
  'games.level': AppTextDefault('Games', 'Lv {level}'),
  'games.best': AppTextDefault('Games', '★ {score}'),
  // Profile
  'profile.eyebrow': AppTextDefault('Profile', 'Your journey'),
  'profile.title': AppTextDefault('Profile', 'Profile'),
  'profile.subtitle':
      AppTextDefault('Profile', 'See your progress and levels here.'),
  'profile.name': AppTextDefault('Profile', 'Hnahsin {experience}'),
  'profile.xpToNext':
      AppTextDefault('Profile', '{xp}/250 XP to the next level'),
  'profile.calm': AppTextDefault('Profile', 'Calm'),
  'profile.myPace': AppTextDefault('Profile', 'My Pace'),
  'profile.dayStreak': AppTextDefault('Profile', 'Day Streak'),
  'profile.games': AppTextDefault('Profile', 'Games'),
  'profile.lessons': AppTextDefault('Profile', 'Lessons'),
  'profile.journey': AppTextDefault('Profile', 'Mizo Journey Collection'),
  'profile.journeyCount': AppTextDefault(
      'Profile', '{stories}/{total} stories • {rewards} rewards'),
  'profile.dailyGoal': AppTextDefault('Profile', 'Daily goal'),
  'profile.dailyGoalNote': AppTextDefault('Profile',
      'About one game round a minute; Home\'s ring fills when you reach it.'),
  'profile.appLanguage': AppTextDefault('Profile', 'App language'),
  'profile.appLanguageNote': AppTextDefault('Profile', 'Buttons and messages'),
  'profile.appLanguageAuto':
      AppTextDefault('Profile', 'Phone language ({language})'),
  'profile.sound': AppTextDefault('Profile', 'Sound'),
  'profile.soundNote': AppTextDefault(
      'Profile', 'Sounds and vibration for answers and finished rounds'),
  'profile.credits': AppTextDefault('Profile', 'Credits'),
  'profile.creditsBody': AppTextDefault('Profile',
      'Sentences from Mizo-Language-Corpus-4M by MWireLabs (CC BY 4.0; sources IndicNLCorp, FineWeb and DIPR Mizoram) and the Mizo–English parallel dataset by Hillbyte AI. Word checks from J.F. Laldailova\'s English–Lushai Dictionary. Word pictures from game-icons.net (CC BY 3.0), Material Design Icons, Tabler Icons, Health Icons and Phosphor Icons. Some photos from Wikimedia Commons (see Photo credits). Emoji: Microsoft Fluent Emoji (MIT).'),
  'profile.ageRange': AppTextDefault('Profile', 'Age range'),
  'profile.englishNote': AppTextDefault(
      'Profile', 'Show English beside the Mizo in stories and culture cards.'),
  'profile.xpLevel': AppTextDefault('Profile', 'Lv {level}'),
  'profile.family': AppTextDefault('Profile', 'Family-friendly'),
  'profile.familyNote': AppTextDefault(
      'Profile', 'No public chat • Progress saved on this device'),
  'profile.reduceMotion': AppTextDefault('Profile', 'Reduce motion'),
  'profile.reduceMotionNote': AppTextDefault('Profile', 'Fewer animations'),
  'profile.gentle': AppTextDefault('Profile', 'Gentle engagement'),
  'profile.gentleNote':
      AppTextDefault('Profile', 'Quests are optional, no streak pressure'),
  'profile.reset': AppTextDefault('Profile', 'Reset Local Progress'),
  'profile.resetTitle': AppTextDefault('Profile', 'Reset local progress?'),
  'profile.resetBody': AppTextDefault('Profile',
      'Your XP, scores, settings and saved game sessions on this device will be deleted. This cannot be undone.'),
  'profile.resetConfirm': AppTextDefault('Profile', 'Reset'),
  'profile.badge.older': AppTextDefault('Profile', 'Journey'),
  // Common
  'common.cancel': AppTextDefault('Common', 'Cancel'),
  'common.back': AppTextDefault('Common', 'Back'),
  'common.continue': AppTextDefault('Common', 'Continue'),
  'common.viewResults': AppTextDefault('Common', 'View Results'),
  'common.next': AppTextDefault('Common', 'Next'),
  'common.next.mizo': AppTextDefault('Common', 'Next'),
  // Word Library
  'library.count': AppTextDefault('Word Library', '{n} words'),
  'library.all': AppTextDefault('Word Library', 'All'),
  // Game screen
  'hud.relaxedSpoken': AppTextDefault('Game screen',
      'Relaxed mode. Score {score}. Progress {percent} percent.'),
  'hud.heartsSpoken':
      AppTextDefault('Game screen', '{hearts} of {total} hearts.'),
  'hud.secondsSpoken':
      AppTextDefault('Game screen', '{seconds} seconds remaining.'),
  'hud.scoreSpoken': AppTextDefault(
      'Game screen', 'Score {score}. Progress {percent} percent.'),
  'hud.relaxed': AppTextDefault('Game screen', 'Relaxed'),
  'game.restored': AppTextDefault(
      'Game screen', 'Saved game restored — picking up where you left off.'),
  'game.hintUsed': AppTextDefault('Game screen', 'Hint used'),
  'game.useHint': AppTextDefault('Game screen', 'Use a hint'),
  'answer.correctSpoken': AppTextDefault('Game screen', '{answer}, correct'),
  'answer.incorrectSpoken':
      AppTextDefault('Game screen', '{answer}, incorrect'),
  'feedback.correctSpoken': AppTextDefault('Game screen', 'Correct'),
  'feedback.retrySpoken': AppTextDefault('Game screen', 'Try again'),
  // Game result
  'result.timeUp': AppTextDefault('Game result', 'Time is up!'),
  'result.outOfHearts': AppTextDefault('Game result', 'Out of hearts!'),
  'result.done': AppTextDefault('Game result', 'You did it!'),
  'result.timeUpNote': AppTextDefault(
      'Game result', 'Time ran out. Every answer you gave is saved.'),
  'result.outOfHeartsNote': AppTextDefault(
      'Game result', 'Your score is saved. Try again and you will get better.'),
  'result.doneNote':
      AppTextDefault('Game result', 'Nice work! New words are sticking.'),
  'result.score': AppTextDefault('Game result', 'SCORE'),
  'result.accuracy': AppTextDefault('Game result', 'ACCURACY'),
  'result.xp': AppTextDefault('Game result', 'XP'),
  'result.playAgain': AppTextDefault('Game result', 'Play again'),
  'result.words': AppTextDefault('Game result', 'Words in this round'),
  'result.missedNote': AppTextDefault(
      'Game result', 'The red ones will come back next time you play.'),
  'result.levelUp': AppTextDefault('Game result', 'Level up! {from} → {to}'),
  'result.levelDown': AppTextDefault(
      'Game result', 'Level {level} — a little easier next time'),
  'result.levelProgress': AppTextDefault(
      'Game result', 'Level {level} • {percent}% to the next level'),
  // Game level
  'gameLevel.spoken': AppTextDefault('Game level', 'Level {level} of 7'),
  'gameLevel.master': AppTextDefault('Game level', 'Level 7 • Master'),
  'gameLevel.level': AppTextDefault('Game level', 'Level {level}'),
  'gameLevel.note':
      AppTextDefault('Game level', 'Words get harder as you improve.'),
  // Game start
  'launcher.howToPlay': AppTextDefault('Game start', 'HOW TO PLAY'),
  'launcher.saved': AppTextDefault('Game start', 'Saved game available'),
  'launcher.savedDetail':
      AppTextDefault('Game start', '{mode} mode • {attempts} attempts'),
  "mode.title": AppTextDefault('Game start', "PLAY MODE"),
  "mode.relaxed": AppTextDefault('Game start', "Practice"),
  "mode.relaxedNote": AppTextDefault('Game start', "No hearts to lose"),
  "mode.standard": AppTextDefault('Game start', "Classic"),
  "mode.standardNote": AppTextDefault('Game start', "3 hearts \u00b7 +25% XP"),
  "mode.timed": AppTextDefault('Game start', "Speed"),
  "mode.timedNote": AppTextDefault('Game start', "90 seconds \u00b7 +50% XP"),
  "games.howTo": AppTextDefault('Game start', "How to play"),
  "result.xpBonus": AppTextDefault('Game start', "XP +{n}%"),
  "result.newBest": AppTextDefault('Game start', "New best: {score}!"),
  'launcher.start': AppTextDefault('Game start', 'Start Game'),
  'launcher.resume': AppTextDefault('Game start', 'Resume Game'),
  'launcher.startNew': AppTextDefault('Game start', 'Start New Game'),
  // Word cards
  // Odd One Out
  "oddOne.empty": AppTextDefault(
      'Odd One Out', "There aren't enough words for this game yet."),
  "oddOne.right": AppTextDefault(
      'Odd One Out', "{three}: {group}. \u201c{odd}\u201d doesn't belong."),
  "oddOne.wrong": AppTextDefault('Odd One Out',
      "The odd one is \u201c{odd}\u201d ({oddGroup}). {three}: {group}."),
  "group.mammals": AppTextDefault('Odd One Out', "animals with four legs"),
  "group.birds": AppTextDefault('Odd One Out', "birds"),
  "group.small_creatures":
      AppTextDefault('Odd One Out', "insects and small creatures"),
  "group.water_animals":
      AppTextDefault('Odd One Out', "animals that live in water"),
  "group.fruit": AppTextDefault('Odd One Out', "fruit"),
  "group.vegetables": AppTextDefault('Odd One Out', "vegetables"),
  "group.drinks": AppTextDefault('Odd One Out', "drinks"),
  "group.meat": AppTextDefault('Odd One Out', "meat"),
  "group.head": AppTextDefault('Odd One Out', "parts of the head"),
  "group.limbs": AppTextDefault('Odd One Out', "parts of the arms and legs"),
  "group.family": AppTextDefault('Odd One Out', "family"),
  "group.jobs": AppTextDefault('Odd One Out', "people's jobs"),
  "group.sky": AppTextDefault('Odd One Out', "the sky and weather"),
  "group.land": AppTextDefault('Odd One Out', "land and water"),
  "group.house": AppTextDefault('Odd One Out', "things in a house"),
  "group.kitchen": AppTextDefault('Odd One Out', "kitchen things"),
  "group.clothes": AppTextDefault('Odd One Out', "clothes"),
  "group.school": AppTextDefault('Odd One Out', "school things"),
  "group.numbers": AppTextDefault('Odd One Out', "numbers"),
  "group.days": AppTextDefault('Odd One Out', "days of the week"),
  "group.daytime": AppTextDefault('Odd One Out', "times of day"),
  "group.colours": AppTextDefault('Odd One Out', "colours"),
  "group.music": AppTextDefault('Odd One Out', "musical instruments"),
  "group.moving": AppTextDefault('Odd One Out', "ways of moving"),
  "group.senses": AppTextDefault('Odd One Out', "seeing and hearing"),
  "group.eating": AppTextDefault('Odd One Out', "eating and drinking"),
  "group.handwork":
      AppTextDefault('Odd One Out', "sewing, weaving and knitting"),
  "group.farming": AppTextDefault('Odd One Out', "farm work"),
  "group.tastes": AppTextDefault('Odd One Out', "tastes"),
  "group.sizes": AppTextDefault('Odd One Out', "sizes and shapes"),
  "group.feelings": AppTextDefault('Odd One Out', "feelings"),
  "group.hot_cold": AppTextDefault('Odd One Out', "hot, cold, wet and dry"),
  "group.nearby_days":
      AppTextDefault('Odd One Out', "yesterday, today and tomorrow"),
  "group.questions": AppTextDefault('Odd One Out', "question words"),
  "group.plants": AppTextDefault('Odd One Out', "trees and plants"),
  "group.tools": AppTextDefault('Odd One Out', "tools"),
  'cards.title': AppTextDefault('Word cards', 'Word Cards'),
  'cards.count':
      AppTextDefault('Word cards', '{n}/{total} cards • {gold} gold'),
  'cards.how': AppTextDefault('Word cards',
      'Get a word right in two games to collect its card. Get it right four times in a row and it turns gold.'),
  'cards.new': AppTextDefault('Word cards', 'New word cards'),
  'cards.open': AppTextDefault('Word cards', 'See all'),
  'cards.cardSpoken': AppTextDefault('Word cards', '{word} card'),
  'cards.goldSpoken': AppTextDefault('Word cards', '{word}, gold card'),
  'cards.lockedSpoken': AppTextDefault('Word cards', 'Card not collected yet'),
  'cards.seenIn': AppTextDefault('Word cards', 'IN OTHER SENTENCES'),
  // Daily puzzles
  'daily.title': AppTextDefault('Daily puzzles', 'Daily puzzles'),
  'daily.subtitle':
      AppTextDefault('Daily puzzles', 'The same puzzle for everyone today'),
  'daily.eyebrow': AppTextDefault('Daily puzzles', 'DAILY PUZZLE'),
  'daily.puzzle': AppTextDefault('Daily puzzles', '{game} #{n}'),
  'daily.play': AppTextDefault('Daily puzzles', 'Play today\'s'),
  'daily.done': AppTextDefault('Daily puzzles', 'Done in {time}'),
  'daily.comeBack':
      AppTextDefault('Daily puzzles', 'A new puzzle comes tomorrow.'),
  'daily.time': AppTextDefault('Daily puzzles', 'TIME'),
  'daily.hints': AppTextDefault('Daily puzzles', 'HINTS'),
  'daily.share': AppTextDefault('Daily puzzles', 'Share'),
  'daily.copied':
      AppTextDefault('Daily puzzles', 'Copied. Paste it anywhere to share.'),
  'daily.marksSpoken':
      AppTextDefault('Daily puzzles', '{clean} of {total} words without help'),
  'daily.shareText': AppTextDefault(
      'Daily puzzles', 'Hnahsin {puzzle}\n{marks}\n⏱ {time} · 💡 {hints}'),
  // Cheers during a round
  'cheer.streak3': AppTextDefault('Games', 'Nice! {n} in a row'),
  'cheer.streak5': AppTextDefault('Games', 'On fire! {n} in a row'),
  'cheer.streak10': AppTextDefault('Games', 'Unstoppable! {n} in a row'),
  // Picture Match
  "picture.whichPicture":
      AppTextDefault('Picture Match', "Which picture is it?"),
  "picture.optionSpoken": AppTextDefault('Picture Match', "Picture {n}"),
  'picture.right': AppTextDefault('Picture Match', '{word} — {gloss}'),
  'picture.wrong': AppTextDefault(
      'Picture Match', 'The answer is “{word}”.\n{meaning}\n“{example}”'),
  // Spelling
  'spelling.clue': AppTextDefault('Spelling', 'CLUE  •  {hint}'),
  'spelling.right': AppTextDefault('Spelling', '“{word}” is complete.'),
  'spelling.wrong':
      AppTextDefault('Spelling', 'The answer is “{answer}”: “{word}”.'),
  "spelling.promptTwo": AppTextDefault('Spelling', "Fill in the two missing letters, in order"),
  "spelling.promptBuild": AppTextDefault('Spelling', "Build the word from the letter tiles"),
  "spelling.promptPick": AppTextDefault('Spelling', "Which spelling is right?"),
  "spelling.clear": AppTextDefault('Spelling', "Start again"),
  "spelling.wrongWord": AppTextDefault('Spelling', "Not quite. It is spelt {word}."),
  // Tawng Upa
  'tawngUpa.blank': AppTextDefault('Tawng Upa', 'Which word fills the blank?'),
  'tawngUpa.wrong':
      AppTextDefault('Tawng Upa', 'The answer is “{answer}”.\n{explanation}'),
  // Word Chain
  'chain.hintNone': AppTextDefault('Word Chain', 'Think of another word.'),
  'chain.hint': AppTextDefault('Word Chain', 'You could use “{word}”.'),
  'chain.word': AppTextDefault('Word Chain', '“{word}”'),
  'chain.wordMeaning': AppTextDefault('Word Chain', '“{word}” ({meaning})'),
  'chain.unknown': AppTextDefault(
      'Word Chain', 'We don\'t have this word yet. Try another one.'),
  'chain.tooShort': AppTextDefault('Word Chain', "At this level, use a word of {n} letters or more."),
  'chain.minLetters': AppTextDefault('Word Chain', "This level: {words} words, each {n} letters or more."),
  'chain.deadEnd': AppTextDefault('Word Chain',
      '“{word}” is right, but we have no word starting with “{unit}” yet. Try another one.'),
  'chain.used': AppTextDefault('Word Chain', 'You already used this word.'),
  'chain.wrongStart': AppTextDefault('Word Chain',
      '“{word}” starts with “{start}”; it needs to start with “{needed}”.'),
  'chain.linked': AppTextDefault(
      'Word Chain', '{word}\nNow link a word starting with “{unit}”.'),
  'chain.howToPlay': AppTextDefault('Word Chain', 'HOW TO PLAY'),
  'chain.rule': AppTextDefault('Word Chain',
      'Take turns with Rova: start each word with the last letter of the one before.'),
  'chain.rova': AppTextDefault('Word Chain', 'Rova'),
  'chain.example':
      AppTextDefault('Word Chain', 'Example: In → Nula → Aizawl → Lal'),
  'chain.title': AppTextDefault('Word Chain', 'Our chain'),
  'chain.needed': AppTextDefault('Word Chain', 'Start with “{unit}”'),
  'chain.input': AppTextDefault('Word Chain', 'Type a Mizo word…'),
  'chain.tip': AppTextDefault(
      'Word Chain', 'TIP  •  We know {n} words starting with “{unit}”.'),
  // Word Groups
  'groups.submit': AppTextDefault('Word Groups', 'Submit'),
  'groups.shuffle': AppTextDefault('Word Groups', 'Shuffle'),
  'groups.clear': AppTextDefault('Word Groups', 'Deselect'),
  'groups.mistakes': AppTextDefault('Word Groups', 'Mistakes left'),
  'groups.oneAway': AppTextDefault('Word Groups', 'One away!'),
  'groups.notGroup': AppTextDefault('Word Groups', 'Not a group. Try again.'),
  'groups.tried': AppTextDefault('Word Groups', 'You already tried those four.'),
  'groups.empty': AppTextDefault(
      'Word Groups', 'Not enough word groups yet. Try again when new content arrives.'),
  'groups.resultSpoken': AppTextDefault('Word Groups', 'Solved in {tries} tries'),
  'groups.groupSpoken': AppTextDefault('Word Groups', '{group}: {words}'),
  // Word Search
  'search.start': AppTextDefault(
      'Word Search', 'Swipe across a word, or tap its letters in order.'),
  'search.allFound': AppTextDefault('Word Search', 'You found every word.'),
  'search.adjacent':
      AppTextDefault('Word Search', 'Pick letters next to each other.'),
  'search.found': AppTextDefault('Word Search', 'You found “{word}”!'),
  'search.foundGloss':
      AppTextDefault('Word Search', 'You found “{word}”! ({gloss})'),
  'search.noMatch':
      AppTextDefault('Word Search', 'That\'s not one. Start again.'),
  'search.cellSpoken': AppTextDefault(
      'Word Search', 'Row {row}, column {column}, letter {letter}'),
  // Crossword
  'crossword.yourAnswer': AppTextDefault('Crossword', 'Your answer'),
  'crossword.words': AppTextDefault('Crossword', '{words} words'),
  'crossword.nearly': AppTextDefault('Crossword',
      '{subject} is very close! The red letter needs â, ê, î, ô, û or ṭ.'),
  'crossword.wrong': AppTextDefault('Crossword',
      '{subject} isn\'t right. Change the red letters and try again.'),
  'crossword.across': AppTextDefault('Crossword', 'Across →'),
  'crossword.down': AppTextDefault('Crossword', 'Down ↓'),
  'crossword.previous': AppTextDefault('Crossword', 'Previous clue'),
  'crossword.next': AppTextDefault('Crossword', 'Next clue'),
  'crossword.clueAcross':
      AppTextDefault('Crossword', '{n} ACROSS →  •  {letters} LETTERS'),
  'crossword.clueDown':
      AppTextDefault('Crossword', '{n} DOWN ↓  •  {letters} LETTERS'),
  'crossword.cellEmptySpoken':
      AppTextDefault('Crossword', 'Row {row}, column {column}, empty'),
  'crossword.cellSpoken': AppTextDefault(
      'Crossword', 'Row {row}, column {column}, letter {letter}'),
  'crossword.erase': AppTextDefault('Crossword', 'Erase'),
  // Sentence Builder
  'sentence.title': AppTextDefault('Sentence Builder', 'Sentence Builder'),
  'sentence.empty':
      AppTextDefault('Sentence Builder', 'Sentence content is not available.'),
  'sentence.usingWord':
      AppTextDefault('Sentence Builder', 'SENTENCE USING THIS WORD'),
  'sentence.yours': AppTextDefault('Sentence Builder', 'YOUR SENTENCE'),
  'sentence.extraWords': AppTextDefault('Sentence Builder', "Not every tile belongs: leave out the extra words."),
  'sentence.right':
      AppTextDefault('Sentence Builder', '{sentence} — Well built!'),
  'sentence.wrong': AppTextDefault('Sentence Builder',
      'The order isn\'t right yet. Look at “{sentence}” and try again.'),
  'sentence.check': AppTextDefault('Sentence Builder', 'Check Sentence'),
  'sentence.finish': AppTextDefault('Sentence Builder', 'Finish'),
  'sentence.next': AppTextDefault('Sentence Builder', 'Next Sentence'),
  'sentence.retry': AppTextDefault('Sentence Builder', 'Try Again'),
  'sentence.gapPrompt':
      AppTextDefault('Sentence Builder', 'WHICH WORD IS MISSING?'),
  'sentence.gapRight':
      AppTextDefault('Sentence Builder', '{sentence} — That\'s the word!'),
  'sentence.gapWrong': AppTextDefault(
      'Sentence Builder', 'That word doesn\'t fit. Try another one.'),
  // Level check
  'placement.empty': AppTextDefault('Level check', 'No words to learn yet.'),
  'placement.prompt': AppTextDefault('Level check', 'Pick the closest meaning'),
  'placement.seeLevel': AppTextDefault('Level check', 'See your level'),
  'placement.skip': AppTextDefault('Level check', 'Start from Level 1'),
  'placement.result': AppTextDefault('Level check', 'Your starting level'),
  'placement.title': AppTextDefault('Level check', 'Level check'),
  'placement.question': AppTextDefault('Level check', 'Question {n}/{total}'),
  'placement.score': AppTextDefault(
      'Level check', '{correct} of {total} right • {description}'),
  // Daily lesson
  'lesson.prompt': AppTextDefault('Daily lesson', 'Pick the meaning'),
  'lesson.finish': AppTextDefault('Daily lesson', 'Finish lesson'),
  'lesson.caughtUp': AppTextDefault('Daily lesson', 'You\'re all caught up!'),
  'lesson.caughtUpNote':
      AppTextDefault('Daily lesson', 'No words to review right now.'),
  'lesson.back': AppTextDefault('Daily lesson', 'Go back'),
  'lesson.completeTitle': AppTextDefault('Daily lesson', 'Lesson complete'),
  'lesson.complete':
      AppTextDefault('Daily lesson', 'You finished today\'s lesson!'),
  'lesson.newWord': AppTextDefault('Daily lesson', 'NEW WORD'),
  'lesson.title': AppTextDefault('Daily lesson', 'Today\'s lesson'),
  'lesson.score': AppTextDefault('Daily lesson',
      '{correct} of {total} right • We\'ll bring these words back at the right time.'),
  'lesson.right': AppTextDefault('Daily lesson', 'Correct! “{example}”'),
  'lesson.wrong':
      AppTextDefault('Daily lesson', 'The answer is “{answer}”. {example}'),
  // Levels
  'level.code': AppTextDefault('Levels', 'Level {n}'),
  'level.1.title': AppTextDefault('Levels', 'First Steps'),
  'level.1.description':
      AppTextDefault('Levels', 'Start with basic words and pictures'),
  'level.2.title': AppTextDefault('Levels', 'Everyday Words'),
  'level.2.description':
      AppTextDefault('Levels', 'Everyday words and short sentences'),
  'level.3.title': AppTextDefault('Levels', 'Growing Speaker'),
  'level.3.description':
      AppTextDefault('Levels', 'Conversation, spelling and reading'),
  'level.4.title': AppTextDefault('Levels', 'Confident Reader'),
  'level.4.description':
      AppTextDefault('Levels', 'Longer sentences and meaning'),
  'level.5.title': AppTextDefault('Levels', 'Storyteller'),
  'level.5.description': AppTextDefault('Levels', 'Stories and accounts'),
  'level.6.title': AppTextDefault('Levels', 'Explorer'),
  'level.6.description': AppTextDefault('Levels', 'Places and way of life'),
  'level.7.title': AppTextDefault('Levels', 'Culture Apprentice'),
  'level.7.description': AppTextDefault('Levels', 'Old sayings and grammar'),
  'level.8.title': AppTextDefault('Levels', 'Culture & Fluency'),
  'level.8.description':
      AppTextDefault('Levels', 'Old sayings, heritage and full fluency'),
  'mastery.unseen': AppTextDefault('Levels', 'New'),
  'mastery.learning': AppTextDefault('Levels', 'Learning'),
  'mastery.familiar': AppTextDefault('Levels', 'Familiar'),
  'mastery.strong': AppTextDefault('Levels', 'Strong'),
  'mastery.mastered': AppTextDefault('Levels', 'Mastered'),
  // Onboarding
  'age.early': AppTextDefault('Onboarding', 'Ages 5–7'),
  'age.young': AppTextDefault('Onboarding', 'Ages 8–13'),
  'age.teen': AppTextDefault('Onboarding', 'Ages 14–17'),
  'age.adult': AppTextDefault('Onboarding', 'Adult'),
  'age.early.note':
      AppTextDefault('Onboarding', 'Start with pictures and games'),
  'age.young.note':
      AppTextDefault('Onboarding', 'Learn with words, spelling and stories'),
  'age.teen.note':
      AppTextDefault('Onboarding', 'Reading, conversation and culture'),
  'age.adult.note': AppTextDefault('Onboarding', 'Learn Mizo at your own pace'),
  'proficiency.new': AppTextDefault('Onboarding', 'I\'m new to Mizo'),
  'proficiency.some': AppTextDefault('Onboarding', 'I understand some'),
  'proficiency.speaks': AppTextDefault('Onboarding', 'I can speak Mizo'),
  'proficiency.reads': AppTextDefault('Onboarding', 'I can read and write'),
  'proficiency.new.note':
      AppTextDefault('Onboarding', 'Guide me from the very first words'),
  'proficiency.some.note': AppTextDefault(
      'Onboarding', 'I know a little and want to speak and read'),
  'proficiency.speaks.note':
      AppTextDefault('Onboarding', 'I want better spelling and reading'),
  'proficiency.reads.note':
      AppTextDefault('Onboarding', 'I want old sayings and harder skills'),
  'goal.conversation': AppTextDefault('Onboarding', 'Home Conversation'),
  'goal.vocabulary': AppTextDefault('Onboarding', 'Words & Spelling'),
  'goal.reading': AppTextDefault('Onboarding', 'Reading'),
  'goal.culture': AppTextDefault('Onboarding', 'Culture'),
  'goal.refresh': AppTextDefault('Onboarding', 'Refresh My Mizo'),
  'support.english': AppTextDefault('Onboarding', 'English support'),
  'support.mizoOnly': AppTextDefault('Onboarding', 'Mizo only'),
  'profile.badge.early': AppTextDefault('Onboarding', 'Sprout'),
  'profile.badge.young': AppTextDefault('Onboarding', 'Explorer'),
  'onboarding.brand': AppTextDefault('Onboarding', 'HNAHSIN'),
  'onboarding.stepSpoken': AppTextDefault('Onboarding', 'Step {n} of {total}'),
  'onboarding.goalLimit':
      AppTextDefault('Onboarding', 'Choose up to two learning goals.'),
  'onboarding.start': AppTextDefault('Onboarding', 'Start My Journey'),
  'onboarding.finish': AppTextDefault('Onboarding', 'Build My Learning Path'),
  'welcome.eyebrow': AppTextDefault('Onboarding', 'Word games from Mizoram'),
  'welcome.title': AppTextDefault('Onboarding', 'Play games. Pick up Mizo.'),
  'welcome.path': AppTextDefault('Onboarding', 'A path built for you'),
  'welcome.pathNote':
      AppTextDefault('Onboarding', 'Games that match what you know.'),
  'welcome.offline': AppTextDefault('Onboarding', 'Learn anywhere'),
  'welcome.offlineNote':
      AppTextDefault('Onboarding', 'Core games work offline on your device.'),
  'welcome.safe': AppTextDefault('Onboarding', 'Safe for families'),
  'welcome.safeNote': AppTextDefault(
      'Onboarding', 'No public chat, ads, or child leaderboard.'),
  'age.eyebrow': AppTextDefault('Onboarding', 'Personalize your path'),
  'age.title': AppTextDefault('Onboarding', 'Who is learning?'),
  'age.subtitle': AppTextDefault(
      'Onboarding', 'We only need an age range — no birthday or name.'),
  'proficiency.eyebrow':
      AppTextDefault('Onboarding', 'Find your starting point'),
  'proficiency.title':
      AppTextDefault('Onboarding', 'How much Mizo do you know?'),
  'proficiency.subtitle': AppTextDefault(
      'Onboarding', 'Pick honestly — you can change it any time in Profile.'),
  'goal.eyebrow': AppTextDefault('Onboarding', 'Choose up to two'),
  'goal.title': AppTextDefault('Onboarding', 'What would you like to learn?'),
  'goal.subtitle': AppTextDefault('Onboarding',
      'Pick what matters most and we\'ll put it first in your daily quests.'),
  'rhythm.eyebrow': AppTextDefault('Onboarding', 'Ready for your first quest'),
  'rhythm.title': AppTextDefault('Onboarding', 'Set your daily rhythm.'),
  'rhythm.subtitle': AppTextDefault(
      'Onboarding', 'A little every day is the best way to learn.'),
  'welcome.subtitle': AppTextDefault(
      'Onboarding', 'Fun word games. You\'ll learn Mizo words as you play.'),
  'rhythm.goal': AppTextDefault('Onboarding', 'DAILY GOAL'),
  'rhythm.minutes': AppTextDefault('Onboarding', '{n} min'),
  'rhythm.privacy': AppTextDefault(
      'Onboarding', 'Guest-first • Progress stays on this device'),
  // Profile • learning level
  'track.beginner': AppTextDefault('Profile • learning level', 'Beginner'),
  'track.explorer': AppTextDefault('Profile • learning level', 'Explorer'),
  'track.master': AppTextDefault('Profile • learning level', 'Master'),
  'track.beginner.note': AppTextDefault(
      'Profile • learning level', 'Start with pictures and easy words'),
  'track.explorer.note': AppTextDefault(
      'Profile • learning level', 'Keep going with spelling and puzzles'),
  'track.master.note':
      AppTextDefault('Profile • learning level', 'Old sayings and proverbs'),
  // Word categories
  'category.chhungkua': AppTextDefault('Word categories', 'Family'),
  'category.sikul': AppTextDefault('Word categories', 'School'),
  'category.nungcha': AppTextDefault('Word categories', 'Animals'),
  'category.khawvel': AppTextDefault('Word categories', 'World'),
  'category.nunphung': AppTextDefault('Word categories', 'Way of life'),
  'category.thiltih': AppTextDefault('Word categories', 'Actions'),
  // Journey
  'journey.title': AppTextDefault('Journey', 'Mizo Journey'),
  'journey.subtitle':
      AppTextDefault('Journey', 'Story, conversation & culture'),
  'journey.todaysQuests': AppTextDefault('Journey', 'Today\'s Quests'),
  'journey.map': AppTextDefault('Journey', 'Journey Map'),
  'journey.cultureTrail': AppTextDefault('Journey', 'Culture Trail'),
  'journey.cultureTrailNote':
      AppTextDefault('Journey', 'Words, values & living culture'),
  'journey.cultureCount': AppTextDefault(
      'Journey', '{collected}/{total} cards • Tawng Upa context'),
  'journey.eyebrow': AppTextDefault('Journey', 'YOUR MIZO JOURNEY'),
  'journey.progress':
      AppTextDefault('Journey', '{done} of {total} story stops complete'),
  'journey.rhythm': AppTextDefault('Journey', 'Learning rhythm'),
  'journey.rhythmDays': AppTextDefault('Journey', '{n} day rhythm'),
  'journey.graceReady': AppTextDefault('Journey', 'Grace ready'),
  'journey.graceUsed': AppTextDefault('Journey', 'Grace used'),
  'journey.thisWeek': AppTextDefault('Journey', '{n}/3 this week'),
  'journey.trailMarks': AppTextDefault('Journey', '{n} Trail Marks'),
  'journey.welcomeBack': AppTextDefault('Journey', 'Welcome back'),
  'journey.welcomeBackNote': AppTextDefault('Journey',
      'Your progress is safe. Pick the story back up in just a few minutes.'),
  'journey.dailyGentle':
      AppTextDefault('Journey', 'OPTIONAL DAILY • NO PENALTY'),
  'journey.daily': AppTextDefault('Journey', 'DAILY'),
  'journey.weeklyGentle':
      AppTextDefault('Journey', 'OPTIONAL WEEKLY • NO DEADLINE'),
  'journey.weekly': AppTextDefault('Journey', 'WEEKLY • NO COUNTDOWN'),
  'journey.claim': AppTextDefault('Journey', 'Claim +{n}'),
  'journey.preview': AppTextDefault(
      'Journey', 'Preview content — awaiting Mizo language review.'),
  'journey.nodeSpoken': AppTextDefault('Journey', '{title}, {status}'),
  'journey.nodeLevel': AppTextDefault('Journey', 'Level {n}'),
  'journey.nodeCards': AppTextDefault('Journey', '{have}/{n} cards'),
  'journey.chapters': AppTextDefault('Journey', 'The story'),
  'journey.replay': AppTextDefault('Journey', 'REPLAY'),
  'journey.start': AppTextDefault('Journey', 'START'),
  'journey.collection': AppTextDefault('Journey', 'My Collection'),
  'journey.viewAll': AppTextDefault('Journey', 'View All'),
  'journey.firstReward': AppTextDefault('Journey',
      'You\'ll earn a reward when you finish your first Story Quest.'),
  'story.title': AppTextDefault('Journey', 'Story Quest'),
  'story.chooseReply': AppTextDefault('Journey', 'Choose a natural reply'),
  'story.words': AppTextDefault('Journey', 'WORDS IN THIS CHAPTER'),
  'story.tryAgain':
      AppTextDefault('Journey', 'That doesn\'t fit here. Try another reply.'),
  'story.complete': AppTextDefault('Journey', 'Complete Story'),
  'story.completeTitle': AppTextDefault('Journey', 'Story Complete'),
  'story.wellDone': AppTextDefault('Journey', 'Well done!'),
  'story.reward': AppTextDefault('Journey', 'Story reward'),
  'story.cultureMoment': AppTextDefault('Journey', 'CULTURE MOMENT'),
  'story.saved': AppTextDefault('Journey', 'Saved'),
  'story.read': AppTextDefault('Journey', 'I read this'),
  'story.stop': AppTextDefault('Journey', 'A good stopping point'),
  'story.stopNote': AppTextDefault('Journey',
      'That\'s enough for today. Come back tomorrow and keep going.'),
  'story.finish': AppTextDefault('Journey', 'Finish for Now'),
  'story.stepSpoken': AppTextDefault('Journey', 'Story step {n} of {total}'),
  'story.conversation':
      AppTextDefault('Journey', 'Conversation {n} of {total}'),
  // Culture
  'culture.title': AppTextDefault('Culture', 'Culture Trail'),
  'culture.collected': AppTextDefault('Culture', '{n}/{total} cards collected'),
  'culture.eyebrow': AppTextDefault('Culture', 'MIZO CULTURE TRAIL'),
  'culture.intro':
      AppTextDefault('Culture', 'Learn words, culture and how they are used.'),
  'culture.marks':
      AppTextDefault('Culture', '{n} Trail Marks • Lessons stay open'),
  'culture.cards': AppTextDefault('Culture', 'Culture Cards'),
  'culture.preview': AppTextDefault(
      'Culture', 'Preview content — awaiting language and culture review.'),
  'culture.noDeadline': AppTextDefault('Culture', 'NO DEADLINE'),
  'culture.unlockAt': AppTextDefault('Culture', 'Unlock at Level {n}'),
  'culture.keepLearning':
      AppTextDefault('Culture', 'Keep learning to reach this level.'),
  'culture.cardTitle': AppTextDefault('Culture', 'Culture Card'),
  'culture.usage':
      AppTextDefault('Culture', 'How it is used and what it means'),
  'culture.example': AppTextDefault('Culture', 'Example'),
  'culture.readToday': AppTextDefault('Culture', 'Read Today'),
  'culture.readAgain': AppTextDefault('Culture', 'Read Again'),
  'culture.add': AppTextDefault('Culture', 'Add to Collection'),
  'culture.report': AppTextDefault('Culture', 'Report a Content Issue'),
  'collection.title': AppTextDefault('Culture', 'My Collection'),
  'collection.count': AppTextDefault('Culture', '{n}/{total} culture cards'),
  'collection.marks': AppTextDefault('Culture', '{n} Trail Marks'),
  'collection.note':
      AppTextDefault('Culture', 'Recognition only • No lesson is locked'),
  'collection.style': AppTextDefault('Culture', 'Choose My Style'),
  'collection.milestones': AppTextDefault('Culture', 'Milestones'),
  'collection.firstCard':
      AppTextDefault('Culture', 'Read your first card on the Culture Trail.'),
  'collection.rewards': AppTextDefault('Culture', 'Story Rewards'),
  'collection.firstReward': AppTextDefault('Culture',
      'You\'ll earn a reward when you finish your first Story Quest.'),
  'collection.avatarLocked':
      AppTextDefault('Culture', '{avatar} • {marks} marks'),
  // Journey quests
  'quest.story': AppTextDefault('Journey quests', 'Story Step'),
  'quest.story.note':
      AppTextDefault('Journey quests', 'Finish one Story Quest.'),
  'quest.words': AppTextDefault('Journey quests', 'Word Keeper'),
  'quest.words.note': AppTextDefault('Journey quests', 'Review three words.'),
  'quest.culture': AppTextDefault('Journey quests', 'Culture Moment'),
  'quest.culture.note':
      AppTextDefault('Journey quests', 'Read one culture note.'),
  'quest.storyWeek': AppTextDefault('Journey quests', 'Story Week'),
  'quest.storyWeek.note':
      AppTextDefault('Journey quests', 'Finish three Story Quests this week.'),
  'quest.cultureWeek': AppTextDefault('Journey quests', 'Culture Trail Week'),
  'quest.cultureWeek.note':
      AppTextDefault('Journey quests', 'Read three Culture Cards this week.'),
};
