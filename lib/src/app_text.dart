/// Every label, button and message in the app, by ID, with the text it shows
/// unless the content Sheet's “App text” tab says otherwise. The Sheet's rows
/// are made from [appTextDefaults], so a new text here needs a new row there
/// (content_studio/README.md).
library;

/// The language the app's own labels and messages are shown in. Simple
/// English is the default, so anyone can play; the Mizo is in the games'
/// words, learnt along the way. Mizo is an option in Profile.
enum AppLanguage { english, mizo }

/// One text's built-in wording and where in the app it shows.
class AppTextDefault {
  const AppTextDefault(this.where, this.text, this.mizo);

  /// The screen or part of the app, so an editor can find it.
  final String where;

  /// The English wording: what the Sheet's “Built-in text” shows.
  final String text;

  /// The same text in Mizo, for [AppLanguage.mizo].
  final String mizo;
}

/// The `{name}` placeholders in [text], which the app fills in.
Set<String> appTextPlaceholders(String text) =>
    RegExp(r'\{(\w+)\}').allMatches(text).map((match) => match[1]!).toSet();

abstract final class AppText {
  static Map<String, String> _delivered = const <String, String>{};

  /// The Sheet's texts from the active content pack.
  static void update(Map<String, String> delivered) => _delivered = delivered;

  /// The learner's choice in Profile.
  static AppLanguage language = AppLanguage.english;

  /// [id]'s text with its `{name}` placeholders filled from [values]. Sheet
  /// text is used only when it has the same placeholders as the built-in
  /// text, so a typo there can't show a raw `{name}` or drop a number. The
  /// Sheet edits the English wording, so Mizo shows the built-in Mizo.
  static String of(String id,
      [Map<String, Object?> values = const <String, Object?>{}]) {
    final builtIn = appTextDefaults[id];
    final mizo = language == AppLanguage.mizo;
    final fallback = (mizo ? builtIn?.mizo : builtIn?.text) ?? id;
    final sheet = mizo ? null : _delivered[id];
    var text = sheet != null &&
            _sameSet(appTextPlaceholders(sheet), appTextPlaceholders(fallback))
        ? sheet
        : fallback;
    values.forEach(
        (name, value) => text = text.replaceAll('{$name}', '${value ?? ''}'));
    return text;
  }

  /// [mizo] or [english], whichever the app is shown in: for content that
  /// has both, such as the journey's story titles.
  static String pick({required String mizo, required String english}) =>
      language == AppLanguage.mizo || english.isEmpty ? mizo : english;

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

const appTextDefaults = <String, AppTextDefault>{
  // Content review
  'review.title': AppTextDefault(
      'Content review', 'Checking content', 'Content en fel mêk a ni'),
  'review.body': AppTextDefault(
      'Content review',
      'Mizo experts are still checking this content. It will appear when it is ready.',
      'Mizo ṭawng thiam mi te\'n content hi an la en fel mêk a. An pawm hma chuan app-ah kan dah lo.'),
  // Navigation
  'nav.home': AppTextDefault('Navigation', 'Home', 'In'),
  'nav.learn': AppTextDefault('Navigation', 'Learn', 'Zir'),
  'nav.games': AppTextDefault('Navigation', 'Games', 'Khel'),
  'nav.profile': AppTextDefault('Navigation', 'Profile', 'Keimah'),
  // Profile • content
  'content.offline': AppTextDefault(
      'Profile • content', 'Offline words', 'Internet nei lovin'),
  'content.version': AppTextDefault(
      'Profile • content', 'Content {version}', 'Content {version}'),
  'content.check': AppTextDefault(
      'Profile • content', 'Check for new words', 'Thil thar awm em en rawh'),
  'content.builtIn':
      AppTextDefault('Profile • content', 'Built-in words', 'App-a awm sa'),
  'sync.builtInReady': AppTextDefault(
      'Profile • content',
      'Words are ready to play offline.',
      'App-a zirna awm sa hi internet nei lovin a hman theih.'),
  'sync.packsReady': AppTextDefault(
      'Profile • content',
      'Your words are ready offline.',
      'Content endik fel sa hi internet nei lovin a hman theih.'),
  'sync.checking': AppTextDefault('Profile • content',
      'Checking for new words…', 'Content thar awm em kan en mêk…'),
  'sync.updated': AppTextDefault(
      'Profile • content', 'New words added.', 'Content thar a lut ṭha ta.'),
  'sync.upToDate': AppTextDefault('Profile • content',
      'You have the latest words.', 'Content thar ber i nei tawh.'),
  'sync.rejected': AppTextDefault(
      'Profile • content',
      'This update had a problem, so we skipped it. Your words still work. {error}',
      'Content thar hi a ṭha lo avangin kan la lo. I content awm sa chu i hmang thei reng. {error}'),
  'sync.unavailable': AppTextDefault(
      'Profile • content',
      'Could not check for new words. Your words still work.',
      'Tunah hian content thar kan la thei lo. I content awm sa chu i hmang thei reng.'),
  // Content report
  'report.done':
      AppTextDefault('Content report', 'Issue reported', 'Kan hriattir tawh'),
  'report.open': AppTextDefault(
      'Content report', 'Report content issue', 'Content dik lo hriattir rawh'),
  'report.title': AppTextDefault(
      'Content report', 'Report a content issue', 'Content dik lo hriattirna'),
  'report.privacy': AppTextDefault(
      'Content report',
      'We don\'t collect personal messages. Your report stays on this device.',
      'I thu mal kan la lo. Content leh a chhan chauh hi i phone-ah a awm a, en fel turin kan dah.'),
  'report.spelling': AppTextDefault('Content report',
      'Mizo spelling or wording', 'Mizo ziah dan emaw thumal hman dan'),
  'report.meaning': AppTextDefault(
      'Content report', 'Meaning or translation', 'Awmzia emaw lehlin dan'),
  'report.picture': AppTextDefault(
      'Content report', 'Picture does not match', 'Milem a inmil lo'),
  'report.culture':
      AppTextDefault('Content report', 'Cultural context', 'Hnam nun lam'),
  'report.save':
      AppTextDefault('Content report', 'Save Report', 'Dah ṭha rawh'),
  'report.saved': AppTextDefault('Content report', 'Report saved. Thank you!',
      'I hriattirna chu en fel turin kan dah ṭha e.'),
  // Home
  'home.games': AppTextDefault('Home', 'Games', 'Khel'),
  'home.viewAll': AppTextDefault('Home', 'View All', 'A vaiin en rawh'),
  'home.journey': AppTextDefault('Home', 'Mizo Journey', 'Mizo Kawngzawh'),
  'home.viewMap': AppTextDefault('Home', 'View Map', 'Map en rawh'),
  'home.storyPath': AppTextDefault('Home', 'STORY PATH', 'THAWNTHU KAWNG'),
  'home.journeyComplete':
      AppTextDefault('Home', 'Journey Complete', 'Kawngzawh i zo ta'),
  'home.journeyContinue': AppTextDefault(
      'Home', 'Continue Your Journey', 'I kawngzawh chhunzawm rawh'),
  'home.journeyProgress': AppTextDefault(
      'Home',
      '{done}/{total} story stops • Daily quests',
      'Thawnthu {total} zingah {done} i zo • Ni tin hna'),
  'home.greeting': AppTextDefault('Home', 'Chibai! 👋', 'Chibai! 👋'),
  'app.name': AppTextDefault('Home', 'Hnahsin', 'Hnahsin'),
  'home.xpLevel': AppTextDefault('Home', 'Lv {level}', 'Lv {level}'),
  'home.todaysGame': AppTextDefault('Home', 'TODAY\'S GAME', 'VAWIIN GAME'),
  'home.best': AppTextDefault('Home', 'Best {score}', 'A sang ber {score}'),
  'home.replay': AppTextDefault(
      'Home', '{n} words to see again', 'Thumal {n} i hmuh leh tur a awm'),
  'home.roundsToday':
      AppTextDefault('Home', '{done}/{goal}\nROUNDS', '{done}/{goal}\nKHELH'),
  'home.rhythm': AppTextDefault('Home', 'Learning rhythm', 'Zirna kalphung'),
  'home.streak': AppTextDefault('Home', '{n} day streak', 'Ni {n} indawt'),
  'home.startToday': AppTextDefault('Home', 'Start today', 'Vawiin ṭan rawh'),
  'home.play': AppTextDefault('Home', 'Play', 'Khel rawh'),
  'home.otherGame':
      AppTextDefault('Home', 'Play another game', 'Game dang khel rawh'),
  // Learn
  'learn.eyebrow': AppTextDefault('Learn', 'Your learning', 'I zirna'),
  'learn.title': AppTextDefault('Learn', 'Learn', 'Zir'),
  'learn.subtitle': AppTextDefault(
      'Learn',
      '{level} {title} • Keep learning at your own pace.',
      '{level} {title} • Mahni chak zawngin zir chhunzawm rawh.'),
  'learn.library': AppTextDefault('Learn', 'Word Library', 'Thumal Dahkhawmna'),
  'learn.libraryCount': AppTextDefault(
      'Learn',
      '{words} words • {categories} topics',
      'Thumal {words} • Chi {categories}'),
  'learn.due': AppTextDefault('Learn', 'TO REVIEW', 'EN LEH TUR'),
  'learn.new': AppTextDefault('Learn', 'NEW', 'THAR'),
  'learn.mastered': AppTextDefault('Learn', 'MASTERED', 'THIAM TAWH'),
  'learn.startLesson':
      AppTextDefault('Learn', 'Start today\'s lesson', 'Vawiin zirna ṭan rawh'),
  'learn.findLevel':
      AppTextDefault('Learn', 'Find your level', 'I level hre chhuak rawh'),
  'learn.retakeLevel':
      AppTextDefault('Learn', 'Check your level again', 'Level en leh rawh'),
  'learn.continue':
      AppTextDefault('Learn', 'Keep learning', 'Zir chhunzawm rawh'),
  // Games
  'games.eyebrow': AppTextDefault('Games', 'Practice arena', 'Inzirna hmun'),
  'games.title': AppTextDefault('Games', 'Games', 'Khel'),
  'games.subtitle': AppTextDefault(
      'Games',
      'Pick a game and beat your best score.',
      'I duh zawng thlang la, i mark sang ber siam rawh.'),
  'games.played': AppTextDefault('Games', 'PLAYED', 'I KHEL TAWH'),
  'games.level': AppTextDefault('Games', 'Lv {level}', 'Lv {level}'),
  'games.best': AppTextDefault('Games', '★ {score}', '★ {score}'),
  'games.play': AppTextDefault('Games', 'PLAY', 'KHEL RAWH'),
  // Profile
  'profile.eyebrow': AppTextDefault('Profile', 'Your journey', 'I kawngzawh'),
  'profile.title': AppTextDefault('Profile', 'Profile', 'Keimah'),
  'profile.subtitle': AppTextDefault(
      'Profile',
      'See your progress and levels here.',
      'I zirna hmasawnna leh level te hetah en rawh.'),
  'profile.name':
      AppTextDefault('Profile', 'Hnahsin {experience}', 'Thumal {experience}'),
  'profile.xpToNext': AppTextDefault('Profile', '{xp}/250 XP to the next level',
      '{xp}/250 XP level thar atan'),
  'profile.calm': AppTextDefault('Profile', 'Calm', 'Muang takin'),
  'profile.myPace': AppTextDefault('Profile', 'My Pace', 'Ka chak zawngin'),
  'profile.dayStreak': AppTextDefault('Profile', 'Day Streak', 'Ni indawt'),
  'profile.games': AppTextDefault('Profile', 'Games', 'Khelh zat'),
  'profile.lessons': AppTextDefault('Profile', 'Lessons', 'Zirna'),
  'profile.journey': AppTextDefault(
      'Profile', 'Mizo Journey Collection', 'Mizo Kawngzawh Dahkhawmna'),
  'profile.journeyCount': AppTextDefault(
      'Profile',
      '{stories}/{total} stories • {rewards} rewards',
      'Thawnthu {stories}/{total} • Lawmman {rewards}'),
  'profile.settings': AppTextDefault('Profile', 'My settings', 'Ka duh dan'),
  'profile.dailyGoal': AppTextDefault('Profile', 'Daily goal', 'Ni tin tum'),
  'profile.dailyGoalNote': AppTextDefault(
      'Profile',
      'About one game round a minute; Home\'s ring fills when you reach it.',
      'Minute khatah game khat vel a ni; i tum i thlen chuan In-a bial chu a khat ang.'),
  'profile.appLanguage': AppTextDefault('Profile', 'App language', 'App ṭawng'),
  'profile.appLanguageNote': AppTextDefault(
      'Profile', 'Buttons and messages', 'Button leh thuchah te ṭawng'),
  'profile.sound': AppTextDefault('Profile', 'Sound', 'Ri'),
  'profile.soundNote': AppTextDefault(
      'Profile',
      'Sounds for right and wrong answers and finished rounds',
      'Chhanna dik, dik lo leh game zawh ri'),
  'profile.credits': AppTextDefault('Profile', 'Credits', 'A lakna hmun'),
  'profile.creditsBody': AppTextDefault(
      'Profile',
      'Sentences from Mizo-Language-Corpus-4M by MWireLabs (CC BY 4.0; sources IndicNLCorp, FineWeb and DIPR Mizoram) and the Mizo–English parallel dataset by Hillbyte AI. Word checks from J.F. Laldailova\'s English–Lushai Dictionary.',
      'Sentence te hi MWireLabs-a Mizo-Language-Corpus-4M (CC BY 4.0; IndicNLCorp, FineWeb leh DIPR Mizoram aṭanga lak) leh Hillbyte AI-a Mizo–English dataset aṭanga lak an ni. Thumal endikna hi J.F. Laldailova-a English–Lushai Dictionary aṭanga lak a ni.'),
  'profile.ageRange': AppTextDefault('Profile', 'Age range', 'Kum'),
  'profile.englishNote': AppTextDefault(
      'Profile',
      'Show English beside the Mizo in stories and culture cards.',
      'Thawnthu leh hnam nun card-ah Mizo bulah English pawh tilang rawh.'),
  'profile.xpLevel': AppTextDefault('Profile', 'Lv {level}', 'Lv {level}'),
  'profile.family':
      AppTextDefault('Profile', 'Family-friendly', 'Chhungkaw tan a him'),
  'profile.familyNote': AppTextDefault(
      'Profile',
      'No public chat • Progress saved on this device',
      'Mi dang nen inbiakna a awm lo • I hmasawnna i phone-ah a awm'),
  'profile.reduceMotion':
      AppTextDefault('Profile', 'Reduce motion', 'Che tlem zawk'),
  'profile.reduceMotionNote': AppTextDefault(
      'Profile', 'Fewer animations', 'Animation tlem zawk hmang rawh'),
  'profile.gentle':
      AppTextDefault('Profile', 'Gentle engagement', 'Nawr lovin'),
  'profile.gentleNote': AppTextDefault(
      'Profile',
      'Quests are optional, no streak pressure',
      'Hna te hi duh thlan a ni a, ni indawt nawrna a lang lo'),
  'profile.reset': AppTextDefault(
      'Profile', 'Reset Local Progress', 'Hmasawnna paih vek rawh'),
  'profile.resetTitle': AppTextDefault(
      'Profile', 'Reset local progress?', 'I hmasawnna paih vek dawn em?'),
  'profile.resetBody': AppTextDefault(
      'Profile',
      'Your XP, scores, settings and saved game sessions on this device will be deleted. This cannot be undone.',
      'He phone-a i XP, mark, i duh dan leh game i dah ṭhat te chu an bo vek ang. Siam ṭhat leh theih a ni lo.'),
  'profile.resetConfirm': AppTextDefault('Profile', 'Reset', 'Paih vek rawh'),
  'profile.badge.older': AppTextDefault('Profile', 'Journey', 'Kawngzawh'),
  // Common
  'common.cancel': AppTextDefault('Common', 'Cancel', 'Ti lo ang'),
  'common.back': AppTextDefault('Common', 'Back', 'Kir leh'),
  'common.continue': AppTextDefault('Common', 'Continue', 'Chhunzawm rawh'),
  'common.viewResults':
      AppTextDefault('Common', 'View Results', 'I hmuh zat en rawh'),
  'common.next': AppTextDefault('Common', 'Next', 'A dawt'),
  'common.next.mizo': AppTextDefault('Common', 'Next', 'A dawt'),
  // Word Library
  'library.count': AppTextDefault('Word Library', '{n} words', 'Thumal {n}'),
  'library.all': AppTextDefault('Word Library', 'All', 'Zawng zawng'),
  // Game screen
  'hud.relaxedSpoken': AppTextDefault(
      'Game screen',
      'Relaxed mode. Score {score}. Progress {percent} percent.',
      'Hahdam takin. Mark {score}. {percent} zaa khat i zo.'),
  'hud.heartsSpoken': AppTextDefault('Game screen',
      '{hearts} of {total} hearts.', 'Thinlung {total} zingah {hearts} i nei.'),
  'hud.secondsSpoken': AppTextDefault('Game screen',
      '{seconds} seconds remaining.', 'Second {seconds} a la awm.'),
  'hud.scoreSpoken': AppTextDefault(
      'Game screen',
      'Score {score}. Progress {percent} percent.',
      'Mark {score}. {percent} zaa khat i zo.'),
  'hud.relaxed': AppTextDefault('Game screen', 'Relaxed', 'Hahdam'),
  'game.restored': AppTextDefault(
      'Game screen',
      'Saved game restored — picking up where you left off.',
      'I khelhna hmasa kha kan chhunzawm e.'),
  'game.hintUsed':
      AppTextDefault('Game screen', 'Hint used', 'Ṭanpuina i la tawh'),
  'game.useHint':
      AppTextDefault('Game screen', 'Use a hint', 'Ṭanpuina la rawh'),
  'answer.correctSpoken':
      AppTextDefault('Game screen', '{answer}, correct', '{answer}, a dik'),
  'answer.incorrectSpoken': AppTextDefault(
      'Game screen', '{answer}, incorrect', '{answer}, a dik lo'),
  'feedback.correctSpoken': AppTextDefault('Game screen', 'Correct', 'A dik'),
  'feedback.retrySpoken':
      AppTextDefault('Game screen', 'Try again', 'Tum leh rawh'),
  // Game result
  'result.timeUp':
      AppTextDefault('Game result', 'Time is up!', 'Hun a tawp ta!'),
  'result.outOfHearts':
      AppTextDefault('Game result', 'Out of hearts!', 'Tunah chuan a tâwk e!'),
  'result.done': AppTextDefault('Game result', 'You did it!', 'I ti thei e!'),
  'result.timeUpNote': AppTextDefault(
      'Game result',
      'Time ran out. Every answer you gave is saved.',
      'Hun a tâwp ta. I chhân tawhte chu a save vek e.'),
  'result.outOfHeartsNote': AppTextDefault(
      'Game result',
      'Your score is saved. Try again and you will get better.',
      'I mark chu a save tawh. Tum leh la, i thiam chho ang.'),
  'result.doneNote': AppTextDefault(
      'Game result',
      'Nice work! New words are sticking.',
      'Khelh pahin Mizo ṭawng i thiam chho zêl e.'),
  'result.score': AppTextDefault('Game result', 'SCORE', 'MARK'),
  'result.accuracy': AppTextDefault('Game result', 'ACCURACY', 'A DIK ZAT'),
  'result.xp': AppTextDefault('Game result', 'XP', 'XP'),
  'result.playAgain':
      AppTextDefault('Game result', 'Play again', 'Khel leh rawh'),
  'result.words':
      AppTextDefault('Game result', 'Words in this round', 'Thumal i hmuh te'),
  'result.missedNote': AppTextDefault(
      'Game result',
      'The red ones will come back next time you play.',
      'A sen te hi i khelh leh hunah an lo lang leh ang.'),
  'result.levelUp': AppTextDefault(
      'Game result', 'Level up! {from} → {to}', 'Level i kai! {from} → {to}'),
  'result.levelDown': AppTextDefault(
      'Game result',
      'Level {level} — a little easier next time',
      'Level {level} — awlsam deuhvin kan ṭan leh ang'),
  'result.levelProgress': AppTextDefault(
      'Game result',
      'Level {level} • {percent}% to the next level',
      'Level {level} • Level thar thlengin {percent}%'),
  // Game level
  'gameLevel.spoken': AppTextDefault(
      'Game level', 'Level {level} of 7', 'Level 7 zingah {level}'),
  'gameLevel.master': AppTextDefault(
      'Game level', 'Level 7 • Master', 'Level 7 • Thiam famkim'),
  'gameLevel.level':
      AppTextDefault('Game level', 'Level {level}', 'Level {level}'),
  'gameLevel.note': AppTextDefault(
      'Game level',
      'Words get harder as you improve.',
      'I thiam chhoh dan zirin thumal a harsa chho zel ang.'),
  // Game start
  'launcher.howToPlay':
      AppTextDefault('Game start', 'HOW TO PLAY', 'KHELH DAN'),
  'launcher.saved': AppTextDefault(
      'Game start', 'Saved game available', 'Game i dah ṭhat a awm'),
  'launcher.savedDetail': AppTextDefault('Game start',
      '{mode} mode • {attempts} attempts', '{mode} • Vawi {attempts} i chhang'),
  'launcher.modeName.relaxed':
      AppTextDefault('Game start', 'relaxed', 'Hahdam'),
  'launcher.modeName.standard':
      AppTextDefault('Game start', 'standard', 'Pangngai'),
  'launcher.modeName.timed': AppTextDefault('Game start', 'timed', 'Hun bituk'),
  'launcher.chooseMode':
      AppTextDefault('Game start', 'Choose a mode', 'Khelh dan thlang rawh'),
  'launcher.relaxed': AppTextDefault('Game start',
      'Relaxed — no hearts to lose', 'Hahdam — Thinlung chân lovin'),
  'launcher.standard': AppTextDefault(
      'Game start', 'Standard — 3 hearts', 'Pangngai — Thinlung 3 nen'),
  'launcher.timed': AppTextDefault(
      'Game start', 'Timed — 90 seconds', 'Hun bituk — Second 90 chhungin'),
  'launcher.start': AppTextDefault('Game start', 'Start Game', 'Ṭan rawh'),
  'launcher.resume':
      AppTextDefault('Game start', 'Resume Game', 'Chhunzawm rawh'),
  'launcher.startNew':
      AppTextDefault('Game start', 'Start New Game', 'A thar ṭan rawh'),
  // Word cards
  'cards.title': AppTextDefault('Word cards', 'Word Cards', 'Thumal Card'),
  'cards.count': AppTextDefault('Word cards', '{n}/{total} cards • {gold} gold',
      'Card {n}/{total} • Rangkachak {gold}'),
  'cards.how': AppTextDefault(
      'Word cards',
      'Get a word right in two games to collect its card. Get it right four times in a row and it turns gold.',
      'Game pahnihah thumal i chhan dik chuan a card i hmu ang. Vawi li indawt i chhan dik chuan a card a rangkachak ang.'),
  'cards.new':
      AppTextDefault('Word cards', 'New word cards', 'Thumal card thar'),
  'cards.open': AppTextDefault('Word cards', 'See all', 'A vaiin en rawh'),
  'cards.cardSpoken':
      AppTextDefault('Word cards', '{word} card', '{word} card'),
  'cards.goldSpoken': AppTextDefault(
      'Word cards', '{word}, gold card', '{word}, card rangkachak'),
  'cards.lockedSpoken': AppTextDefault(
      'Word cards', 'Card not collected yet', 'Card i la hmu lo'),
  // Daily puzzles
  'daily.title':
      AppTextDefault('Daily puzzles', 'Daily puzzles', 'Ni tin puzzle'),
  'daily.subtitle': AppTextDefault(
      'Daily puzzles',
      'The same puzzle for everyone today',
      'Vawiinah mi zawng zawng tan puzzle inang'),
  'daily.eyebrow':
      AppTextDefault('Daily puzzles', 'DAILY PUZZLE', 'NI TIN PUZZLE'),
  'daily.puzzle': AppTextDefault('Daily puzzles', '{game} #{n}', '{game} #{n}'),
  'daily.play':
      AppTextDefault('Daily puzzles', 'Play today\'s', 'Vawiin mi khel rawh'),
  'daily.done':
      AppTextDefault('Daily puzzles', 'Done in {time}', '{time}-ah i zo'),
  'daily.comeBack': AppTextDefault('Daily puzzles',
      'A new puzzle comes tomorrow.', 'Naktukah puzzle thar a lo awm ang.'),
  'daily.time': AppTextDefault('Daily puzzles', 'TIME', 'HUN'),
  'daily.hints': AppTextDefault('Daily puzzles', 'HINTS', 'ṬANPUINA'),
  'daily.share': AppTextDefault('Daily puzzles', 'Share', 'Share rawh'),
  'daily.copied': AppTextDefault(
      'Daily puzzles',
      'Copied. Paste it anywhere to share.',
      'Copy a ni. Share turin paste rawh.'),
  'daily.marksSpoken': AppTextDefault(
      'Daily puzzles',
      '{clean} of {total} words without help',
      'Thumal {total} zingah {clean} ṭanpuina lovin'),
  'daily.shareText': AppTextDefault(
      'Daily puzzles',
      'Hnahsin {puzzle}\n{marks}\n⏱ {time} · 💡 {hints}',
      'Hnahsin {puzzle}\n{marks}\n⏱ {time} · 💡 {hints}'),
  // Picture Match
  'picture.right':
      AppTextDefault('Picture Match', '{word} — {gloss}', '{word} — {gloss}'),
  'picture.wrong': AppTextDefault(
      'Picture Match',
      'The answer is “{word}”.\n{meaning}\n“{example}”',
      'Chhanna dik chu “{word}” a ni.\n{meaning}\n“{example}”'),
  // Spelling
  'spelling.clue':
      AppTextDefault('Spelling', 'CLUE  •  {hint}', 'KAWHHMUHNA  •  {hint}'),
  'spelling.right':
      AppTextDefault('Spelling', '“{word}” is complete.', '“{word}” a kim ta.'),
  'spelling.wrong': AppTextDefault(
      'Spelling',
      'The answer is “{answer}”: “{word}”.',
      'Chhanna dik chu “{answer}” a ni: “{word}”.'),
  // Tawng Upa
  'tawngUpa.blank': AppTextDefault('Tawng Upa', 'Which word fills the blank?',
      'A ruak-ah eng thumal nge a lut ang?'),
  'tawngUpa.wrong': AppTextDefault(
      'Tawng Upa',
      'The answer is “{answer}”.\n{explanation}',
      'Chhanna dik chu “{answer}” a ni.\n{explanation}'),
  // Word Chain
  'chain.hintNone': AppTextDefault(
      'Word Chain', 'Think of another word.', 'Thumal dang ngaihtuah rawh.'),
  'chain.hint': AppTextDefault(
      'Word Chain', 'You could use “{word}”.', '“{word}” i hmang thei.'),
  'chain.word': AppTextDefault('Word Chain', '“{word}”', '“{word}”'),
  'chain.wordMeaning': AppTextDefault(
      'Word Chain', '“{word}” ({meaning})', '“{word}” ({meaning})'),
  'chain.unknown': AppTextDefault(
      'Word Chain',
      'We don\'t have this word yet. Try another one.',
      'He thumal hi kan thumal dahkhâwmnaah a la awm lo. Thumal dang ziak rawh.'),
  'chain.deadEnd': AppTextDefault(
      'Word Chain',
      '“{word}” is right, but we have no word starting with “{unit}” yet. Try another one.',
      '“{word}” a dik, mahse “{unit}” hmanga bulṭan thumal kan la nei lo. Thumal dang ziak rawh.'),
  'chain.used': AppTextDefault('Word Chain', 'You already used this word.',
      'He thumal hi i hmang tawh.'),
  'chain.wrongStart': AppTextDefault(
      'Word Chain',
      '“{word}” starts with “{start}”; it needs to start with “{needed}”.',
      '“{word}” chu “{start}” hmangin a inṭan; “{needed}” hmanga bulṭan tûr a ni.'),
  'chain.linked': AppTextDefault(
      'Word Chain',
      '{word}\nNow link a word starting with “{unit}”.',
      '{word}\n“{unit}” hmanga zawm leh rawh.'),
  'chain.howToPlay': AppTextDefault('Word Chain', 'HOW TO PLAY', 'KHELH DAN'),
  'chain.rule': AppTextDefault(
      'Word Chain',
      'Start each word with the last letter of the one before.',
      'Thumal tawpna hawrawp hmangin thumal dang bulṭan rawh.'),
  'chain.example': AppTextDefault('Word Chain',
      'Example: In → Nula → Aizawl → Lal', 'Entîrna: In → Nula → Aizawl → Lal'),
  'chain.title': AppTextDefault('Word Chain', 'Our chain', 'Kan thumal zawm'),
  'chain.start':
      AppTextDefault('Word Chain', 'Start: {word}', 'Inṭanna: {word}'),
  'chain.needed': AppTextDefault(
      'Word Chain', 'Start with “{unit}”', '“{unit}” hmanga bulṭan rawh'),
  'chain.input': AppTextDefault(
      'Word Chain', 'Type a Mizo word…', 'Mizo thumal ziak rawh…'),
  'chain.tip': AppTextDefault(
      'Word Chain',
      'TIP  •  We know {n} words starting with “{unit}”.',
      'KAWHHMUHNA  •  “{unit}” hmanga bulṭan thumal {n} kan nei.'),
  // Word Search
  'search.start': AppTextDefault('Word Search', 'Tap the letters in order.',
      'Hawrawp te indawtin hmet rawh.'),
  'search.allFound': AppTextDefault(
      'Word Search', 'You found every word.', 'Thumal zawng zawng i hmu tawh.'),
  'search.adjacent': AppTextDefault(
      'Word Search',
      'Pick letters next to each other.',
      'Hawrawp bul hnai indawtin thlang rawh.'),
  'search.found': AppTextDefault(
      'Word Search', 'You found “{word}”!', '“{word}” i hmu ta!'),
  'search.foundGloss': AppTextDefault('Word Search',
      'You found “{word}”! ({gloss})', '“{word}” i hmu ta! ({gloss})'),
  'search.noMatch': AppTextDefault('Word Search',
      'That\'s not one. Start again.', 'A rem lo. Bulṭan nawn leh rawh.'),
  'search.cellSpoken': AppTextDefault(
      'Word Search',
      'Row {row}, column {column}, letter {letter}',
      'Tlar {row}, ban {column}, hawrawp {letter}'),
  // Crossword
  'crossword.yourAnswer':
      AppTextDefault('Crossword', 'Your answer', 'I chhanna'),
  'crossword.words':
      AppTextDefault('Crossword', '{words} words', 'Thumal {words}'),
  'crossword.nearly': AppTextDefault(
      'Crossword',
      '{subject} is very close! The red letter needs â, ê, î, ô, û or ṭ.',
      '{subject} a hnaih hle! Hawrawp sen chu â, ê, î, ô, û emaw ṭ emaw a ni ang.'),
  'crossword.wrong': AppTextDefault(
      'Crossword',
      '{subject} isn\'t right. Change the red letters and try again.',
      '{subject} a dik lo. Hawrawp sen te thlak la, tum leh rawh.'),
  'crossword.across': AppTextDefault('Crossword', 'Across →', 'Vang →'),
  'crossword.down': AppTextDefault('Crossword', 'Down ↓', 'Dung ↓'),
  'crossword.previous':
      AppTextDefault('Crossword', 'Previous clue', 'Kawhhmuhna hmasa'),
  'crossword.next': AppTextDefault('Crossword', 'Next clue', 'Kawhhmuhna dawt'),
  'crossword.clueAcross': AppTextDefault('Crossword',
      '{n} ACROSS →  •  {letters} LETTERS', '{n} VANG →  •  HAWRAWP {letters}'),
  'crossword.clueDown': AppTextDefault('Crossword',
      '{n} DOWN ↓  •  {letters} LETTERS', '{n} DUNG ↓  •  HAWRAWP {letters}'),
  'crossword.cellEmptySpoken': AppTextDefault('Crossword',
      'Row {row}, column {column}, empty', 'Tlar {row}, ban {column}, a ruak'),
  'crossword.cellSpoken': AppTextDefault(
      'Crossword',
      'Row {row}, column {column}, letter {letter}',
      'Tlar {row}, ban {column}, hawrawp {letter}'),
  'crossword.erase': AppTextDefault('Crossword', 'Erase', 'Thai bo'),
  // Sentence Builder
  'sentence.title': AppTextDefault(
      'Sentence Builder', 'Sentence Builder', 'Sentence Builder'),
  'sentence.empty': AppTextDefault('Sentence Builder',
      'Sentence content is not available.', 'Sentence a la awm lo.'),
  'sentence.usingWord': AppTextDefault('Sentence Builder',
      'SENTENCE USING THIS WORD', 'HE THUMAL HMANGA SENTENCE'),
  'sentence.yours':
      AppTextDefault('Sentence Builder', 'YOUR SENTENCE', 'I SENTENCE'),
  'sentence.right': AppTextDefault('Sentence Builder',
      '{sentence} — Well built!', '{sentence} — A rem dik e.'),
  'sentence.wrong': AppTextDefault(
      'Sentence Builder',
      'The order isn\'t right yet. Look at “{sentence}” and try again.',
      'A indawt a la dik lo. “{sentence}” tih hi en la, tum leh rawh.'),
  'sentence.check':
      AppTextDefault('Sentence Builder', 'Check Sentence', 'En rawh'),
  'sentence.finish': AppTextDefault('Sentence Builder', 'Finish', 'Zo ta'),
  'sentence.next':
      AppTextDefault('Sentence Builder', 'Next Sentence', 'Sentence dawt'),
  'sentence.retry':
      AppTextDefault('Sentence Builder', 'Try Again', 'Tum leh rawh'),
  // Thumal Kawp
  'kawp.progress': AppTextDefault(
      'Thumal Kawp',
      '{found}/{pairs} pairs found • {turns} turns',
      'Kawp {found}/{pairs} i hmu tawh • Vawi {turns} i let tawh'),
  'kawp.notEnough': AppTextDefault(
      'Thumal Kawp',
      'Not enough words for the cards yet. Try again when new content arrives.',
      'Card kawp tûr thumal a tâwk lo. Content thar a lo thlen hunah tum leh rawh.'),
  'kawp.hiddenSpoken':
      AppTextDefault('Thumal Kawp', 'Hidden card', 'Card khuh'),
  'kawp.pictureSpoken':
      AppTextDefault('Thumal Kawp', 'Picture of {gloss}', '{gloss} milem'),
  'kawp.matchedSpoken':
      AppTextDefault('Thumal Kawp', '{card}, matched', '{card}, a inkawp ta'),
  // Level check
  'placement.empty': AppTextDefault(
      'Level check', 'No words to learn yet.', 'Zirna tur thumal a la awm lo.'),
  'placement.prompt': AppTextDefault('Level check', 'Pick the closest meaning',
      'A awmzia hnai ber thlang rawh'),
  'placement.seeLevel':
      AppTextDefault('Level check', 'See your level', 'I level en rawh'),
  'placement.skip': AppTextDefault(
      'Level check', 'Start from Level 1', 'Level 1 aṭangin ṭan nghal rawh'),
  'placement.result':
      AppTextDefault('Level check', 'Your starting level', 'I ṭanna level'),
  'placement.title': AppTextDefault('Level check', 'Level check', 'Level enna'),
  'placement.question': AppTextDefault(
      'Level check', 'Question {n}/{total}', 'Zawhna {n}/{total}'),
  'placement.score': AppTextDefault(
      'Level check',
      '{correct} of {total} right • {description}',
      '{total} zingah {correct} i chhang dik • {description}'),
  // Daily lesson
  'lesson.prompt': AppTextDefault(
      'Daily lesson', 'Pick the meaning', 'A awmzia thlang rawh'),
  'lesson.finish':
      AppTextDefault('Daily lesson', 'Finish lesson', 'Zirna tihfel rawh'),
  'lesson.caughtUp': AppTextDefault(
      'Daily lesson', 'You\'re all caught up!', 'I zo vek tawh e!'),
  'lesson.caughtUpNote': AppTextDefault(
      'Daily lesson',
      'No words to review right now.',
      'Tunah hian en leh tur thumal a awm lo.'),
  'lesson.back': AppTextDefault('Daily lesson', 'Go back', 'Kir leh rawh'),
  'lesson.completeTitle':
      AppTextDefault('Daily lesson', 'Lesson complete', 'Zirna zo'),
  'lesson.complete': AppTextDefault(
      'Daily lesson', 'You finished today\'s lesson!', 'Vawiin zirna i zo ta!'),
  'lesson.newWord': AppTextDefault('Daily lesson', 'NEW WORD', 'THUMAL THAR'),
  'lesson.title':
      AppTextDefault('Daily lesson', 'Today\'s lesson', 'Vawiin zirna'),
  'lesson.score': AppTextDefault(
      'Daily lesson',
      '{correct} of {total} right • We\'ll bring these words back at the right time.',
      '{total} zingah {correct} i chhang dik • Heng thumalte hi a hun takah kan rawn tilang leh ang.'),
  'lesson.right': AppTextDefault(
      'Daily lesson', 'Correct! “{example}”', 'A dik e! “{example}”'),
  'lesson.wrong': AppTextDefault(
      'Daily lesson',
      'The answer is “{answer}”. {example}',
      'A dik chu “{answer}” a ni. {example}'),
  // Levels
  'level.code': AppTextDefault('Levels', 'Level {n}', 'Level {n}'),
  'level.1.title': AppTextDefault('Levels', 'First Steps', 'Ke pen hmasa'),
  'level.1.description': AppTextDefault(
      'Levels',
      'Start with basic words and pictures',
      'Thumal bul leh milem hmanga bulṭanna'),
  'level.2.title': AppTextDefault('Levels', 'Everyday Words', 'Ni tin thumal'),
  'level.2.description': AppTextDefault(
      'Levels',
      'Everyday words and short sentences',
      'Ni tin thumal leh sentence tawi zirna'),
  'level.3.title':
      AppTextDefault('Levels', 'Growing Speaker', 'Sawi thiam chho'),
  'level.3.description': AppTextDefault(
      'Levels',
      'Conversation, spelling and reading',
      'Inbiakna, hawrawp ziah dan leh chhiarna'),
  'level.4.title': AppTextDefault('Levels', 'Confident Reader', 'Chhiar thiam'),
  'level.4.description': AppTextDefault('Levels',
      'Longer sentences and meaning', 'Sentence sei leh thu awmzia hriatna'),
  'level.5.title':
      AppTextDefault('Levels', 'Storyteller', 'Thawnthu sawi thiam'),
  'level.5.description': AppTextDefault(
      'Levels', 'Stories and accounts', 'Thawnthu leh chanchin zirna'),
  'level.6.title': AppTextDefault('Levels', 'Explorer', 'Kawngzawh thiam'),
  'level.6.description': AppTextDefault(
      'Levels', 'Places and way of life', 'Ram hmuhna leh nunphung zirna'),
  'level.7.title':
      AppTextDefault('Levels', 'Culture Apprentice', 'Hnam nun zir'),
  'level.7.description': AppTextDefault(
      'Levels', 'Old sayings and grammar', 'Tawng upa leh ṭawng dan zirna'),
  'level.8.title':
      AppTextDefault('Levels', 'Culture & Fluency', 'Hnam nun leh ṭawng thiam'),
  'level.8.description': AppTextDefault(
      'Levels',
      'Old sayings, heritage and full fluency',
      'Tawng upa, hnam ziarang leh ṭawng thiamna famkim'),
  'mastery.unseen': AppTextDefault('Levels', 'New', 'Thar'),
  'mastery.learning': AppTextDefault('Levels', 'Learning', 'Zir mêk'),
  'mastery.familiar': AppTextDefault('Levels', 'Familiar', 'Hriat chin'),
  'mastery.strong': AppTextDefault('Levels', 'Strong', 'Hriat ṭha'),
  'mastery.mastered': AppTextDefault('Levels', 'Mastered', 'Thiam tawh'),
  // Onboarding
  'age.early': AppTextDefault('Onboarding', 'Ages 5–7', 'Kum 5–7'),
  'age.young': AppTextDefault('Onboarding', 'Ages 8–13', 'Kum 8–13'),
  'age.teen': AppTextDefault('Onboarding', 'Ages 14–17', 'Kum 14–17'),
  'age.adult': AppTextDefault('Onboarding', 'Adult', 'Puitling'),
  'age.early.note': AppTextDefault('Onboarding',
      'Start with pictures and games', 'Milem leh game hmanga bulṭanna'),
  'age.young.note': AppTextDefault(
      'Onboarding',
      'Learn with words, spelling and stories',
      'Thumal, hawrawp ziah dan leh thawnthu hmanga zir'),
  'age.teen.note': AppTextDefault('Onboarding',
      'Reading, conversation and culture', 'Chhiarna, inbiakna leh hnam nun'),
  'age.adult.note': AppTextDefault('Onboarding', 'Learn Mizo at your own pace',
      'Mahni chak zawngin Mizo ṭawng zir leh'),
  'proficiency.new': AppTextDefault(
      'Onboarding', 'I\'m new to Mizo', 'Mizo ṭawng ka thiam lo'),
  'proficiency.some':
      AppTextDefault('Onboarding', 'I understand some', 'Ka hrethiam deuh'),
  'proficiency.speaks': AppTextDefault(
      'Onboarding', 'I can speak Mizo', 'Mizo ṭawng ka sawi thiam'),
  'proficiency.reads': AppTextDefault(
      'Onboarding', 'I can read and write', 'Ka chhiar leh ziak thiam'),
  'proficiency.new.note': AppTextDefault(
      'Onboarding',
      'Guide me from the very first words',
      'Thumal bul aṭangin min kaihhruai rawh'),
  'proficiency.some.note': AppTextDefault(
      'Onboarding',
      'I know a little and want to speak and read',
      'Ka hria deuh, sawi leh chhiar ka zir duh'),
  'proficiency.speaks.note': AppTextDefault(
      'Onboarding',
      'I want better spelling and reading',
      'Hawrawp ziah dan leh chhiarna ka tihpun duh'),
  'proficiency.reads.note': AppTextDefault(
      'Onboarding',
      'I want old sayings and harder skills',
      'Tawng upa leh thiamna sang zâwk ka duh'),
  'goal.conversation':
      AppTextDefault('Onboarding', 'Home Conversation', 'Inbiakna'),
  'goal.vocabulary':
      AppTextDefault('Onboarding', 'Words & Spelling', 'Thumal leh ziah dan'),
  'goal.reading': AppTextDefault('Onboarding', 'Reading', 'Chhiarna'),
  'goal.culture': AppTextDefault('Onboarding', 'Culture', 'Hnam nun'),
  'goal.refresh':
      AppTextDefault('Onboarding', 'Refresh My Mizo', 'Ka Mizo ṭawng tihthar'),
  'support.english':
      AppTextDefault('Onboarding', 'English support', 'English ṭanpuina'),
  'support.mizoOnly': AppTextDefault('Onboarding', 'Mizo only', 'Mizo chauh'),
  'profile.badge.early': AppTextDefault('Onboarding', 'Sprout', 'Thlai tiak'),
  'profile.badge.young': AppTextDefault('Onboarding', 'Explorer', 'Kawngzawh'),
  'onboarding.brand': AppTextDefault('Onboarding', 'HNAHSIN', 'HNAHSIN'),
  'onboarding.stepSpoken': AppTextDefault(
      'Onboarding', 'Step {n} of {total}', 'Kal dan {total} zingah {n}-na'),
  'onboarding.goalLimit': AppTextDefault('Onboarding',
      'Choose up to two learning goals.', 'I tum pahnih thleng i thlang thei.'),
  'onboarding.start':
      AppTextDefault('Onboarding', 'Start My Journey', 'Ka kawngzawh ṭan rawh'),
  'onboarding.finish': AppTextDefault(
      'Onboarding', 'Build My Learning Path', 'Ka zirna kawng siam rawh'),
  'welcome.eyebrow': AppTextDefault(
      'Onboarding', 'Word games from Mizoram', 'Mizo ṭawng hlim taka zirna'),
  'welcome.title': AppTextDefault('Onboarding', 'Play games. Pick up Mizo.',
      'I Mizo ṭawng kawngzawh hetah a ṭan.'),
  'welcome.path': AppTextDefault(
      'Onboarding', 'A path built for you', 'Nangma tana kawng siam'),
  'welcome.pathNote': AppTextDefault('Onboarding',
      'Games that match what you know.', 'I thiamna leh i tum dân ang zêlin.'),
  'welcome.offline':
      AppTextDefault('Onboarding', 'Learn anywhere', 'Khawiah pawh zir rawh'),
  'welcome.offlineNote': AppTextDefault(
      'Onboarding',
      'Core games work offline on your device.',
      'Game te hi internet nei lovin i phone-ah a khelh theih.'),
  'welcome.safe':
      AppTextDefault('Onboarding', 'Safe for families', 'Chhungkaw tan a him'),
  'welcome.safeNote': AppTextDefault(
      'Onboarding',
      'No public chat, ads, or child leaderboard.',
      'Mi dang nen inbiakna, advertisement, naupang inelna list a awm lo.'),
  'age.eyebrow': AppTextDefault(
      'Onboarding', 'Personalize your path', 'I kawng siam rawh'),
  'age.title':
      AppTextDefault('Onboarding', 'Who is learning?', 'Tu nge zir dawn?'),
  'age.subtitle': AppTextDefault(
      'Onboarding',
      'We only need an age range — no birthday or name.',
      'Kum chauh kan mamawh — pian ni emaw hming emaw kan dil lo.'),
  'proficiency.eyebrow': AppTextDefault(
      'Onboarding', 'Find your starting point', 'I ṭanna zawng rawh'),
  'proficiency.title': AppTextDefault(
      'Onboarding', 'How much Mizo do you know?', 'Mizo ṭawng i thiam em?'),
  'proficiency.subtitle': AppTextDefault(
      'Onboarding',
      'Pick honestly — you can change it any time in Profile.',
      'A dik tak thlang rawh — eng hunah pawh Keimah-ah i thlâk thei.'),
  'goal.eyebrow': AppTextDefault(
      'Onboarding', 'Choose up to two', 'Pahnih thleng thlang rawh'),
  'goal.title': AppTextDefault(
      'Onboarding', 'What would you like to learn?', 'Eng nge i zir duh?'),
  'goal.subtitle': AppTextDefault(
      'Onboarding',
      'Pick what matters most and we\'ll put it first in your daily quests.',
      'I zir duh ber thlang la, ni tin hnaah kan dah hmasa ang.'),
  'rhythm.eyebrow': AppTextDefault('Onboarding', 'Ready for your first quest',
      'I hna hmasa ber atan i inpeih'),
  'rhythm.title': AppTextDefault(
      'Onboarding', 'Set your daily rhythm.', 'Ni tin i zir zat thlang rawh.'),
  'rhythm.subtitle': AppTextDefault(
      'Onboarding',
      'A little every day is the best way to learn.',
      'Tlem tê tê, ni tin zir hi zirna kawng ṭha ber a ni.'),
  'welcome.subtitle': AppTextDefault(
      'Onboarding',
      'Fun word games. You\'ll learn Mizo words as you play.',
      'Khelh pahin thumal, hawrawp ziah dan, chhiarna leh Mizo nunphung zir rawh.'),
  'rhythm.goal': AppTextDefault('Onboarding', 'DAILY GOAL', 'NI TIN TUM'),
  'rhythm.minutes': AppTextDefault('Onboarding', '{n} min', 'Minute {n}'),
  'rhythm.privacy': AppTextDefault(
      'Onboarding',
      'Guest-first • Progress stays on this device',
      'Account a ngai lo • I hmasawnna i phone-ah a awm'),
  // Profile • learning level
  'track.beginner':
      AppTextDefault('Profile • learning level', 'Beginner', 'Bulṭan'),
  'track.explorer':
      AppTextDefault('Profile • learning level', 'Explorer', 'Zirchho'),
  'track.master':
      AppTextDefault('Profile • learning level', 'Master', 'Thiamna'),
  'track.beginner.note': AppTextDefault(
      'Profile • learning level',
      'Start with pictures and easy words',
      'Milem leh thumal awlsam hmanga bulṭan'),
  'track.explorer.note': AppTextDefault(
      'Profile • learning level',
      'Keep going with spelling and puzzles',
      'Hawrawp ziah dan leh puzzle hmanga zir chhunzawm'),
  'track.master.note': AppTextDefault('Profile • learning level',
      'Old sayings and proverbs', 'Tawng upa leh thufing zirna'),
  // Word categories
  'category.chhungkua':
      AppTextDefault('Word categories', 'Family', 'Chhungkua'),
  'category.sikul': AppTextDefault('Word categories', 'School', 'Sikul'),
  'category.nungcha': AppTextDefault('Word categories', 'Animals', 'Nungcha'),
  'category.khawvel': AppTextDefault('Word categories', 'World', 'Khawvel'),
  'category.nunphung':
      AppTextDefault('Word categories', 'Way of life', 'Nunphung'),
  'category.thiltih': AppTextDefault('Word categories', 'Actions', 'Thiltih'),
  // Journey
  'journey.title': AppTextDefault('Journey', 'Mizo Journey', 'Mizo Kawngzawh'),
  'journey.subtitle': AppTextDefault('Journey', 'Story, conversation & culture',
      'Thawnthu, inbiakna leh hnam nun'),
  'journey.todaysQuests':
      AppTextDefault('Journey', 'Today\'s Quests', 'Vawiin hna'),
  'journey.map': AppTextDefault('Journey', 'Journey Map', 'Kawngzawh Map'),
  'journey.cultureTrail':
      AppTextDefault('Journey', 'Culture Trail', 'Hnam Nun Kawng'),
  'journey.cultureTrailNote': AppTextDefault('Journey',
      'Words, values & living culture', 'Thumal, ngaihhlutna leh hnam nun'),
  'journey.cultureCount': AppTextDefault(
      'Journey',
      '{collected}/{total} cards • Tawng Upa context',
      'Card {collected}/{total} • Tawng upa chanchin'),
  'journey.eyebrow':
      AppTextDefault('Journey', 'YOUR MIZO JOURNEY', 'I MIZO KAWNGZAWH'),
  'journey.progress': AppTextDefault(
      'Journey',
      '{done} of {total} story stops complete',
      'Thawnthu {total} zingah {done} i zo'),
  'journey.rhythm':
      AppTextDefault('Journey', 'Learning rhythm', 'Zirna kalphung'),
  'journey.rhythmDays':
      AppTextDefault('Journey', '{n} day rhythm', 'Ni {n} indawt'),
  'journey.graceReady':
      AppTextDefault('Journey', 'Grace ready', 'Ni khat chawl theih'),
  'journey.graceUsed':
      AppTextDefault('Journey', 'Grace used', 'Ni chawl i hmang tawh'),
  'journey.thisWeek':
      AppTextDefault('Journey', '{n}/3 this week', 'Kar khatah {n}/3'),
  'journey.trailMarks':
      AppTextDefault('Journey', '{n} Trail Marks', 'Chhinchhiahna {n}'),
  'journey.welcomeBack':
      AppTextDefault('Journey', 'Welcome back', 'Lo kir leh rawh, i lawm e'),
  'journey.welcomeBackNote': AppTextDefault(
      'Journey',
      'Your progress is safe. Pick the story back up in just a few minutes.',
      'I kalna hmasa a bo lo. Minute tlem chauh hmangin thawnthu chhunzawm rawh.'),
  'journey.dailyGentle': AppTextDefault('Journey',
      'OPTIONAL DAILY • NO PENALTY', 'NI TIN • DUH THLAN • HREMNA AWM LO'),
  'journey.daily': AppTextDefault('Journey', 'DAILY', 'NI TIN'),
  'journey.weeklyGentle': AppTextDefault(
      'Journey',
      'OPTIONAL WEEKLY • NO DEADLINE',
      'KAR TIN • DUH THLAN • HUN BITUK AWM LO'),
  'journey.weekly': AppTextDefault(
      'Journey', 'WEEKLY • NO COUNTDOWN', 'KAR TIN • HUN CHHIAR AWM LO'),
  'journey.claim': AppTextDefault('Journey', 'Claim +{n}', 'La rawh +{n}'),
  'journey.preview': AppTextDefault(
      'Journey',
      'Preview content — awaiting Mizo language review.',
      'Content en chhinna — Mizo ṭawng thiam mi pawmna a la nghah mêk.'),
  'journey.nodeSpoken':
      AppTextDefault('Journey', '{title}, {status}', '{title}, {status}'),
  'journey.nodeLevel': AppTextDefault('Journey', 'Level {n}', 'Level {n}'),
  'journey.replay': AppTextDefault('Journey', 'REPLAY', 'CHHIAR LEH'),
  'journey.start': AppTextDefault('Journey', 'START', 'ṬAN RAWH'),
  'journey.collection':
      AppTextDefault('Journey', 'My Collection', 'Ka Dahkhawm'),
  'journey.viewAll': AppTextDefault('Journey', 'View All', 'A vaiin en rawh'),
  'journey.firstReward': AppTextDefault(
      'Journey',
      'You\'ll earn a reward when you finish your first Story Quest.',
      'Thawnthu hmasa ber i zawh hunah lawmman i hmu ang.'),
  'story.title': AppTextDefault('Journey', 'Story Quest', 'Thawnthu'),
  'story.chooseReply': AppTextDefault(
      'Journey', 'Choose a natural reply', 'Chhanna remchang thlang rawh'),
  'story.complete':
      AppTextDefault('Journey', 'Complete Story', 'Thawnthu zo rawh'),
  'story.completeTitle':
      AppTextDefault('Journey', 'Story Complete', 'Thawnthu i zo ta'),
  'story.wellDone': AppTextDefault('Journey', 'Well done!', 'I ti ṭha e!'),
  'story.reward': AppTextDefault('Journey', 'Story reward', 'Thawnthu lawmman'),
  'story.cultureMoment':
      AppTextDefault('Journey', 'CULTURE MOMENT', 'HNAM NUN'),
  'story.saved': AppTextDefault('Journey', 'Saved', 'Dah ṭha'),
  'story.read': AppTextDefault('Journey', 'I read this', 'Ka chhiar tawh'),
  'story.stop':
      AppTextDefault('Journey', 'A good stopping point', 'Chawl hun ṭha'),
  'story.stopNote': AppTextDefault(
      'Journey',
      'That\'s enough for today. Come back tomorrow and keep going.',
      'Vawiin tâna i zirna a tâwk tawh. Naktûkah hlim takin i chhunzawm leh thei e.'),
  'story.finish':
      AppTextDefault('Journey', 'Finish for Now', 'Tunah chawl rawh'),
  'story.stepSpoken': AppTextDefault(
      'Journey', 'Story step {n} of {total}', 'Thawnthu {total} zingah {n}-na'),
  'story.conversation': AppTextDefault('Journey', 'Conversation {n} of {total}',
      'Inbiakna {total} zingah {n}-na'),
  // Culture
  'culture.title': AppTextDefault('Culture', 'Culture Trail', 'Hnam Nun Kawng'),
  'culture.collected': AppTextDefault('Culture', '{n}/{total} cards collected',
      'Card {n}/{total} i khawl tawh'),
  'culture.eyebrow':
      AppTextDefault('Culture', 'MIZO CULTURE TRAIL', 'MIZO HNAM NUN KAWNG'),
  'culture.intro': AppTextDefault(
      'Culture',
      'Learn words, culture and how they are used.',
      'Thumal, hnam nun leh a hman dân zir rawh.'),
  'culture.marks': AppTextDefault(
      'Culture',
      '{n} Trail Marks • Lessons stay open',
      'Chhinchhiahna {n} • Zirna a hawng reng'),
  'culture.cards': AppTextDefault('Culture', 'Culture Cards', 'Hnam Nun Card'),
  'culture.preview': AppTextDefault(
      'Culture',
      'Preview content — awaiting language and culture review.',
      'Content en chhinna — ṭawng leh hnam nun thiam mi pawmna a la nghah mêk.'),
  'culture.noDeadline':
      AppTextDefault('Culture', 'NO DEADLINE', 'HUN BITUK AWM LO'),
  'culture.unlockAt': AppTextDefault(
      'Culture', 'Unlock at Level {n}', 'Level {n}-ah a hawng ang'),
  'culture.keepLearning': AppTextDefault('Culture',
      'Keep learning to reach this level.', 'Zirna level chhunzawm rawh.'),
  'culture.cardTitle':
      AppTextDefault('Culture', 'Culture Card', 'Hnam Nun Card'),
  'culture.usage': AppTextDefault(
      'Culture', 'How it is used and what it means', 'A hman dân leh a nihna'),
  'culture.example': AppTextDefault('Culture', 'Example', 'Entîrna'),
  'culture.readToday':
      AppTextDefault('Culture', 'Read Today', 'Vawiin chhiar rawh'),
  'culture.readAgain':
      AppTextDefault('Culture', 'Read Again', 'Chhiar leh rawh'),
  'culture.add':
      AppTextDefault('Culture', 'Add to Collection', 'Ka dahkhawmah dah rawh'),
  'culture.report': AppTextDefault(
      'Culture', 'Report a Content Issue', 'Content dik lo hriattir rawh'),
  'collection.title': AppTextDefault('Culture', 'My Collection', 'Ka Dahkhawm'),
  'collection.count': AppTextDefault(
      'Culture', '{n}/{total} culture cards', 'Hnam nun card {n}/{total}'),
  'collection.marks':
      AppTextDefault('Culture', '{n} Trail Marks', 'Chhinchhiahna {n}'),
  'collection.note': AppTextDefault(
      'Culture',
      'Recognition only • No lesson is locked',
      'Lawmna chauh a ni • Zirna pakhatmah a khar lo'),
  'collection.style':
      AppTextDefault('Culture', 'Choose My Style', 'Ka hmel thlang rawh'),
  'collection.milestones':
      AppTextDefault('Culture', 'Milestones', 'Hmasawnna chhinchhiahna'),
  'collection.firstCard': AppTextDefault(
      'Culture',
      'Read your first card on the Culture Trail.',
      'Hnam Nun Kawng-ah card pakhat chhiar hmasa rawh.'),
  'collection.rewards':
      AppTextDefault('Culture', 'Story Rewards', 'Thawnthu lawmman'),
  'collection.firstReward': AppTextDefault(
      'Culture',
      'You\'ll earn a reward when you finish your first Story Quest.',
      'Thawnthu hmasa ber i zawh hunah lawmman i hmu ang.'),
  'collection.avatarLocked': AppTextDefault('Culture',
      '{avatar} • {marks} marks', '{avatar} • Chhinchhiahna {marks}'),
  // Journey quests
  'quest.story':
      AppTextDefault('Journey quests', 'Story Step', 'Thawnthu pen khat'),
  'quest.story.note': AppTextDefault(
      'Journey quests', 'Finish one Story Quest.', 'Thawnthu pakhat zo rawh.'),
  'quest.words':
      AppTextDefault('Journey quests', 'Word Keeper', 'Thumal vengtu'),
  'quest.words.note': AppTextDefault(
      'Journey quests', 'Review three words.', 'Thumal pathum en leh rawh.'),
  'quest.culture':
      AppTextDefault('Journey quests', 'Culture Moment', 'Hnam nun hun'),
  'quest.culture.note': AppTextDefault('Journey quests',
      'Read one culture note.', 'Hnam nun thu pakhat chhiar rawh.'),
  'quest.storyWeek':
      AppTextDefault('Journey quests', 'Story Week', 'Thawnthu kar'),
  'quest.storyWeek.note': AppTextDefault(
      'Journey quests',
      'Finish three Story Quests this week.',
      'Kar khat chhûngin thawnthu pathum zo rawh.'),
  'quest.cultureWeek':
      AppTextDefault('Journey quests', 'Culture Trail Week', 'Hnam nun kar'),
  'quest.cultureWeek.note': AppTextDefault(
      'Journey quests',
      'Read three Culture Cards this week.',
      'Kar khat chhûngin hnam nun card pathum chhiar rawh.'),
};
