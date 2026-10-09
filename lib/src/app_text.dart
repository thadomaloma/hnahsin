/// Every label, button and message in the app, by ID, with the text it shows
/// unless the content Sheet's “App text” tab says otherwise. The Sheet's rows
/// are made from [appTextDefaults], so a new text here needs a new row there
/// (content_studio/README.md).
library;

/// The language the app's own labels and messages are shown in. Mizo is the
/// default; English is for learners who can't read Mizo yet.
enum AppLanguage { mizo, english }

/// One text's built-in wording and where in the app it shows.
class AppTextDefault {
  const AppTextDefault(this.where, this.text, this.english);

  /// The screen or part of the app, so an editor can find it.
  final String where;

  /// The Mizo wording: what the Sheet's “Built-in text” shows.
  final String text;

  /// The same text in English, for [AppLanguage.english].
  final String english;
}

/// The `{name}` placeholders in [text], which the app fills in.
Set<String> appTextPlaceholders(String text) =>
    RegExp(r'\{(\w+)\}').allMatches(text).map((match) => match[1]!).toSet();

abstract final class AppText {
  static Map<String, String> _delivered = const <String, String>{};

  /// The Sheet's texts from the active content pack.
  static void update(Map<String, String> delivered) => _delivered = delivered;

  /// The learner's choice (Profile, or the welcome screen).
  static AppLanguage language = AppLanguage.mizo;

  /// [id]'s text with its `{name}` placeholders filled from [values]. Sheet
  /// text is used only when it has the same placeholders as the built-in
  /// text, so a typo there can't show a raw `{name}` or drop a number. The
  /// Sheet edits the Mizo wording, so English shows the built-in English.
  static String of(String id,
      [Map<String, Object?> values = const <String, Object?>{}]) {
    final builtIn = appTextDefaults[id];
    final english = language == AppLanguage.english;
    final fallback = (english ? builtIn?.english : builtIn?.text) ?? id;
    final sheet = english ? null : _delivered[id];
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
  'review.title': AppTextDefault('Content review', 'Content en fel mêk a ni',
      'Content review in progress'),
  'review.body': AppTextDefault(
      'Content review',
      'Mizo ṭawng thiam mi te\'n content hi an la en fel mêk a. An pawm hma chuan app-ah kan dah lo.',
      'Qualified Mizo reviewers are still checking this content. Draft content is not shown in public releases.'),
  // Navigation
  'nav.home': AppTextDefault('Navigation', 'In', 'Home'),
  'nav.learn': AppTextDefault('Navigation', 'Zir', 'Learn'),
  'nav.games': AppTextDefault('Navigation', 'Khel', 'Games'),
  'nav.profile': AppTextDefault('Navigation', 'Keimah', 'Profile'),
  // Profile • content
  'content.offline': AppTextDefault(
      'Profile • content', 'Internet nei lovin', 'Offline content'),
  'content.version': AppTextDefault(
      'Profile • content', 'Content {version}', 'Content {version}'),
  'content.check': AppTextDefault(
      'Profile • content', 'Thil thar awm em en rawh', 'Check for Updates'),
  'content.builtIn':
      AppTextDefault('Profile • content', 'App-a awm sa', 'Built-in Pack'),
  'sync.builtInReady': AppTextDefault(
      'Profile • content',
      'App-a zirna awm sa hi internet nei lovin a hman theih.',
      'Built-in learning content is ready offline.'),
  'sync.packsReady': AppTextDefault(
      'Profile • content',
      'Content endik fel sa hi internet nei lovin a hman theih.',
      'Verified offline packs are ready.'),
  'sync.checking': AppTextDefault('Profile • content',
      'Content thar awm em kan en mêk…', 'Checking reviewed content packs…'),
  'sync.updated': AppTextDefault('Profile • content',
      'Content thar a lut ṭha ta.', 'Reviewed offline packs updated safely.'),
  'sync.upToDate': AppTextDefault('Profile • content',
      'Content thar ber i nei tawh.', 'Offline packs are up to date.'),
  'sync.rejected': AppTextDefault(
      'Profile • content',
      'Content thar hi a ṭha lo avangin kan la lo. I content awm sa chu i hmang thei reng. {error}',
      'Unsafe update rejected. Verified compatible offline content remains available. {error}'),
  'sync.unavailable': AppTextDefault(
      'Profile • content',
      'Tunah hian content thar kan la thei lo. I content awm sa chu i hmang thei reng.',
      'Update unavailable. Verified compatible offline content remains available.'),
  // Content report
  'report.done':
      AppTextDefault('Content report', 'Kan hriattir tawh', 'Issue reported'),
  'report.open': AppTextDefault(
      'Content report', 'Content dik lo hriattir rawh', 'Report content issue'),
  'report.title': AppTextDefault(
      'Content report', 'Content dik lo hriattirna', 'Report a content issue'),
  'report.privacy': AppTextDefault(
      'Content report',
      'I thu mal kan la lo. Content leh a chhan chauh hi i phone-ah a awm a, en fel turin kan dah.',
      'No personal message is collected. The content reference and reason stay on this device for the review queue.'),
  'report.spelling': AppTextDefault('Content report',
      'Mizo ziah dan emaw thumal hman dan', 'Mizo spelling or wording'),
  'report.meaning': AppTextDefault(
      'Content report', 'Awmzia emaw lehlin dan', 'Meaning or translation'),
  'report.picture': AppTextDefault(
      'Content report', 'Milem a inmil lo', 'Picture does not match'),
  'report.culture':
      AppTextDefault('Content report', 'Hnam nun lam', 'Cultural context'),
  'report.save':
      AppTextDefault('Content report', 'Dah ṭha rawh', 'Save Report'),
  'report.saved': AppTextDefault(
      'Content report',
      'I hriattirna chu en fel turin kan dah ṭha e.',
      'Report saved to the local review queue.'),
  // Home
  'home.games': AppTextDefault('Home', 'Khel', 'Games'),
  'home.viewAll': AppTextDefault('Home', 'A vaiin en rawh', 'View All'),
  'home.journey': AppTextDefault('Home', 'Mizo Kawngzawh', 'Mizo Journey'),
  'home.viewMap': AppTextDefault('Home', 'Map en rawh', 'View Map'),
  'home.storyPath': AppTextDefault('Home', 'THAWNTHU KAWNG', 'STORY PATH'),
  'home.journeyComplete':
      AppTextDefault('Home', 'Kawngzawh i zo ta', 'Journey Complete'),
  'home.journeyContinue': AppTextDefault(
      'Home', 'I kawngzawh chhunzawm rawh', 'Continue Your Journey'),
  'home.journeyProgress': AppTextDefault(
      'Home',
      'Thawnthu {total} zingah {done} i zo • Ni tin hna',
      '{done}/{total} story stops • Daily quests'),
  'home.greeting': AppTextDefault('Home', 'Chibai! 👋', 'Chibai! 👋'),
  'app.name': AppTextDefault('Home', 'Hnahsin', 'Hnahsin'),
  'home.xpLevel': AppTextDefault('Home', 'Lv {level}', 'Lv {level}'),
  'home.todaysGame': AppTextDefault('Home', 'VAWIIN GAME', 'TODAY\'S GAME'),
  'home.best': AppTextDefault('Home', 'A sang ber {score}', 'Best {score}'),
  'home.replay': AppTextDefault(
      'Home', 'Thumal {n} i hmuh leh tur a awm', '{n} words to see again'),
  'home.roundsToday':
      AppTextDefault('Home', '{done}/{goal}\nKHELH', '{done}/{goal}\nROUNDS'),
  'home.rhythm': AppTextDefault('Home', 'Zirna kalphung', 'Learning rhythm'),
  'home.streak': AppTextDefault('Home', 'Ni {n} indawt', '{n} day streak'),
  'home.startToday': AppTextDefault('Home', 'Vawiin ṭan rawh', 'Start today'),
  'home.play': AppTextDefault('Home', 'Khel rawh', 'Play'),
  'home.otherGame':
      AppTextDefault('Home', 'Game dang khel rawh', 'Play another game'),
  // Learn
  'learn.eyebrow': AppTextDefault('Learn', 'I zirna', 'Your learning'),
  'learn.title': AppTextDefault('Learn', 'Zir', 'Learn'),
  'learn.subtitle': AppTextDefault(
      'Learn',
      '{level} {title} • Mahni chak zawngin zir chhunzawm rawh.',
      '{level} {title} • Keep learning at your own pace.'),
  'learn.library': AppTextDefault('Learn', 'Thumal Dahkhawmna', 'Word Library'),
  'learn.libraryCount': AppTextDefault(
      'Learn',
      'Thumal {words} • Chi {categories}',
      '{words} words • {categories} topics'),
  'learn.due': AppTextDefault('Learn', 'EN LEH TUR', 'TO REVIEW'),
  'learn.new': AppTextDefault('Learn', 'THAR', 'NEW'),
  'learn.mastered': AppTextDefault('Learn', 'THIAM TAWH', 'MASTERED'),
  'learn.startLesson':
      AppTextDefault('Learn', 'Vawiin zirna ṭan rawh', 'Start today\'s lesson'),
  'learn.findLevel':
      AppTextDefault('Learn', 'I level hre chhuak rawh', 'Find your level'),
  'learn.retakeLevel':
      AppTextDefault('Learn', 'Level en leh rawh', 'Check your level again'),
  'learn.continue':
      AppTextDefault('Learn', 'Zir chhunzawm rawh', 'Keep learning'),
  // Games
  'games.eyebrow': AppTextDefault('Games', 'Inzirna hmun', 'Practice arena'),
  'games.title': AppTextDefault('Games', 'Khel', 'Games'),
  'games.subtitle': AppTextDefault(
      'Games',
      'I duh zawng thlang la, i mark sang ber siam rawh.',
      'Pick a game and beat your best score.'),
  'games.played': AppTextDefault('Games', 'I KHEL TAWH', 'PLAYED'),
  'games.level': AppTextDefault('Games', 'Lv {level}', 'Lv {level}'),
  'games.best': AppTextDefault('Games', '★ {score}', '★ {score}'),
  'games.play': AppTextDefault('Games', 'KHEL RAWH', 'PLAY'),
  // Profile
  'profile.eyebrow': AppTextDefault('Profile', 'I kawngzawh', 'Your journey'),
  'profile.title': AppTextDefault('Profile', 'Keimah', 'Profile'),
  'profile.subtitle': AppTextDefault(
      'Profile',
      'I zirna hmasawnna leh level te hetah en rawh.',
      'See your progress and levels here.'),
  'profile.name':
      AppTextDefault('Profile', 'Thumal {experience}', 'Thumal {experience}'),
  'profile.xpToNext': AppTextDefault('Profile', '{xp}/250 XP level thar atan',
      '{xp}/250 XP to the next level'),
  'profile.calm': AppTextDefault('Profile', 'Muang takin', 'Calm'),
  'profile.myPace': AppTextDefault('Profile', 'Ka chak zawngin', 'My Pace'),
  'profile.dayStreak': AppTextDefault('Profile', 'Ni indawt', 'Day Streak'),
  'profile.games': AppTextDefault('Profile', 'Khelh zat', 'Games'),
  'profile.lessons': AppTextDefault('Profile', 'Zirna', 'Lessons'),
  'profile.journey': AppTextDefault(
      'Profile', 'Mizo Kawngzawh Dahkhawmna', 'Mizo Journey Collection'),
  'profile.journeyCount': AppTextDefault(
      'Profile',
      'Thawnthu {stories}/{total} • Lawmman {rewards}',
      '{stories}/{total} stories • {rewards} rewards'),
  'profile.settings': AppTextDefault('Profile', 'Ka duh dan', 'My settings'),
  'profile.dailyGoal': AppTextDefault('Profile', 'Ni tin tum', 'Daily goal'),
  'profile.dailyGoalNote': AppTextDefault(
      'Profile',
      'Minute khatah game khat vel a ni; i tum i thlen chuan In-a bial chu a khat ang.',
      'About one game round a minute; Home\'s ring fills when you reach it.'),
  'profile.appLanguage': AppTextDefault('Profile', 'App ṭawng', 'App language'),
  'profile.appLanguageNote': AppTextDefault('Profile',
      'Button leh thuchah te ṭawng', 'The language of buttons and messages'),
  'profile.sound': AppTextDefault('Profile', 'Ri', 'Sound'),
  'profile.soundNote': AppTextDefault(
      'Profile',
      'Chhanna dik, dik lo leh game zawh ri',
      'Sounds for right and wrong answers and finished rounds'),
  'profile.ageRange': AppTextDefault('Profile', 'Kum', 'Age range'),
  'profile.englishNote': AppTextDefault(
      'Profile',
      'Thawnthu leh hnam nun card-ah Mizo bulah English pawh tilang rawh.',
      'Show English beside the Mizo in stories and culture cards.'),
  'profile.xpLevel': AppTextDefault('Profile', 'Lv {level}', 'Lv {level}'),
  'profile.family':
      AppTextDefault('Profile', 'Chhungkaw tan a him', 'Family-friendly'),
  'profile.familyNote': AppTextDefault(
      'Profile',
      'Mi dang nen inbiakna a awm lo • I hmasawnna i phone-ah a awm',
      'No public chat • Progress saved on this device'),
  'profile.reduceMotion':
      AppTextDefault('Profile', 'Che tlem zawk', 'Reduce motion'),
  'profile.reduceMotionNote': AppTextDefault('Profile',
      'Animation tlem zawk hmang rawh', 'Use fewer interface animations'),
  'profile.gentle':
      AppTextDefault('Profile', 'Nawr lovin', 'Gentle engagement'),
  'profile.gentleNote': AppTextDefault(
      'Profile',
      'Hna te hi duh thlan a ni a, ni indawt nawrna a lang lo',
      'Keep quests optional and hide streak pressure'),
  'profile.reset': AppTextDefault(
      'Profile', 'Hmasawnna paih vek rawh', 'Reset Local Progress'),
  'profile.resetTitle': AppTextDefault(
      'Profile', 'I hmasawnna paih vek dawn em?', 'Reset local progress?'),
  'profile.resetBody': AppTextDefault(
      'Profile',
      'He phone-a i XP, mark, i duh dan leh game i dah ṭhat te chu an bo vek ang. Siam ṭhat leh theih a ni lo.',
      'Your XP, scores, settings and saved game sessions on this device will be deleted. This cannot be undone.'),
  'profile.resetConfirm': AppTextDefault('Profile', 'Paih vek rawh', 'Reset'),
  'profile.badge.older': AppTextDefault('Profile', 'Kawngzawh', 'Journey'),
  // Common
  'common.cancel': AppTextDefault('Common', 'Ti lo ang', 'Cancel'),
  'common.back': AppTextDefault('Common', 'Kir leh', 'Back'),
  'common.continue': AppTextDefault('Common', 'Chhunzawm rawh', 'Continue'),
  'common.viewResults':
      AppTextDefault('Common', 'I hmuh zat en rawh', 'View Results'),
  'common.next': AppTextDefault('Common', 'A dawt', 'Next'),
  'common.next.mizo': AppTextDefault('Common', 'A dawt', 'Next'),
  // Word Library
  'library.count': AppTextDefault('Word Library', 'Thumal {n}', '{n} words'),
  'library.all': AppTextDefault('Word Library', 'Zawng zawng', 'All'),
  // Game screen
  'hud.relaxedSpoken': AppTextDefault(
      'Game screen',
      'Hahdam takin. Mark {score}. {percent} zaa khat i zo.',
      'Relaxed mode. Score {score}. Progress {percent} percent.'),
  'hud.heartsSpoken': AppTextDefault('Game screen',
      'Thinlung {total} zingah {hearts} i nei.', '{hearts} of {total} hearts.'),
  'hud.secondsSpoken': AppTextDefault('Game screen',
      'Second {seconds} a la awm.', '{seconds} seconds remaining.'),
  'hud.scoreSpoken': AppTextDefault(
      'Game screen',
      'Mark {score}. {percent} zaa khat i zo.',
      'Score {score}. Progress {percent} percent.'),
  'hud.relaxed': AppTextDefault('Game screen', 'Hahdam', 'Relaxed'),
  'game.restored': AppTextDefault(
      'Game screen',
      'I khelhna hmasa kha kan chhunzawm e.',
      'Saved game restored — picking up where you left off.'),
  'game.hintUsed':
      AppTextDefault('Game screen', 'Ṭanpuina i la tawh', 'Hint used'),
  'game.useHint':
      AppTextDefault('Game screen', 'Ṭanpuina la rawh', 'Use a hint'),
  'answer.correctSpoken':
      AppTextDefault('Game screen', '{answer}, a dik', '{answer}, correct'),
  'answer.incorrectSpoken': AppTextDefault(
      'Game screen', '{answer}, a dik lo', '{answer}, incorrect'),
  'feedback.correctSpoken': AppTextDefault('Game screen', 'A dik', 'Correct'),
  'feedback.retrySpoken':
      AppTextDefault('Game screen', 'Tum leh rawh', 'Try again'),
  // Game result
  'result.timeUp':
      AppTextDefault('Game result', 'Hun a tawp ta!', 'Time is up!'),
  'result.outOfHearts':
      AppTextDefault('Game result', 'Tunah chuan a tâwk e!', 'Out of hearts!'),
  'result.done': AppTextDefault('Game result', 'I ti thei e!', 'You did it!'),
  'result.timeUpNote': AppTextDefault(
      'Game result',
      'Hun a tâwp ta. I chhân tawhte chu a save vek e.',
      'Time ran out. Every answer you gave is saved.'),
  'result.outOfHeartsNote': AppTextDefault(
      'Game result',
      'I mark chu a save tawh. Tum leh la, i thiam chho ang.',
      'Your score is saved. Try again and you will get better.'),
  'result.doneNote': AppTextDefault(
      'Game result',
      'Khelh pahin Mizo ṭawng i thiam chho zêl e.',
      'Every game makes your Mizo stronger.'),
  'result.score': AppTextDefault('Game result', 'MARK', 'SCORE'),
  'result.accuracy': AppTextDefault('Game result', 'A DIK ZAT', 'ACCURACY'),
  'result.xp': AppTextDefault('Game result', 'XP', 'XP'),
  'result.playAgain':
      AppTextDefault('Game result', 'Khel leh rawh', 'Play again'),
  'result.words':
      AppTextDefault('Game result', 'Thumal i hmuh te', 'Words in this round'),
  'result.missedNote': AppTextDefault(
      'Game result',
      'A sen te hi i khelh leh hunah an lo lang leh ang.',
      'The red ones will come back next time you play.'),
  'result.levelUp': AppTextDefault(
      'Game result', 'Level i kai! {from} → {to}', 'Level up! {from} → {to}'),
  'result.levelDown': AppTextDefault(
      'Game result',
      'Level {level} — awlsam deuhvin kan ṭan leh ang',
      'Level {level} — a little easier next time'),
  'result.levelProgress': AppTextDefault(
      'Game result',
      'Level {level} • Level thar thlengin {percent}%',
      'Level {level} • {percent}% to the next level'),
  // Game level
  'gameLevel.spoken': AppTextDefault(
      'Game level', 'Level 7 zingah {level}', 'Level {level} of 7'),
  'gameLevel.master': AppTextDefault(
      'Game level', 'Level 7 • Thiam famkim', 'Level 7 • Master'),
  'gameLevel.level':
      AppTextDefault('Game level', 'Level {level}', 'Level {level}'),
  'gameLevel.note': AppTextDefault(
      'Game level',
      'I thiam chhoh dan zirin thumal a harsa chho zel ang.',
      'Words get harder as you improve.'),
  // Game start
  'launcher.howToPlay':
      AppTextDefault('Game start', 'KHELH DAN', 'HOW TO PLAY'),
  'launcher.saved': AppTextDefault(
      'Game start', 'Game i dah ṭhat a awm', 'Saved game available'),
  'launcher.savedDetail': AppTextDefault('Game start',
      '{mode} • Vawi {attempts} i chhang', '{mode} mode • {attempts} attempts'),
  'launcher.modeName.relaxed':
      AppTextDefault('Game start', 'Hahdam', 'relaxed'),
  'launcher.modeName.standard':
      AppTextDefault('Game start', 'Pangngai', 'standard'),
  'launcher.modeName.timed': AppTextDefault('Game start', 'Hun bituk', 'timed'),
  'launcher.chooseMode':
      AppTextDefault('Game start', 'Khelh dan thlang rawh', 'Choose a mode'),
  'launcher.relaxed': AppTextDefault('Game start',
      'Hahdam — Thinlung chân lovin', 'Relaxed — no hearts to lose'),
  'launcher.standard': AppTextDefault(
      'Game start', 'Pangngai — Thinlung 3 nen', 'Standard — 3 hearts'),
  'launcher.timed': AppTextDefault(
      'Game start', 'Hun bituk — Second 90 chhungin', 'Timed — 90 seconds'),
  'launcher.start': AppTextDefault('Game start', 'Ṭan rawh', 'Start Game'),
  'launcher.resume':
      AppTextDefault('Game start', 'Chhunzawm rawh', 'Resume Game'),
  'launcher.startNew':
      AppTextDefault('Game start', 'A thar ṭan rawh', 'Start New Game'),
  // Picture Match
  'picture.right':
      AppTextDefault('Picture Match', '{word} — {gloss}', '{word} — {gloss}'),
  'picture.wrong': AppTextDefault(
      'Picture Match',
      'Chhanna dik chu “{word}” a ni.\n{meaning}\n“{example}”',
      'The answer is “{word}”.\n{meaning}\n“{example}”'),
  // Spelling
  'spelling.clue':
      AppTextDefault('Spelling', 'KAWHHMUHNA  •  {hint}', 'CLUE  •  {hint}'),
  'spelling.right':
      AppTextDefault('Spelling', '“{word}” a kim ta.', '“{word}” is complete.'),
  'spelling.wrong': AppTextDefault(
      'Spelling',
      'Chhanna dik chu “{answer}” a ni: “{word}”.',
      'The answer is “{answer}”: “{word}”.'),
  // Tawng Upa
  'tawngUpa.blank': AppTextDefault('Tawng Upa',
      'A ruak-ah eng thumal nge a lut ang?', 'Which word fills the blank?'),
  'tawngUpa.wrong': AppTextDefault(
      'Tawng Upa',
      'Chhanna dik chu “{answer}” a ni.\n{explanation}',
      'The answer is “{answer}”.\n{explanation}'),
  // Word Chain
  'chain.hintNone': AppTextDefault(
      'Word Chain', 'Thumal dang ngaihtuah rawh.', 'Think of another word.'),
  'chain.hint': AppTextDefault(
      'Word Chain', '“{word}” i hmang thei.', 'You could use “{word}”.'),
  'chain.word': AppTextDefault('Word Chain', '“{word}”', '“{word}”'),
  'chain.wordMeaning': AppTextDefault(
      'Word Chain', '“{word}” ({meaning})', '“{word}” ({meaning})'),
  'chain.unknown': AppTextDefault(
      'Word Chain',
      'He thumal hi kan thumal dahkhâwmnaah a la awm lo. Thumal dang ziak rawh.',
      'We don\'t have this word yet. Try another one.'),
  'chain.deadEnd': AppTextDefault(
      'Word Chain',
      '“{word}” a dik, mahse “{unit}” hmanga bulṭan thumal kan la nei lo. Thumal dang ziak rawh.',
      '“{word}” is right, but we have no word starting with “{unit}” yet. Try another one.'),
  'chain.used': AppTextDefault('Word Chain', 'He thumal hi i hmang tawh.',
      'You already used this word.'),
  'chain.wrongStart': AppTextDefault(
      'Word Chain',
      '“{word}” chu “{start}” hmangin a inṭan; “{needed}” hmanga bulṭan tûr a ni.',
      '“{word}” starts with “{start}”; it needs to start with “{needed}”.'),
  'chain.linked': AppTextDefault(
      'Word Chain',
      '{word}\n“{unit}” hmanga zawm leh rawh.',
      '{word}\nNow link a word starting with “{unit}”.'),
  'chain.howToPlay': AppTextDefault('Word Chain', 'KHELH DAN', 'HOW TO PLAY'),
  'chain.rule': AppTextDefault(
      'Word Chain',
      'Thumal tawpna hawrawp hmangin thumal dang bulṭan rawh.',
      'Start each word with the last letter of the one before.'),
  'chain.example': AppTextDefault('Word Chain',
      'Entîrna: In → Nula → Aizawl → Lal', 'Example: In → Nula → Aizawl → Lal'),
  'chain.title': AppTextDefault('Word Chain', 'Kan thumal zawm', 'Our chain'),
  'chain.start':
      AppTextDefault('Word Chain', 'Inṭanna: {word}', 'Start: {word}'),
  'chain.needed': AppTextDefault(
      'Word Chain', '“{unit}” hmanga bulṭan rawh', 'Start with “{unit}”'),
  'chain.input': AppTextDefault(
      'Word Chain', 'Mizo thumal ziak rawh…', 'Type a Mizo word…'),
  'chain.tip': AppTextDefault(
      'Word Chain',
      'KAWHHMUHNA  •  “{unit}” hmanga bulṭan thumal {n} kan nei.',
      'TIP  •  We know {n} words starting with “{unit}”.'),
  // Word Search
  'search.start': AppTextDefault('Word Search',
      'Hawrawp te indawtin hmet rawh.', 'Tap the letters in order.'),
  'search.allFound': AppTextDefault(
      'Word Search', 'Thumal zawng zawng i hmu tawh.', 'You found every word.'),
  'search.adjacent': AppTextDefault(
      'Word Search',
      'Hawrawp bul hnai indawtin thlang rawh.',
      'Pick letters next to each other.'),
  'search.found': AppTextDefault(
      'Word Search', '“{word}” i hmu ta!', 'You found “{word}”!'),
  'search.foundGloss': AppTextDefault('Word Search',
      '“{word}” i hmu ta! ({gloss})', 'You found “{word}”! ({gloss})'),
  'search.noMatch': AppTextDefault('Word Search',
      'A rem lo. Bulṭan nawn leh rawh.', 'That\'s not one. Start again.'),
  'search.cellSpoken': AppTextDefault(
      'Word Search',
      'Tlar {row}, ban {column}, hawrawp {letter}',
      'Row {row}, column {column}, letter {letter}'),
  // Crossword
  'crossword.yourAnswer':
      AppTextDefault('Crossword', 'I chhanna', 'Your answer'),
  'crossword.words':
      AppTextDefault('Crossword', 'Thumal {words}', '{words} words'),
  'crossword.nearly': AppTextDefault(
      'Crossword',
      '{subject} a hnaih hle! Hawrawp sen chu â, ê, î, ô, û emaw ṭ emaw a ni ang.',
      '{subject} is very close! The red letter needs â, ê, î, ô, û or ṭ.'),
  'crossword.wrong': AppTextDefault(
      'Crossword',
      '{subject} a dik lo. Hawrawp sen te thlak la, tum leh rawh.',
      '{subject} isn\'t right. Change the red letters and try again.'),
  'crossword.across': AppTextDefault('Crossword', 'Vang →', 'Across →'),
  'crossword.down': AppTextDefault('Crossword', 'Dung ↓', 'Down ↓'),
  'crossword.previous':
      AppTextDefault('Crossword', 'Kawhhmuhna hmasa', 'Previous clue'),
  'crossword.next': AppTextDefault('Crossword', 'Kawhhmuhna dawt', 'Next clue'),
  'crossword.clueAcross': AppTextDefault('Crossword',
      '{n} VANG →  •  HAWRAWP {letters}', '{n} ACROSS →  •  {letters} LETTERS'),
  'crossword.clueDown': AppTextDefault('Crossword',
      '{n} DUNG ↓  •  HAWRAWP {letters}', '{n} DOWN ↓  •  {letters} LETTERS'),
  'crossword.cellEmptySpoken': AppTextDefault('Crossword',
      'Tlar {row}, ban {column}, a ruak', 'Row {row}, column {column}, empty'),
  'crossword.cellSpoken': AppTextDefault(
      'Crossword',
      'Tlar {row}, ban {column}, hawrawp {letter}',
      'Row {row}, column {column}, letter {letter}'),
  'crossword.erase': AppTextDefault('Crossword', 'Thai bo', 'Erase'),
  // Sentence Builder
  'sentence.title': AppTextDefault(
      'Sentence Builder', 'Sentence Builder', 'Sentence Builder'),
  'sentence.empty': AppTextDefault('Sentence Builder', 'Sentence a la awm lo.',
      'Sentence content is not available.'),
  'sentence.usingWord': AppTextDefault('Sentence Builder',
      'HE THUMAL HMANGA SENTENCE', 'SENTENCE USING THIS WORD'),
  'sentence.yours':
      AppTextDefault('Sentence Builder', 'I SENTENCE', 'YOUR SENTENCE'),
  'sentence.right': AppTextDefault('Sentence Builder',
      '{sentence} — A rem dik e.', '{sentence} — Well built!'),
  'sentence.wrong': AppTextDefault(
      'Sentence Builder',
      'A indawt a la dik lo. “{sentence}” tih hi en la, tum leh rawh.',
      'The order isn\'t right yet. Look at “{sentence}” and try again.'),
  'sentence.check':
      AppTextDefault('Sentence Builder', 'En rawh', 'Check Sentence'),
  'sentence.finish': AppTextDefault('Sentence Builder', 'Zo ta', 'Finish'),
  'sentence.next':
      AppTextDefault('Sentence Builder', 'Sentence dawt', 'Next Sentence'),
  'sentence.retry':
      AppTextDefault('Sentence Builder', 'Tum leh rawh', 'Try Again'),
  // Thumal Kawp
  'kawp.progress': AppTextDefault(
      'Thumal Kawp',
      'Kawp {found}/{pairs} i hmu tawh • Vawi {turns} i let tawh',
      '{found}/{pairs} pairs found • {turns} turns'),
  'kawp.notEnough': AppTextDefault(
      'Thumal Kawp',
      'Card kawp tûr thumal a tâwk lo. Content thar a lo thlen hunah tum leh rawh.',
      'Not enough words for the cards yet. Try again when new content arrives.'),
  'kawp.hiddenSpoken':
      AppTextDefault('Thumal Kawp', 'Card khuh', 'Hidden card'),
  'kawp.pictureSpoken':
      AppTextDefault('Thumal Kawp', '{gloss} milem', 'Picture of {gloss}'),
  'kawp.matchedSpoken':
      AppTextDefault('Thumal Kawp', '{card}, a inkawp ta', '{card}, matched'),
  // Level check
  'placement.empty': AppTextDefault(
      'Level check', 'Zirna tur thumal a la awm lo.', 'No words to learn yet.'),
  'placement.prompt': AppTextDefault('Level check',
      'A awmzia hnai ber thlang rawh', 'Pick the closest meaning'),
  'placement.seeLevel':
      AppTextDefault('Level check', 'I level en rawh', 'See your level'),
  'placement.skip': AppTextDefault(
      'Level check', 'Level 1 aṭangin ṭan nghal rawh', 'Start from Level 1'),
  'placement.result':
      AppTextDefault('Level check', 'I ṭanna level', 'Your starting level'),
  'placement.title': AppTextDefault('Level check', 'Level enna', 'Level check'),
  'placement.question': AppTextDefault(
      'Level check', 'Zawhna {n}/{total}', 'Question {n}/{total}'),
  'placement.score': AppTextDefault(
      'Level check',
      '{total} zingah {correct} i chhang dik • {description}',
      '{correct} of {total} right • {description}'),
  // Daily lesson
  'lesson.prompt': AppTextDefault(
      'Daily lesson', 'A awmzia thlang rawh', 'Pick the meaning'),
  'lesson.finish':
      AppTextDefault('Daily lesson', 'Zirna tihfel rawh', 'Finish lesson'),
  'lesson.caughtUp': AppTextDefault(
      'Daily lesson', 'I zo vek tawh e!', 'You\'re all caught up!'),
  'lesson.caughtUpNote': AppTextDefault(
      'Daily lesson',
      'Tunah hian en leh tur thumal a awm lo.',
      'No words to review right now.'),
  'lesson.back': AppTextDefault('Daily lesson', 'Kir leh rawh', 'Go back'),
  'lesson.completeTitle':
      AppTextDefault('Daily lesson', 'Zirna zo', 'Lesson complete'),
  'lesson.complete': AppTextDefault(
      'Daily lesson', 'Vawiin zirna i zo ta!', 'You finished today\'s lesson!'),
  'lesson.newWord': AppTextDefault('Daily lesson', 'THUMAL THAR', 'NEW WORD'),
  'lesson.title':
      AppTextDefault('Daily lesson', 'Vawiin zirna', 'Today\'s lesson'),
  'lesson.score': AppTextDefault(
      'Daily lesson',
      '{total} zingah {correct} i chhang dik • Heng thumalte hi a hun takah kan rawn tilang leh ang.',
      '{correct} of {total} right • We\'ll bring these words back at the right time.'),
  'lesson.right': AppTextDefault(
      'Daily lesson', 'A dik e! “{example}”', 'Correct! “{example}”'),
  'lesson.wrong': AppTextDefault(
      'Daily lesson',
      'A dik chu “{answer}” a ni. {example}',
      'The answer is “{answer}”. {example}'),
  // Levels
  'level.code': AppTextDefault('Levels', 'Level {n}', 'Level {n}'),
  'level.1.title': AppTextDefault('Levels', 'Ke pen hmasa', 'First Steps'),
  'level.1.description': AppTextDefault(
      'Levels',
      'Thumal bul leh milem hmanga bulṭanna',
      'Start with basic words and pictures'),
  'level.2.title': AppTextDefault('Levels', 'Ni tin thumal', 'Everyday Words'),
  'level.2.description': AppTextDefault(
      'Levels',
      'Ni tin thumal leh sentence tawi zirna',
      'Everyday words and short sentences'),
  'level.3.title':
      AppTextDefault('Levels', 'Sawi thiam chho', 'Growing Speaker'),
  'level.3.description': AppTextDefault(
      'Levels',
      'Inbiakna, hawrawp ziah dan leh chhiarna',
      'Conversation, spelling and reading'),
  'level.4.title': AppTextDefault('Levels', 'Chhiar thiam', 'Confident Reader'),
  'level.4.description': AppTextDefault('Levels',
      'Sentence sei leh thu awmzia hriatna', 'Longer sentences and meaning'),
  'level.5.title':
      AppTextDefault('Levels', 'Thawnthu sawi thiam', 'Storyteller'),
  'level.5.description': AppTextDefault(
      'Levels', 'Thawnthu leh chanchin zirna', 'Stories and accounts'),
  'level.6.title': AppTextDefault('Levels', 'Kawngzawh thiam', 'Explorer'),
  'level.6.description': AppTextDefault(
      'Levels', 'Ram hmuhna leh nunphung zirna', 'Places and way of life'),
  'level.7.title':
      AppTextDefault('Levels', 'Hnam nun zir', 'Culture Apprentice'),
  'level.7.description': AppTextDefault(
      'Levels', 'Tawng upa leh ṭawng dan zirna', 'Old sayings and grammar'),
  'level.8.title':
      AppTextDefault('Levels', 'Hnam nun leh ṭawng thiam', 'Culture & Fluency'),
  'level.8.description': AppTextDefault(
      'Levels',
      'Tawng upa, hnam ziarang leh ṭawng thiamna famkim',
      'Old sayings, heritage and full fluency'),
  'mastery.unseen': AppTextDefault('Levels', 'Thar', 'New'),
  'mastery.learning': AppTextDefault('Levels', 'Zir mêk', 'Learning'),
  'mastery.familiar': AppTextDefault('Levels', 'Hriat chin', 'Familiar'),
  'mastery.strong': AppTextDefault('Levels', 'Hriat ṭha', 'Strong'),
  'mastery.mastered': AppTextDefault('Levels', 'Thiam tawh', 'Mastered'),
  // Onboarding
  'age.early': AppTextDefault('Onboarding', 'Kum 5–7', 'Ages 5–7'),
  'age.young': AppTextDefault('Onboarding', 'Kum 8–13', 'Ages 8–13'),
  'age.teen': AppTextDefault('Onboarding', 'Kum 14–17', 'Ages 14–17'),
  'age.adult': AppTextDefault('Onboarding', 'Puitling', 'Adult'),
  'age.early.note': AppTextDefault('Onboarding',
      'Milem leh game hmanga bulṭanna', 'Start with pictures and games'),
  'age.young.note': AppTextDefault(
      'Onboarding',
      'Thumal, hawrawp ziah dan leh thawnthu hmanga zir',
      'Learn with words, spelling and stories'),
  'age.teen.note': AppTextDefault('Onboarding',
      'Chhiarna, inbiakna leh hnam nun', 'Reading, conversation and culture'),
  'age.adult.note': AppTextDefault('Onboarding',
      'Mahni chak zawngin Mizo ṭawng zir leh', 'Learn Mizo at your own pace'),
  'proficiency.new': AppTextDefault(
      'Onboarding', 'Mizo ṭawng ka thiam lo', 'I\'m new to Mizo'),
  'proficiency.some':
      AppTextDefault('Onboarding', 'Ka hrethiam deuh', 'I understand some'),
  'proficiency.speaks': AppTextDefault(
      'Onboarding', 'Mizo ṭawng ka sawi thiam', 'I can speak Mizo'),
  'proficiency.reads': AppTextDefault(
      'Onboarding', 'Ka chhiar leh ziak thiam', 'I can read and write'),
  'proficiency.new.note': AppTextDefault(
      'Onboarding',
      'Thumal bul aṭangin min kaihhruai rawh',
      'Guide me from the very first words'),
  'proficiency.some.note': AppTextDefault(
      'Onboarding',
      'Ka hria deuh, sawi leh chhiar ka zir duh',
      'I know a little and want to speak and read'),
  'proficiency.speaks.note': AppTextDefault(
      'Onboarding',
      'Hawrawp ziah dan leh chhiarna ka tihpun duh',
      'I want better spelling and reading'),
  'proficiency.reads.note': AppTextDefault(
      'Onboarding',
      'Tawng upa leh thiamna sang zâwk ka duh',
      'I want old sayings and harder skills'),
  'goal.conversation':
      AppTextDefault('Onboarding', 'Inbiakna', 'Home Conversation'),
  'goal.vocabulary':
      AppTextDefault('Onboarding', 'Thumal leh ziah dan', 'Words & Spelling'),
  'goal.reading': AppTextDefault('Onboarding', 'Chhiarna', 'Reading'),
  'goal.culture': AppTextDefault('Onboarding', 'Hnam nun', 'Culture'),
  'goal.refresh':
      AppTextDefault('Onboarding', 'Ka Mizo ṭawng tihthar', 'Refresh My Mizo'),
  'support.english':
      AppTextDefault('Onboarding', 'English ṭanpuina', 'English support'),
  'support.mizoOnly': AppTextDefault('Onboarding', 'Mizo chauh', 'Mizo only'),
  'profile.badge.early': AppTextDefault('Onboarding', 'Thlai tiak', 'Sprout'),
  'profile.badge.young': AppTextDefault('Onboarding', 'Kawngzawh', 'Explorer'),
  'onboarding.brand': AppTextDefault('Onboarding', 'HNAHSIN', 'HNAHSIN'),
  'onboarding.stepSpoken': AppTextDefault(
      'Onboarding', 'Kal dan {total} zingah {n}-na', 'Step {n} of {total}'),
  'onboarding.goalLimit': AppTextDefault('Onboarding',
      'I tum pahnih thleng i thlang thei.', 'Choose up to two learning goals.'),
  'onboarding.start':
      AppTextDefault('Onboarding', 'Ka kawngzawh ṭan rawh', 'Start My Journey'),
  'onboarding.finish': AppTextDefault(
      'Onboarding', 'Ka zirna kawng siam rawh', 'Build My Learning Path'),
  'welcome.eyebrow': AppTextDefault(
      'Onboarding', 'Mizo ṭawng hlim taka zirna', 'Mizo learning, made joyful'),
  'welcome.title': AppTextDefault('Onboarding',
      'I Mizo ṭawng kawngzawh hetah a ṭan.', 'Your Mizo journey starts here.'),
  'welcome.path': AppTextDefault(
      'Onboarding', 'Nangma tana kawng siam', 'A path built for you'),
  'welcome.pathNote': AppTextDefault(
      'Onboarding',
      'I thiamna leh i tum dân ang zêlin.',
      'Shaped by what you know and what you want.'),
  'welcome.offline':
      AppTextDefault('Onboarding', 'Khawiah pawh zir rawh', 'Learn anywhere'),
  'welcome.offlineNote': AppTextDefault(
      'Onboarding',
      'Game te hi internet nei lovin i phone-ah a khelh theih.',
      'Core games work offline on your device.'),
  'welcome.safe':
      AppTextDefault('Onboarding', 'Chhungkaw tan a him', 'Safe for families'),
  'welcome.safeNote': AppTextDefault(
      'Onboarding',
      'Mi dang nen inbiakna, advertisement, naupang inelna list a awm lo.',
      'No public chat, ads, or child leaderboard.'),
  'age.eyebrow': AppTextDefault(
      'Onboarding', 'I kawng siam rawh', 'Personalize your path'),
  'age.title':
      AppTextDefault('Onboarding', 'Tu nge zir dawn?', 'Who is learning?'),
  'age.subtitle': AppTextDefault(
      'Onboarding',
      'Kum chauh kan mamawh — pian ni emaw hming emaw kan dil lo.',
      'We only need an age range — no birthday or name.'),
  'proficiency.eyebrow': AppTextDefault(
      'Onboarding', 'I ṭanna zawng rawh', 'Find your starting point'),
  'proficiency.title': AppTextDefault(
      'Onboarding', 'Mizo ṭawng i thiam em?', 'How much Mizo do you know?'),
  'proficiency.subtitle': AppTextDefault(
      'Onboarding',
      'A dik tak thlang rawh — eng hunah pawh Keimah-ah i thlâk thei.',
      'Pick honestly — you can change it any time in Profile.'),
  'goal.eyebrow': AppTextDefault(
      'Onboarding', 'Pahnih thleng thlang rawh', 'Choose up to two'),
  'goal.title': AppTextDefault(
      'Onboarding', 'Eng nge i zir duh?', 'What would you like to learn?'),
  'goal.subtitle': AppTextDefault(
      'Onboarding',
      'I zir duh ber thlang la, ni tin hnaah kan dah hmasa ang.',
      'Pick what matters most and we\'ll put it first in your daily quests.'),
  'rhythm.eyebrow': AppTextDefault('Onboarding',
      'I hna hmasa ber atan i inpeih', 'Ready for your first quest'),
  'rhythm.title': AppTextDefault(
      'Onboarding', 'Ni tin i zir zat thlang rawh.', 'Set your daily rhythm.'),
  'rhythm.subtitle': AppTextDefault(
      'Onboarding',
      'Tlem tê tê, ni tin zir hi zirna kawng ṭha ber a ni.',
      'A little every day is the best way to learn.'),
  'welcome.subtitle': AppTextDefault(
      'Onboarding',
      'Khelh pahin thumal, hawrawp ziah dan, chhiarna leh Mizo nunphung zir rawh.',
      'Learn words, spelling, reading and Mizo culture as you play.'),
  'rhythm.goal': AppTextDefault('Onboarding', 'NI TIN TUM', 'DAILY GOAL'),
  'rhythm.minutes': AppTextDefault('Onboarding', 'Minute {n}', '{n} min'),
  'rhythm.privacy': AppTextDefault(
      'Onboarding',
      'Account a ngai lo • I hmasawnna i phone-ah a awm',
      'Guest-first • Progress stays on this device'),
  // Profile • learning level
  'track.beginner':
      AppTextDefault('Profile • learning level', 'Bulṭan', 'Beginner'),
  'track.explorer':
      AppTextDefault('Profile • learning level', 'Zirchho', 'Explorer'),
  'track.master':
      AppTextDefault('Profile • learning level', 'Thiamna', 'Master'),
  'track.beginner.note': AppTextDefault(
      'Profile • learning level',
      'Milem leh thumal awlsam hmanga bulṭan',
      'Start with pictures and easy words'),
  'track.explorer.note': AppTextDefault(
      'Profile • learning level',
      'Hawrawp ziah dan leh puzzle hmanga zir chhunzawm',
      'Keep going with spelling and puzzles'),
  'track.master.note': AppTextDefault('Profile • learning level',
      'Tawng upa leh thufing zirna', 'Old sayings and proverbs'),
  // Word categories
  'category.chhungkua':
      AppTextDefault('Word categories', 'Chhungkua', 'Family'),
  'category.sikul': AppTextDefault('Word categories', 'Sikul', 'School'),
  'category.nungcha': AppTextDefault('Word categories', 'Nungcha', 'Animals'),
  'category.khawvel': AppTextDefault('Word categories', 'Khawvel', 'World'),
  'category.nunphung':
      AppTextDefault('Word categories', 'Nunphung', 'Way of life'),
  'category.thiltih': AppTextDefault('Word categories', 'Thiltih', 'Actions'),
  // Journey
  'journey.title': AppTextDefault('Journey', 'Mizo Kawngzawh', 'Mizo Journey'),
  'journey.subtitle': AppTextDefault('Journey',
      'Thawnthu, inbiakna leh hnam nun', 'Story, conversation & culture'),
  'journey.todaysQuests':
      AppTextDefault('Journey', 'Vawiin hna', 'Today\'s Quests'),
  'journey.map': AppTextDefault('Journey', 'Kawngzawh Map', 'Journey Map'),
  'journey.cultureTrail':
      AppTextDefault('Journey', 'Hnam Nun Kawng', 'Culture Trail'),
  'journey.cultureTrailNote': AppTextDefault('Journey',
      'Thumal, ngaihhlutna leh hnam nun', 'Words, values & living culture'),
  'journey.cultureCount': AppTextDefault(
      'Journey',
      'Card {collected}/{total} • Tawng upa chanchin',
      '{collected}/{total} cards • Tawng Upa context'),
  'journey.eyebrow':
      AppTextDefault('Journey', 'I MIZO KAWNGZAWH', 'YOUR MIZO JOURNEY'),
  'journey.progress': AppTextDefault(
      'Journey',
      'Thawnthu {total} zingah {done} i zo',
      '{done} of {total} story stops complete'),
  'journey.rhythm':
      AppTextDefault('Journey', 'Zirna kalphung', 'Learning rhythm'),
  'journey.rhythmDays':
      AppTextDefault('Journey', 'Ni {n} indawt', '{n} day rhythm'),
  'journey.graceReady':
      AppTextDefault('Journey', 'Ni khat chawl theih', 'Grace ready'),
  'journey.graceUsed':
      AppTextDefault('Journey', 'Ni chawl i hmang tawh', 'Grace used'),
  'journey.thisWeek':
      AppTextDefault('Journey', 'Kar khatah {n}/3', '{n}/3 this week'),
  'journey.trailMarks':
      AppTextDefault('Journey', 'Chhinchhiahna {n}', '{n} Trail Marks'),
  'journey.welcomeBack':
      AppTextDefault('Journey', 'Lo kir leh rawh, i lawm e', 'Welcome back'),
  'journey.welcomeBackNote': AppTextDefault(
      'Journey',
      'I kalna hmasa a bo lo. Minute tlem chauh hmangin thawnthu chhunzawm rawh.',
      'Your progress is safe. Pick the story back up in just a few minutes.'),
  'journey.dailyGentle': AppTextDefault('Journey',
      'NI TIN • DUH THLAN • HREMNA AWM LO', 'OPTIONAL DAILY • NO PENALTY'),
  'journey.daily': AppTextDefault('Journey', 'NI TIN', 'DAILY'),
  'journey.weeklyGentle': AppTextDefault(
      'Journey',
      'KAR TIN • DUH THLAN • HUN BITUK AWM LO',
      'OPTIONAL WEEKLY • NO DEADLINE'),
  'journey.weekly': AppTextDefault(
      'Journey', 'KAR TIN • HUN CHHIAR AWM LO', 'WEEKLY • NO COUNTDOWN'),
  'journey.claim': AppTextDefault('Journey', 'La rawh +{n}', 'Claim +{n}'),
  'journey.preview': AppTextDefault(
      'Journey',
      'Content en chhinna — Mizo ṭawng thiam mi pawmna a la nghah mêk.',
      'Preview content — awaiting Mizo language review.'),
  'journey.nodeSpoken':
      AppTextDefault('Journey', '{title}, {status}', '{title}, {status}'),
  'journey.nodeLevel': AppTextDefault('Journey', 'Level {n}', 'Level {n}'),
  'journey.replay': AppTextDefault('Journey', 'CHHIAR LEH', 'REPLAY'),
  'journey.start': AppTextDefault('Journey', 'ṬAN RAWH', 'START'),
  'journey.collection':
      AppTextDefault('Journey', 'Ka Dahkhawm', 'My Collection'),
  'journey.viewAll': AppTextDefault('Journey', 'A vaiin en rawh', 'View All'),
  'journey.firstReward': AppTextDefault(
      'Journey',
      'Thawnthu hmasa ber i zawh hunah lawmman i hmu ang.',
      'You\'ll earn a reward when you finish your first Story Quest.'),
  'story.title': AppTextDefault('Journey', 'Thawnthu', 'Story Quest'),
  'story.chooseReply': AppTextDefault(
      'Journey', 'Chhanna remchang thlang rawh', 'Choose a natural reply'),
  'story.complete':
      AppTextDefault('Journey', 'Thawnthu zo rawh', 'Complete Story'),
  'story.completeTitle':
      AppTextDefault('Journey', 'Thawnthu i zo ta', 'Story Complete'),
  'story.wellDone': AppTextDefault('Journey', 'I ti ṭha e!', 'Well done!'),
  'story.reward': AppTextDefault('Journey', 'Thawnthu lawmman', 'Story reward'),
  'story.cultureMoment':
      AppTextDefault('Journey', 'HNAM NUN', 'CULTURE MOMENT'),
  'story.saved': AppTextDefault('Journey', 'Dah ṭha', 'Saved'),
  'story.read': AppTextDefault('Journey', 'Ka chhiar tawh', 'I read this'),
  'story.stop':
      AppTextDefault('Journey', 'Chawl hun ṭha', 'A good stopping point'),
  'story.stopNote': AppTextDefault(
      'Journey',
      'Vawiin tâna i zirna a tâwk tawh. Naktûkah hlim takin i chhunzawm leh thei e.',
      'That\'s enough for today. Come back tomorrow and keep going.'),
  'story.finish':
      AppTextDefault('Journey', 'Tunah chawl rawh', 'Finish for Now'),
  'story.stepSpoken': AppTextDefault(
      'Journey', 'Thawnthu {total} zingah {n}-na', 'Story step {n} of {total}'),
  'story.conversation': AppTextDefault('Journey',
      'Inbiakna {total} zingah {n}-na', 'Conversation {n} of {total}'),
  // Culture
  'culture.title': AppTextDefault('Culture', 'Hnam Nun Kawng', 'Culture Trail'),
  'culture.collected': AppTextDefault('Culture',
      'Card {n}/{total} i khawl tawh', '{n}/{total} cards collected'),
  'culture.eyebrow':
      AppTextDefault('Culture', 'MIZO HNAM NUN KAWNG', 'MIZO CULTURE TRAIL'),
  'culture.intro': AppTextDefault(
      'Culture',
      'Thumal, hnam nun leh a hman dân zir rawh.',
      'Learn words, culture and how they are used.'),
  'culture.marks': AppTextDefault(
      'Culture',
      'Chhinchhiahna {n} • Zirna a hawng reng',
      '{n} Trail Marks • Lessons stay open'),
  'culture.cards': AppTextDefault('Culture', 'Hnam Nun Card', 'Culture Cards'),
  'culture.preview': AppTextDefault(
      'Culture',
      'Content en chhinna — ṭawng leh hnam nun thiam mi pawmna a la nghah mêk.',
      'Preview content — awaiting language and culture review.'),
  'culture.noDeadline':
      AppTextDefault('Culture', 'HUN BITUK AWM LO', 'NO DEADLINE'),
  'culture.unlockAt': AppTextDefault(
      'Culture', 'Level {n}-ah a hawng ang', 'Unlock at Level {n}'),
  'culture.keepLearning': AppTextDefault('Culture',
      'Zirna level chhunzawm rawh.', 'Keep learning to reach this level.'),
  'culture.cardTitle':
      AppTextDefault('Culture', 'Hnam Nun Card', 'Culture Card'),
  'culture.usage': AppTextDefault(
      'Culture', 'A hman dân leh a nihna', 'How it is used and what it means'),
  'culture.example': AppTextDefault('Culture', 'Entîrna', 'Example'),
  'culture.readToday':
      AppTextDefault('Culture', 'Vawiin chhiar rawh', 'Read Today'),
  'culture.readAgain':
      AppTextDefault('Culture', 'Chhiar leh rawh', 'Read Again'),
  'culture.add':
      AppTextDefault('Culture', 'Ka dahkhawmah dah rawh', 'Add to Collection'),
  'culture.report': AppTextDefault(
      'Culture', 'Content dik lo hriattir rawh', 'Report a Content Issue'),
  'collection.title': AppTextDefault('Culture', 'Ka Dahkhawm', 'My Collection'),
  'collection.count': AppTextDefault(
      'Culture', 'Hnam nun card {n}/{total}', '{n}/{total} culture cards'),
  'collection.marks':
      AppTextDefault('Culture', 'Chhinchhiahna {n}', '{n} Trail Marks'),
  'collection.note': AppTextDefault(
      'Culture',
      'Lawmna chauh a ni • Zirna pakhatmah a khar lo',
      'Recognition only • No lesson is locked'),
  'collection.style':
      AppTextDefault('Culture', 'Ka hmel thlang rawh', 'Choose My Style'),
  'collection.milestones':
      AppTextDefault('Culture', 'Hmasawnna chhinchhiahna', 'Milestones'),
  'collection.firstCard': AppTextDefault(
      'Culture',
      'Hnam Nun Kawng-ah card pakhat chhiar hmasa rawh.',
      'Read your first card on the Culture Trail.'),
  'collection.rewards':
      AppTextDefault('Culture', 'Thawnthu lawmman', 'Story Rewards'),
  'collection.firstReward': AppTextDefault(
      'Culture',
      'Thawnthu hmasa ber i zawh hunah lawmman i hmu ang.',
      'You\'ll earn a reward when you finish your first Story Quest.'),
  'collection.avatarLocked': AppTextDefault('Culture',
      '{avatar} • Chhinchhiahna {marks}', '{avatar} • {marks} marks'),
  // Journey quests
  'quest.story':
      AppTextDefault('Journey quests', 'Thawnthu pen khat', 'Story Step'),
  'quest.story.note': AppTextDefault(
      'Journey quests', 'Thawnthu pakhat zo rawh.', 'Finish one Story Quest.'),
  'quest.words':
      AppTextDefault('Journey quests', 'Thumal vengtu', 'Word Keeper'),
  'quest.words.note': AppTextDefault(
      'Journey quests', 'Thumal pathum en leh rawh.', 'Review three words.'),
  'quest.culture':
      AppTextDefault('Journey quests', 'Hnam nun hun', 'Culture Moment'),
  'quest.culture.note': AppTextDefault('Journey quests',
      'Hnam nun thu pakhat chhiar rawh.', 'Read one culture note.'),
  'quest.storyWeek':
      AppTextDefault('Journey quests', 'Thawnthu kar', 'Story Week'),
  'quest.storyWeek.note': AppTextDefault(
      'Journey quests',
      'Kar khat chhûngin thawnthu pathum zo rawh.',
      'Finish three Story Quests this week.'),
  'quest.cultureWeek':
      AppTextDefault('Journey quests', 'Hnam nun kar', 'Culture Trail Week'),
  'quest.cultureWeek.note': AppTextDefault(
      'Journey quests',
      'Kar khat chhûngin hnam nun card pathum chhiar rawh.',
      'Read three Culture Cards this week.'),
};
