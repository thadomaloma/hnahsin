/// Every label, button and message in the app, by ID, with the text it shows
/// unless the content Sheet's “App text” tab says otherwise. The Sheet's rows
/// are made from [appTextDefaults], so a new text here needs a new row there
/// (content_studio/README.md).
library;

/// One text's built-in wording and where in the app it shows.
class AppTextDefault {
  const AppTextDefault(this.where, this.text);

  /// The screen or part of the app, so an editor can find it.
  final String where;
  final String text;
}

/// The `{name}` placeholders in [text], which the app fills in.
Set<String> appTextPlaceholders(String text) =>
    RegExp(r'\{(\w+)\}').allMatches(text).map((match) => match[1]!).toSet();

abstract final class AppText {
  static Map<String, String> _delivered = const <String, String>{};

  /// The Sheet's texts from the active content pack.
  static void update(Map<String, String> delivered) => _delivered = delivered;

  /// [id]'s text with its `{name}` placeholders filled from [values]. Sheet
  /// text is used only when it has the same placeholders as the built-in
  /// text, so a typo there can't show a raw `{name}` or drop a number.
  static String of(String id,
      [Map<String, Object?> values = const <String, Object?>{}]) {
    final fallback = appTextDefaults[id]?.text ?? id;
    final sheet = _delivered[id];
    var text = sheet != null &&
            _sameSet(appTextPlaceholders(sheet), appTextPlaceholders(fallback))
        ? sheet
        : fallback;
    values.forEach(
        (name, value) => text = text.replaceAll('{$name}', '${value ?? ''}'));
    return text;
  }

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

const appTextDefaults = <String, AppTextDefault>{
  // Content review
  'review.title':
      AppTextDefault('Content review', 'Content review in progress'),
  'review.body': AppTextDefault('Content review',
      'Mizo tawng content hi qualified reviewer-te pawmna kan nghah mêk a ni. Public release-ah draft content kan lantîr lo.'),
  // Navigation
  'nav.home': AppTextDefault('Navigation', 'Home'),
  'nav.learn': AppTextDefault('Navigation', 'Learn'),
  'nav.games': AppTextDefault('Navigation', 'Games'),
  'nav.profile': AppTextDefault('Navigation', 'Profile'),
  // Profile • content
  'content.offline': AppTextDefault('Profile • content', 'Offline content'),
  'content.version': AppTextDefault('Profile • content', 'Content {version}'),
  'content.check': AppTextDefault('Profile • content', 'Check for Updates'),
  'content.builtIn': AppTextDefault('Profile • content', 'Built-in Pack'),
  'sync.builtInReady': AppTextDefault(
      'Profile • content', 'Built-in learning content is ready offline.'),
  'sync.packsReady':
      AppTextDefault('Profile • content', 'Verified offline packs are ready.'),
  'sync.checking':
      AppTextDefault('Profile • content', 'Checking reviewed content packs…'),
  'sync.updated': AppTextDefault(
      'Profile • content', 'Reviewed offline packs updated safely.'),
  'sync.upToDate':
      AppTextDefault('Profile • content', 'Offline packs are up to date.'),
  'sync.rejected': AppTextDefault('Profile • content',
      'Unsafe update rejected. Verified compatible offline content remains available. {error}'),
  'sync.unavailable': AppTextDefault('Profile • content',
      'Update unavailable. Verified compatible offline content remains available.'),
  // Content report
  'report.done': AppTextDefault('Content report', 'Issue reported'),
  'report.open': AppTextDefault('Content report', 'Report content issue'),
  'report.title': AppTextDefault('Content report', 'Report a content issue'),
  'report.privacy': AppTextDefault('Content report',
      'No personal message is collected. The content reference and reason stay on this device for the review queue.'),
  'report.spelling':
      AppTextDefault('Content report', 'Mizo spelling or wording'),
  'report.meaning': AppTextDefault('Content report', 'Meaning or translation'),
  'report.picture': AppTextDefault('Content report', 'Picture does not match'),
  'report.culture': AppTextDefault('Content report', 'Cultural context'),
  'report.save': AppTextDefault('Content report', 'Save Report'),
  'report.saved': AppTextDefault(
      'Content report', 'Report saved to the local review queue.'),
  // Home
  'home.games': AppTextDefault('Home', 'Games'),
  'home.viewAll': AppTextDefault('Home', 'View All'),
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
  'home.todaysGame': AppTextDefault('Home', 'VAWIIN GAME'),
  'home.best': AppTextDefault('Home', 'Best {score}'),
  'home.replay': AppTextDefault('Home', 'Thumal {n} i hmuh leh tur a awm'),
  'home.roundsToday': AppTextDefault('Home', '{done}/{goal}\nKHELH'),
  'home.rhythm': AppTextDefault('Home', 'Learning rhythm'),
  'home.streak': AppTextDefault('Home', '{n} day streak'),
  'home.startToday': AppTextDefault('Home', 'Vawiin ṭan rawh'),
  'home.play': AppTextDefault('Home', 'Khel rawh'),
  'home.otherGame': AppTextDefault('Home', 'Game dang khel rawh'),
  // Learn
  'learn.eyebrow': AppTextDefault('Learn', 'I zirna'),
  'learn.title': AppTextDefault('Learn', 'Learn'),
  'learn.subtitle': AppTextDefault(
      'Learn', '{level} {title} • Mahni chak zawngin zir chhunzawm rawh.'),
  'learn.library': AppTextDefault('Learn', 'Word Library'),
  'learn.libraryCount':
      AppTextDefault('Learn', 'Thumal {words} • Chi {categories}'),
  'learn.due': AppTextDefault('Learn', 'EN LEH TUR'),
  'learn.new': AppTextDefault('Learn', 'THAR'),
  'learn.mastered': AppTextDefault('Learn', 'THIAM TAWH'),
  'learn.startLesson': AppTextDefault('Learn', 'Vawiin zirna ṭan rawh'),
  'learn.findLevel': AppTextDefault('Learn', 'I level hre chhuak rawh'),
  'learn.retakeLevel': AppTextDefault('Learn', 'Level en leh rawh'),
  'learn.continue': AppTextDefault('Learn', 'Zir chhunzawm rawh'),
  // Games
  'games.eyebrow': AppTextDefault('Games', 'Practice arena'),
  'games.title': AppTextDefault('Games', 'Games'),
  'games.subtitle': AppTextDefault(
      'Games', 'I duh zawng thlang la, i score sang ber siam rawh.'),
  'games.played': AppTextDefault('Games', 'PLAYED'),
  'games.level': AppTextDefault('Games', 'Lv {level}'),
  'games.best': AppTextDefault('Games', '★ {score}'),
  'games.play': AppTextDefault('Games', 'PLAY'),
  // Profile
  'profile.eyebrow': AppTextDefault('Profile', 'Your journey'),
  'profile.title': AppTextDefault('Profile', 'Profile'),
  'profile.subtitle':
      AppTextDefault('Profile', 'I zirna progress leh level-te hetah en rawh.'),
  'profile.name': AppTextDefault('Profile', 'Thumal {experience}'),
  'profile.xpToNext': AppTextDefault('Profile', '{xp}/250 XP level thar atan'),
  'profile.calm': AppTextDefault('Profile', 'Calm'),
  'profile.myPace': AppTextDefault('Profile', 'My Pace'),
  'profile.dayStreak': AppTextDefault('Profile', 'Day Streak'),
  'profile.games': AppTextDefault('Profile', 'Games'),
  'profile.lessons': AppTextDefault('Profile', 'Lessons'),
  'profile.journey': AppTextDefault('Profile', 'Mizo Journey Collection'),
  'profile.journeyCount': AppTextDefault(
      'Profile', '{stories}/{total} stories • {rewards} rewards'),
  'profile.settings': AppTextDefault('Profile', 'My settings'),
  'profile.dailyGoal': AppTextDefault('Profile', 'Daily goal'),
  'profile.dailyGoalNote': AppTextDefault('Profile',
      'About one game round a minute; Home’s ring fills when you reach it.'),
  'profile.ageRange': AppTextDefault('Profile', 'Age range'),
  'profile.englishNote': AppTextDefault(
      'Profile', 'Show English beside the Mizo in stories and culture cards.'),
  'profile.xpLevel': AppTextDefault('Profile', 'Lv {level}'),
  'profile.family': AppTextDefault('Profile', 'Family-friendly'),
  'profile.familyNote': AppTextDefault(
      'Profile', 'No public chat • Progress saved on this device'),
  'profile.reduceMotion': AppTextDefault('Profile', 'Reduce motion'),
  'profile.reduceMotionNote':
      AppTextDefault('Profile', 'Use fewer interface animations'),
  'profile.gentle': AppTextDefault('Profile', 'Gentle engagement'),
  'profile.gentleNote': AppTextDefault(
      'Profile', 'Keep quests optional and hide streak pressure'),
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
  'common.next.mizo': AppTextDefault('Common', 'A dawt'),
  // Word Library
  'library.count': AppTextDefault('Word Library', 'Thumal {n}'),
  'library.all': AppTextDefault('Word Library', 'Zawng zawng'),
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
  'game.restored': AppTextDefault('Game screen',
      'Saved game restored — i khelhna hmasa kha kan chhunzawm e.'),
  'game.hintUsed': AppTextDefault('Game screen', 'Hint used'),
  'game.useHint': AppTextDefault('Game screen', 'Use a hint'),
  'answer.correctSpoken': AppTextDefault('Game screen', '{answer}, correct'),
  'answer.incorrectSpoken':
      AppTextDefault('Game screen', '{answer}, incorrect'),
  'feedback.correctSpoken': AppTextDefault('Game screen', 'Correct'),
  'feedback.retrySpoken': AppTextDefault('Game screen', 'Try again'),
  // Game result
  'result.timeUp': AppTextDefault('Game result', 'Time is up!'),
  'result.outOfHearts': AppTextDefault('Game result', 'Tunah chuan a tâwk e!'),
  'result.done': AppTextDefault('Game result', 'I ti thei e!'),
  'result.timeUpNote': AppTextDefault(
      'Game result', 'Hun a tâwp ta. I chhân tawhte chu a save vek e.'),
  'result.outOfHeartsNote': AppTextDefault(
      'Game result', 'I score chu a save tawh. Tum leh la, i thiam chho ang.'),
  'result.doneNote': AppTextDefault(
      'Game result', 'Khelh pahin Mizo tawng i thiam chho zêl e.'),
  'result.score': AppTextDefault('Game result', 'SCORE'),
  'result.accuracy': AppTextDefault('Game result', 'ACCURACY'),
  'result.xp': AppTextDefault('Game result', 'XP'),
  'result.playAgain': AppTextDefault('Game result', 'Khelh leh'),
  'result.words': AppTextDefault('Game result', 'Thumal i hmuh te'),
  'result.missedNote': AppTextDefault(
      'Game result', 'A sen te hi i khelh leh hunah an lo lang leh ang.'),
  'result.levelUp': AppTextDefault('Game result', 'Level up! {from} → {to}'),
  'result.levelDown': AppTextDefault(
      'Game result', 'Level {level} — awlsam deuhvin kan tan leh ang'),
  'result.levelProgress': AppTextDefault(
      'Game result', 'Level {level} • {percent}% level thar thlengin'),
  // Game level
  'gameLevel.spoken': AppTextDefault('Game level', 'Level {level} of 7'),
  'gameLevel.master': AppTextDefault('Game level', 'Level 7 • Master'),
  'gameLevel.level': AppTextDefault('Game level', 'Level {level}'),
  'gameLevel.note': AppTextDefault(
      'Game level', 'I thiam chhoh dan zirin thumal a harsa chho zel ang.'),
  // Game start
  'launcher.howToPlay': AppTextDefault('Game start', 'HOW TO PLAY'),
  'launcher.saved': AppTextDefault('Game start', 'Saved game available'),
  'launcher.savedDetail':
      AppTextDefault('Game start', '{mode} mode • {attempts} attempts'),
  'launcher.modeName.relaxed': AppTextDefault('Game start', 'relaxed'),
  'launcher.modeName.standard': AppTextDefault('Game start', 'standard'),
  'launcher.modeName.timed': AppTextDefault('Game start', 'timed'),
  'launcher.chooseMode': AppTextDefault('Game start', 'Choose a mode'),
  'launcher.relaxed':
      AppTextDefault('Game start', 'Relaxed — Heart chân lovin khel'),
  'launcher.standard': AppTextDefault('Game start', 'Standard — Heart 3 nen'),
  'launcher.timed': AppTextDefault('Game start', 'Timed — Second 90 chhungin'),
  'launcher.start': AppTextDefault('Game start', 'Start Game'),
  'launcher.resume': AppTextDefault('Game start', 'Resume Game'),
  'launcher.startNew': AppTextDefault('Game start', 'Start New Game'),
  // Picture Match
  'picture.right': AppTextDefault('Picture Match', '{word} — {gloss}'),
  'picture.wrong': AppTextDefault('Picture Match',
      'Chhanna dik chu “{word}” a ni.\n{meaning}\n“{example}”'),
  // Spelling
  'spelling.clue': AppTextDefault('Spelling', 'CLUE  •  {hint}'),
  'spelling.right': AppTextDefault('Spelling', '“{word}” a kim ta.'),
  'spelling.wrong':
      AppTextDefault('Spelling', 'Chhanna dik chu “{answer}” a ni: “{word}”.'),
  // Tawng Upa
  'tawngUpa.blank':
      AppTextDefault('Tawng Upa', 'A ruak-ah eng thumal nge a lut ang?'),
  'tawngUpa.wrong': AppTextDefault(
      'Tawng Upa', 'Chhanna dik chu “{answer}” a ni.\n{explanation}'),
  // Word Chain
  'chain.hintNone':
      AppTextDefault('Word Chain', 'A thumal dang ngaihtuah rawh.'),
  'chain.hint': AppTextDefault('Word Chain', '“{word}” i hmang thei.'),
  'chain.word': AppTextDefault('Word Chain', '“{word}”'),
  'chain.wordMeaning': AppTextDefault('Word Chain', '“{word}” ({meaning})'),
  'chain.unknown': AppTextDefault('Word Chain',
      'He thumal hi kan thumal dahkhâwmnaah a la awm lo. Thumal dang ziak rawh.'),
  'chain.deadEnd': AppTextDefault('Word Chain',
      '“{word}” a dik, mahse “{unit}” hmanga bulṭan thumal kan la nei lo. Thumal dang ziak rawh.'),
  'chain.used': AppTextDefault('Word Chain', 'He thumal hi i hmang tawh.'),
  'chain.wrongStart': AppTextDefault('Word Chain',
      '“{word}” chu “{start}” hmangin a inṭan; “{needed}” hmanga bulṭan tûr a ni.'),
  'chain.linked':
      AppTextDefault('Word Chain', '{word}\n“{unit}” hmanga zawm leh rawh.'),
  'chain.howToPlay': AppTextDefault('Word Chain', 'HOW TO PLAY'),
  'chain.rule': AppTextDefault('Word Chain',
      'Thumal tawpna hawrawp inzawm hmangin thumal dang bulṭan rawh.'),
  'chain.example':
      AppTextDefault('Word Chain', 'Entîrna: In → Nula → Aizawl → Lal'),
  'chain.title': AppTextDefault('Word Chain', 'Kan chain'),
  'chain.start': AppTextDefault('Word Chain', 'Inṭanna: {word}'),
  'chain.needed': AppTextDefault('Word Chain', '“{unit}” hmanga bulṭan rawh'),
  'chain.input': AppTextDefault('Word Chain', 'Mizo thumal ziak rawh…'),
  'chain.tip': AppTextDefault(
      'Word Chain', 'TIP  •  “{unit}” hmanga bulṭan thumal {n} kan nei.'),
  // Word Search
  'search.start': AppTextDefault('Word Search', 'Letter-te indawtin tap rawh.'),
  'search.allFound':
      AppTextDefault('Word Search', 'Thumal zawng zawng i hmu tawh.'),
  'search.adjacent':
      AppTextDefault('Word Search', 'Letter bul hnai indawtin thlang rawh.'),
  'search.found': AppTextDefault('Word Search', '“{word}” i hmu ta!'),
  'search.foundGloss':
      AppTextDefault('Word Search', '“{word}” i hmu ta! ({gloss})'),
  'search.noMatch':
      AppTextDefault('Word Search', 'A rem lo. Bulṭan nawn leh rawh.'),
  'search.cellSpoken': AppTextDefault(
      'Word Search', 'Row {row}, column {column}, letter {letter}'),
  // Crossword
  'crossword.yourAnswer': AppTextDefault('Crossword', 'I chhanna'),
  'crossword.words': AppTextDefault('Crossword', 'Thumal {words}'),
  'crossword.nearly': AppTextDefault('Crossword',
      '{subject} a hnaih hle! Hawrawp sen chu â, ê, î, ô, û emaw ṭ emaw a ni ang.'),
  'crossword.wrong': AppTextDefault('Crossword',
      '{subject} a dik lo. Hawrawp sen te thlak la, tum leh rawh.'),
  'crossword.across': AppTextDefault('Crossword', 'Across →'),
  'crossword.down': AppTextDefault('Crossword', 'Down ↓'),
  'crossword.previous': AppTextDefault('Crossword', 'Previous clue'),
  'crossword.next': AppTextDefault('Crossword', 'Next clue'),
  'crossword.clueAcross':
      AppTextDefault('Crossword', '{n} ACROSS →  •  {letters} HAWRAWP'),
  'crossword.clueDown':
      AppTextDefault('Crossword', '{n} DOWN ↓  •  {letters} HAWRAWP'),
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
  'sentence.right':
      AppTextDefault('Sentence Builder', '{sentence} — A rem dik e.'),
  'sentence.wrong': AppTextDefault('Sentence Builder',
      'A indawt a la dik lo. “{sentence}” tih hi en la, tum leh rawh.'),
  'sentence.check': AppTextDefault('Sentence Builder', 'Check Sentence'),
  'sentence.finish': AppTextDefault('Sentence Builder', 'Finish'),
  'sentence.next': AppTextDefault('Sentence Builder', 'Next Sentence'),
  'sentence.retry': AppTextDefault('Sentence Builder', 'Try Again'),
  // Thumal Kawp
  'kawp.progress': AppTextDefault('Thumal Kawp',
      'Kawp {found}/{pairs} i hmu tawh • Vawi {turns} i let tawh'),
  'kawp.notEnough': AppTextDefault('Thumal Kawp',
      'Card kawp tûr thumal a tâwk lo. Content thar a lo thlen hunah tum leh rawh.'),
  'kawp.hiddenSpoken': AppTextDefault('Thumal Kawp', 'Hidden card'),
  'kawp.pictureSpoken': AppTextDefault('Thumal Kawp', 'Picture of {gloss}'),
  'kawp.matchedSpoken': AppTextDefault('Thumal Kawp', '{card}, matched'),
  // Level check
  'placement.empty':
      AppTextDefault('Level check', 'Zirna tur thumal a la awm lo.'),
  'placement.prompt':
      AppTextDefault('Level check', 'A awmzia hnai ber thlang rawh'),
  'placement.seeLevel': AppTextDefault('Level check', 'I level en rawh'),
  'placement.skip':
      AppTextDefault('Level check', 'Level 1 atangin ṭan nghal rawh'),
  'placement.result': AppTextDefault('Level check', 'I ṭanna level'),
  'placement.title': AppTextDefault('Level check', 'Level enna'),
  'placement.question': AppTextDefault('Level check', 'Zawhna {n}/{total}'),
  'placement.score': AppTextDefault(
      'Level check', '{total} zingah {correct} i chhang dik • {description}'),
  // Daily lesson
  'lesson.prompt': AppTextDefault('Daily lesson', 'A awmzia thlang rawh'),
  'lesson.finish': AppTextDefault('Daily lesson', 'Zirna tihfel rawh'),
  'lesson.caughtUp': AppTextDefault('Daily lesson', 'I zo vek tawh e!'),
  'lesson.caughtUpNote':
      AppTextDefault('Daily lesson', 'Tunah hian en leh tur thumal a awm lo.'),
  'lesson.back': AppTextDefault('Daily lesson', 'Kir leh rawh'),
  'lesson.completeTitle': AppTextDefault('Daily lesson', 'Zirna zo'),
  'lesson.complete': AppTextDefault('Daily lesson', 'Vawiin zirna i zo ta!'),
  'lesson.newWord': AppTextDefault('Daily lesson', 'THUMAL THAR'),
  'lesson.title': AppTextDefault('Daily lesson', 'Vawiin zirna'),
  'lesson.score': AppTextDefault('Daily lesson',
      '{total} zingah {correct} i chhang dik • Heng thumalte hi a hun takah kan rawn tilang leh ang.'),
  'lesson.right': AppTextDefault('Daily lesson', 'A dik e! “{example}”'),
  'lesson.wrong':
      AppTextDefault('Daily lesson', 'A dik chu “{answer}” a ni. {example}'),
  // Levels
  'level.code': AppTextDefault('Levels', 'Level {n}'),
  'level.1.title': AppTextDefault('Levels', 'First Steps'),
  'level.1.description':
      AppTextDefault('Levels', 'Thumal bul leh thlalak hmanga bulṭan'),
  'level.2.title': AppTextDefault('Levels', 'Everyday Words'),
  'level.2.description':
      AppTextDefault('Levels', 'Nitin thumal leh sentence tawi zirna'),
  'level.3.title': AppTextDefault('Levels', 'Growing Speaker'),
  'level.3.description':
      AppTextDefault('Levels', 'Conversation, spelling leh chhiarna'),
  'level.4.title': AppTextDefault('Levels', 'Confident Reader'),
  'level.4.description':
      AppTextDefault('Levels', 'Sentence sei leh thu awmzia hriatna'),
  'level.5.title': AppTextDefault('Levels', 'Storyteller'),
  'level.5.description':
      AppTextDefault('Levels', 'Thawnthu leh chanchin zirna'),
  'level.6.title': AppTextDefault('Levels', 'Explorer'),
  'level.6.description':
      AppTextDefault('Levels', 'Ram hmuhna leh nunphung zirna'),
  'level.7.title': AppTextDefault('Levels', 'Culture Apprentice'),
  'level.7.description':
      AppTextDefault('Levels', 'Tawng upa leh grammar zirna'),
  'level.8.title': AppTextDefault('Levels', 'Culture & Fluency'),
  'level.8.description': AppTextDefault(
      'Levels', 'Tawng upa, hnam ziarang leh tawng thiamna famkim'),
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
      AppTextDefault('Onboarding', 'Picture leh game hmanga bulṭan'),
  'age.young.note':
      AppTextDefault('Onboarding', 'Words, spelling leh story hmanga zir'),
  'age.teen.note':
      AppTextDefault('Onboarding', 'Reading, conversation leh culture'),
  'age.adult.note':
      AppTextDefault('Onboarding', 'Mahni pace-a Mizo tawng zir leh'),
  'proficiency.new': AppTextDefault('Onboarding', 'I\'m new to Mizo'),
  'proficiency.some': AppTextDefault('Onboarding', 'I understand some'),
  'proficiency.speaks': AppTextDefault('Onboarding', 'I can speak Mizo'),
  'proficiency.reads': AppTextDefault('Onboarding', 'I can read and write'),
  'proficiency.new.note':
      AppTextDefault('Onboarding', 'Thumal bul aṭangin min kaihhruai rawh'),
  'proficiency.some.note':
      AppTextDefault('Onboarding', 'Ka hria deuh, sawi leh chhiar ka zir duh'),
  'proficiency.speaks.note':
      AppTextDefault('Onboarding', 'Spelling leh reading ka tihpun duh'),
  'proficiency.reads.note':
      AppTextDefault('Onboarding', 'Tawng upa leh thiamna sang zâwk ka duh'),
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
  'welcome.eyebrow': AppTextDefault('Onboarding', 'Mizo learning, made joyful'),
  'welcome.title':
      AppTextDefault('Onboarding', 'Your Mizo journey starts here.'),
  'welcome.path': AppTextDefault('Onboarding', 'A path built for you'),
  'welcome.pathNote':
      AppTextDefault('Onboarding', 'I thiamna leh i tum dân ang zêlin.'),
  'welcome.offline': AppTextDefault('Onboarding', 'Learn anywhere'),
  'welcome.offlineNote':
      AppTextDefault('Onboarding', 'Core games work offline on your device.'),
  'welcome.safe': AppTextDefault('Onboarding', 'Safe for families'),
  'welcome.safeNote': AppTextDefault(
      'Onboarding', 'No public chat, ads, or child leaderboard.'),
  'age.eyebrow': AppTextDefault('Onboarding', 'Personalize your path'),
  'age.title': AppTextDefault('Onboarding', 'Who is learning?'),
  'age.subtitle': AppTextDefault('Onboarding',
      'Age range chauh kan mamawh—birthday emaw hming emaw kan dil lo.'),
  'proficiency.eyebrow':
      AppTextDefault('Onboarding', 'Find your starting point'),
  'proficiency.title':
      AppTextDefault('Onboarding', 'How much Mizo do you know?'),
  'proficiency.subtitle': AppTextDefault('Onboarding',
      'A dik tak thlang rawh—eng hunah pawh Profile-ah i thlâk thei.'),
  'goal.eyebrow': AppTextDefault('Onboarding', 'Choose up to two'),
  'goal.title': AppTextDefault('Onboarding', 'What would you like to learn?'),
  'goal.subtitle': AppTextDefault('Onboarding',
      'I zir duh ber thlang la, daily quest-ah kan dah hmasa ang.'),
  'rhythm.eyebrow': AppTextDefault('Onboarding', 'Ready for your first quest'),
  'rhythm.title': AppTextDefault('Onboarding', 'Set your daily rhythm.'),
  'rhythm.subtitle': AppTextDefault('Onboarding',
      'Tlem tê tê, ni tin zir hi rei tak zirna kawng tha ber a ni.'),
  'welcome.subtitle': AppTextDefault('Onboarding',
      'Khelh pahin thumal, spelling, chhiarna leh Mizo nunphung zir rawh.'),
  'rhythm.goal': AppTextDefault('Onboarding', 'DAILY GOAL'),
  'rhythm.minutes': AppTextDefault('Onboarding', '{n} min'),
  'rhythm.privacy': AppTextDefault(
      'Onboarding', 'Guest-first • Progress stays on this device'),
  // Profile • learning level
  'track.beginner': AppTextDefault('Profile • learning level', 'Bulṭan'),
  'track.explorer': AppTextDefault('Profile • learning level', 'Zirchho'),
  'track.master': AppTextDefault('Profile • learning level', 'Thiamna'),
  'track.beginner.note': AppTextDefault(
      'Profile • learning level', 'Thlalak leh thumal awlsam hmanga bulṭan'),
  'track.explorer.note': AppTextDefault(
      'Profile • learning level', 'Spelling leh puzzle hmanga zir chhunzawm'),
  'track.master.note':
      AppTextDefault('Profile • learning level', 'Tawng upa leh thufing zirna'),
  // Word categories
  'category.chhungkua': AppTextDefault('Word categories', 'Chhungkua'),
  'category.sikul': AppTextDefault('Word categories', 'Sikul'),
  'category.nungcha': AppTextDefault('Word categories', 'Nungcha'),
  'category.khawvel': AppTextDefault('Word categories', 'Khawvel'),
  'category.nunphung': AppTextDefault('Word categories', 'Nunphung'),
  'category.thiltih': AppTextDefault('Word categories', 'Thiltih'),
  // Journey
  'journey.title': AppTextDefault('Journey', 'Mizo Journey'),
  'journey.subtitle':
      AppTextDefault('Journey', 'Story, conversation & culture'),
  'journey.todaysQuests': AppTextDefault('Journey', 'Today’s Quests'),
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
      'I kalna hmasa a bo lo. Minute tlem chauh hmangin story chhunzawm rawh.'),
  'journey.dailyGentle':
      AppTextDefault('Journey', 'OPTIONAL DAILY • NO PENALTY'),
  'journey.daily': AppTextDefault('Journey', 'DAILY'),
  'journey.weeklyGentle':
      AppTextDefault('Journey', 'OPTIONAL WEEKLY • NO DEADLINE'),
  'journey.weekly': AppTextDefault('Journey', 'WEEKLY • NO COUNTDOWN'),
  'journey.claim': AppTextDefault('Journey', 'Claim +{n}'),
  'journey.preview': AppTextDefault('Journey',
      'Preview content — Mizo language reviewer pawmna a la nghah mêk.'),
  'journey.nodeSpoken': AppTextDefault('Journey', '{title}, {status}'),
  'journey.nodeLevel': AppTextDefault('Journey', 'Level {n}'),
  'journey.replay': AppTextDefault('Journey', 'REPLAY'),
  'journey.start': AppTextDefault('Journey', 'START'),
  'journey.collection': AppTextDefault('Journey', 'My Collection'),
  'journey.viewAll': AppTextDefault('Journey', 'View All'),
  'journey.firstReward': AppTextDefault(
      'Journey', 'Story Quest zawh hmasak berah reward i hmu ang.'),
  'story.title': AppTextDefault('Journey', 'Story Quest'),
  'story.chooseReply': AppTextDefault('Journey', 'Choose a natural reply'),
  'story.complete': AppTextDefault('Journey', 'Complete Story'),
  'story.completeTitle': AppTextDefault('Journey', 'Story Complete'),
  'story.wellDone': AppTextDefault('Journey', 'I ti ṭha e!'),
  'story.reward': AppTextDefault('Journey', 'Story reward'),
  'story.cultureMoment': AppTextDefault('Journey', 'CULTURE MOMENT'),
  'story.saved': AppTextDefault('Journey', 'Saved'),
  'story.read': AppTextDefault('Journey', 'I read this'),
  'story.stop': AppTextDefault('Journey', 'A good stopping point'),
  'story.stopNote': AppTextDefault('Journey',
      'Vawiin tâna i zirna a tâwk tawh. Naktûkah hlim takin i chhunzawm leh thei e.'),
  'story.finish': AppTextDefault('Journey', 'Finish for Now'),
  'story.stepSpoken': AppTextDefault('Journey', 'Story step {n} of {total}'),
  'story.conversation':
      AppTextDefault('Journey', 'Conversation {n} of {total}'),
  // Culture
  'culture.title': AppTextDefault('Culture', 'Culture Trail'),
  'culture.collected': AppTextDefault('Culture', '{n}/{total} cards collected'),
  'culture.eyebrow': AppTextDefault('Culture', 'MIZO CULTURE TRAIL'),
  'culture.intro':
      AppTextDefault('Culture', 'Thumal, hnam nun leh a hman dân zir rawh.'),
  'culture.marks':
      AppTextDefault('Culture', '{n} Trail Marks • Lessons stay open'),
  'culture.cards': AppTextDefault('Culture', 'Culture Cards'),
  'culture.preview': AppTextDefault('Culture',
      'Preview content — language leh culture reviewer pawmna a la nghah mêk.'),
  'culture.noDeadline': AppTextDefault('Culture', 'NO DEADLINE'),
  'culture.unlockAt': AppTextDefault('Culture', 'Unlock at Level {n}'),
  'culture.keepLearning':
      AppTextDefault('Culture', 'Zirna level chhunzawm rawh.'),
  'culture.cardTitle': AppTextDefault('Culture', 'Culture Card'),
  'culture.usage': AppTextDefault('Culture', 'A hman dân leh a nihna'),
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
  'collection.firstCard': AppTextDefault(
      'Culture', 'Culture Trail-ah card pakhat chhiar hmasa rawh.'),
  'collection.rewards': AppTextDefault('Culture', 'Story Rewards'),
  'collection.firstReward': AppTextDefault(
      'Culture', 'Story Quest zawh hmasak berah reward i hmu ang.'),
  'collection.avatarLocked':
      AppTextDefault('Culture', '{avatar} • {marks} marks'),
  // Journey quests
  'quest.story': AppTextDefault('Journey quests', 'Story Step'),
  'quest.story.note':
      AppTextDefault('Journey quests', 'Story Quest pakhat zawh rawh.'),
  'quest.words': AppTextDefault('Journey quests', 'Word Keeper'),
  'quest.words.note':
      AppTextDefault('Journey quests', 'Thumal pathum review rawh.'),
  'quest.culture': AppTextDefault('Journey quests', 'Culture Moment'),
  'quest.culture.note':
      AppTextDefault('Journey quests', 'Culture note pakhat chhiar rawh.'),
  'quest.storyWeek': AppTextDefault('Journey quests', 'Story Week'),
  'quest.storyWeek.note': AppTextDefault(
      'Journey quests', 'Kar khat chhûngin Story Quest pathum zawh rawh.'),
  'quest.cultureWeek': AppTextDefault('Journey quests', 'Culture Trail Week'),
  'quest.cultureWeek.note': AppTextDefault(
      'Journey quests', 'Kar khat chhûngin Culture Card pathum chhiar rawh.'),
};
