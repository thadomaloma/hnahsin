/**
 * Hnahsin menu for the content Google Sheet: check the rows, publish the
 * content pack to GitHub Pages (where the app downloads it), and set the
 * sheet up. Pack.js does the checking and building.
 *
 * Script properties (Hnahsin → GitHub settings): GITHUB_REPO (owner/name),
 * GITHUB_TOKEN (a fine-grained token with Contents read/write on that repo
 * only), GITHUB_BRANCH (default main).
 */

var PICTURE_FOLDER = 'Hnahsin thlalak';
var PACK_PATH = 'api/v1/content_packs/latest';

function onOpen() {
  SpreadsheetApp.getUi().createMenu('Hnahsin')
    .addItem('✅ Check for problems', 'checkRows')
    .addItem('🚀 Publish to the app', 'publishPack')
    .addSeparator()
    .addSubMenu(SpreadsheetApp.getUi().createMenu('⚙️ Developer')
      .addItem('Set up the sheet (format, dropdowns)', 'setUpSheet')
      .addItem('GitHub settings', 'askGitHubSettings'))
    .addToUi();
}

// --- Reading the sheet ------------------------------------------------------

function readTab(key) {
  var sheet = SpreadsheetApp.getActive().getSheetByName(TABS[key]);
  if (!sheet || sheet.getLastRow() < 2) return [];
  var values = sheet.getRange(1, 1, sheet.getLastRow(), sheet.getLastColumn()).getValues();
  var headings = values[0].map(function (heading) { return String(heading).trim(); });
  var columns = COLUMNS[key].map(function (column) { return [column[0], headings.indexOf(column[1])]; });
  return values.slice(1).map(function (cells, index) {
    var row = { row: index + 2 };
    columns.forEach(function (column) { row[column[0]] = column[1] < 0 ? '' : cells[column[1]]; });
    return row;
  });
}

function readTabs() {
  return {
    words: readTab('words'), questions: readTab('questions'), sentences: readTab('sentences'),
    gameText: readTab('gameText'), appText: readTab('appText'),
  };
}

function hex(bytes) {
  return bytes.map(function (b) { return ('0' + (b & 0xff).toString(16)).slice(-2); }).join('');
}

function sha256Hex(string) {
  return hex(Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, string, Utilities.Charset.UTF_8));
}

/** Pictures in the “Hnahsin thlalak” (pictures) folder by file name, read on demand. */
function pictureReader() {
  var folder = pictureFolder(false);
  var cache = {};
  return {
    lookup: function (name) {
      if (name in cache) return cache[name];
      cache[name] = null;
      if (!folder) return null;
      var files = folder.getFilesByName(name);
      if (!files.hasNext()) return null;
      var blob = files.next().getBlob();
      var bytes = blob.getBytes();
      cache[name] = {
        checksum: hex(Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, bytes)),
        content_type: blob.getContentType(),
        byte_size: bytes.length,
        blob: blob,
      };
      return cache[name];
    },
  };
}

function pictureFolder(create) {
  var props = PropertiesService.getDocumentProperties();
  var id = props.getProperty('PICTURE_FOLDER_ID');
  if (id) {
    try { return DriveApp.getFolderById(id); } catch (e) { /* deleted: look again */ }
  }
  var parent = DriveApp.getFileById(SpreadsheetApp.getActive().getId()).getParents();
  var home = parent.hasNext() ? parent.next() : DriveApp.getRootFolder();
  var found = home.getFoldersByName(PICTURE_FOLDER);
  var folder = found.hasNext() ? found.next() : (create ? home.createFolder(PICTURE_FOLDER) : null);
  if (folder) props.setProperty('PICTURE_FOLDER_ID', folder.getId());
  return folder;
}

function build(pictures) {
  var now = new Date();
  return buildPack(readTabs(), {
    sha256Hex: sha256Hex,
    picture: pictures.lookup,
    version: packVersion(now),
    id: Utilities.getUuid(),
    now: now.toISOString().replace(/\.\d{3}Z$/, 'Z'),
  });
}

// --- Menu actions -----------------------------------------------------------

/** What a publish holds, e.g. “1147 words, 5 questions, …”. */
function summary(counts) {
  return counts.words + ' words, ' + counts.questions + ' questions, ' + counts.sentences + ' sentences, ' +
    counts.gameText + ' game texts and ' + counts.appText + ' changed app texts';
}

function checkRows() {
  var result = build(pictureReader());
  if (result.problems.length) return showProblems(result.problems);
  SpreadsheetApp.getUi().alert('No problems ✅',
    summary(result.counts) + ' are ready.\n\nTo send them to the app, use “🚀 Publish to the app”.',
    SpreadsheetApp.getUi().ButtonSet.OK);
}

function publishPack() {
  var ui = SpreadsheetApp.getUi();
  var settings = gitHubSettings();
  if (!settings) {
    ui.alert('GitHub is not set up yet. A developer needs to fill in “⚙️ Developer → GitHub settings” first.');
    return;
  }
  var pictures = pictureReader();
  var result = build(pictures);
  if (result.problems.length) return showProblems(result.problems);

  var answer = ui.alert('Publish to the app?',
    summary(result.counts) + ' will go to the app.\n\nPublish now?',
    ui.ButtonSet.YES_NO);
  if (answer !== ui.Button.YES) return;

  writeNewIds(result.newIds);
  var uploaded = 0;
  var done = {};
  result.pictures.forEach(function (picture) {
    if (done[picture.checksum]) return;
    done[picture.checksum] = true;
    var path = 'api/v1/word_images/' + picture.checksum;
    if (gitHubSha(settings, path)) return; // a picture's path is its checksum, so it never changes
    gitHubPut(settings, path, Utilities.base64Encode(pictures.lookup(picture.name).blob.getBytes()), 'Picture ' + picture.name);
    uploaded += 1;
  });
  var json = JSON.stringify(result.envelope);
  var base64 = Utilities.base64Encode(json, Utilities.Charset.UTF_8);
  gitHubPut(settings, 'api/v1/content_packs/' + result.envelope.version + '.json', base64, 'Content pack ' + result.envelope.version);
  gitHubPut(settings, PACK_PATH, base64, 'Publish content pack ' + result.envelope.version);

  SpreadsheetApp.getActive().toast('GitHub is publishing it… (about 1 minute)', 'Hnahsin', 180);
  var live = waitUntilLive(settings, result.envelope.version);
  SpreadsheetApp.getActive().toast('', 'Hnahsin', 1);
  ui.alert(live ? 'It is in the app ✅' : 'Published 🎉',
    'Version ' + result.envelope.version + ' (' + uploaded + ' new pictures).\n\n' +
    (live
      ? 'Open apps get it within 1 minute, from their next game round.'
      : 'GitHub is still publishing it. It reaches the app in 2–3 minutes.'),
    ui.ButtonSet.OK);
}

/** The address the app downloads the pack from (GitHub Pages). */
function pagesPackUrl(settings) {
  var parts = settings.repo.split('/');
  return 'https://' + parts[0].toLowerCase() + '.github.io/' + parts[1] + '/' + PACK_PATH;
}

/**
 * Waits (up to about 3 minutes) until GitHub Pages serves [version], which
 * is when apps can download it. Pages clears its cache on each deploy.
 */
function waitUntilLive(settings, version) {
  var url = pagesPackUrl(settings);
  for (var i = 0; i < 18; i++) {
    Utilities.sleep(10000);
    try {
      var response = UrlFetchApp.fetch(url + '?check=' + Date.now(), { muteHttpExceptions: true });
      if (response.getResponseCode() === 200 && JSON.parse(response.getContentText()).version === version) return true;
    } catch (e) {
      // not there yet
    }
  }
  return false;
}

/** Writes the IDs Publish gave to new rows back into their ID cells. */
function writeNewIds(newIds) {
  newIds.forEach(function (entry) {
    var sheet = SpreadsheetApp.getActive().getSheetByName(entry.tab);
    var column = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0].indexOf('ID') + 1;
    if (column > 0) sheet.getRange(entry.row, column).setValue(entry.id);
  });
}

function showProblems(problems) {
  var ss = SpreadsheetApp.getActive();
  var items = problems.slice(0, 150).map(function (p) {
    var sheet = ss.getSheetByName(p.tab);
    var where = p.tab + (p.row ? ', row ' + p.row : '');
    var link = sheet && p.row ? ss.getUrl() + '#gid=' + sheet.getSheetId() + '&range=A' + p.row + ':Z' + p.row : null;
    return '<li><b>' + escapeHtml(where) + '</b>' + (link ? ' <a href="' + link + '" target="_blank">(open)</a>' : '') +
      '<br>' + escapeHtml(p.message) + '</li>';
  }).join('');
  var more = problems.length > 150 ? '<p>… and ' + (problems.length - 150) + ' more.</p>' : '';
  var html = HtmlService.createHtmlOutput(
    '<div style="font-family:sans-serif;font-size:14px;line-height:1.45">' +
    '<p>Found <b>' + problems.length + '</b> problems. Fix them, then use “✅ Check for problems” again. ' +
    'Nothing was sent to the app.</p><ol>' + items + '</ol>' + more + '</div>')
    .setWidth(560).setHeight(520);
  SpreadsheetApp.getUi().showModalDialog(html, 'Problems to fix');
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; });
}

// --- GitHub -----------------------------------------------------------------

function askGitHubSettings() {
  var ui = SpreadsheetApp.getUi();
  var props = PropertiesService.getScriptProperties();
  var repo = ui.prompt('GitHub repo', 'owner/name (e.g. thadomaloma/hnahsin-content):', ui.ButtonSet.OK_CANCEL);
  if (repo.getSelectedButton() !== ui.Button.OK) return;
  var token = ui.prompt('GitHub token', 'Fine-grained token with Contents: Read and write, for this repo only:', ui.ButtonSet.OK_CANCEL);
  if (token.getSelectedButton() !== ui.Button.OK) return;
  props.setProperties({
    GITHUB_REPO: repo.getResponseText().trim(),
    GITHUB_TOKEN: token.getResponseText().trim(),
    GITHUB_BRANCH: props.getProperty('GITHUB_BRANCH') || 'main',
  });
  ui.alert('Saved.');
}

function gitHubSettings() {
  var props = PropertiesService.getScriptProperties();
  var repo = props.getProperty('GITHUB_REPO');
  var token = props.getProperty('GITHUB_TOKEN');
  if (!repo || !token) return null;
  return { repo: repo, token: token, branch: props.getProperty('GITHUB_BRANCH') || 'main' };
}

function gitHubRequest(settings, method, path, payload) {
  var response = UrlFetchApp.fetch('https://api.github.com/repos/' + settings.repo + '/contents/' + path +
    (method === 'get' ? '?ref=' + encodeURIComponent(settings.branch) : ''), {
    method: method,
    contentType: 'application/json',
    payload: payload ? JSON.stringify(payload) : undefined,
    // The object media type returns a file's sha even above GitHub's 1 MB
    // limit for inline contents (a large pack).
    headers: { Authorization: 'Bearer ' + settings.token, Accept: method === 'get' ? 'application/vnd.github.object+json' : 'application/vnd.github+json' },
    muteHttpExceptions: true,
  });
  return response;
}

function gitHubSha(settings, path) {
  var response = gitHubRequest(settings, 'get', path);
  if (response.getResponseCode() === 404) return null;
  if (response.getResponseCode() !== 200) throw new Error('GitHub ' + response.getResponseCode() + ': ' + response.getContentText());
  return JSON.parse(response.getContentText()).sha;
}

function gitHubPut(settings, path, base64, message) {
  var payload = { message: message, content: base64, branch: settings.branch };
  var sha = gitHubSha(settings, path);
  if (sha) payload.sha = sha;
  var response = gitHubRequest(settings, 'put', path, payload);
  if (response.getResponseCode() !== 200 && response.getResponseCode() !== 201) {
    throw new Error('Could not save to GitHub (' + response.getResponseCode() + '). Please tell a developer.\n' + response.getContentText());
  }
}

// --- Setup ------------------------------------------------------------------

/** Headings, dropdowns, checkboxes and colours on every tab. Safe to run again. */
function setUpSheet() {
  var ss = SpreadsheetApp.getActive();
  var levels = SpreadsheetApp.newDataValidation().requireValueInList(['1', '2', '3', '4', '5', '6', '7'], true).build();
  var statuses = SpreadsheetApp.newDataValidation()
    .requireValueInList([STATUS.live, STATUS.review, STATUS.dropped], true).build();

  Object.keys(COLUMNS).forEach(function (key) {
    var sheet = ss.getSheetByName(TABS[key]) || ss.insertSheet(TABS[key]);
    var headings = COLUMNS[key].map(function (column) { return column[1]; });
    if (sheet.getLastRow() === 0) sheet.getRange(1, 1, 1, headings.length).setValues([headings]);
    var present = sheet.getRange(1, 1, 1, Math.max(sheet.getLastColumn(), 1)).getValues()[0].map(String);
    var rows = Math.max(sheet.getMaxRows() - 1, 1);
    function column(heading) { return present.indexOf(heading) + 1; }
    function whole(heading) { return column(heading) > 0 ? sheet.getRange(2, column(heading), rows, 1) : null; }

    sheet.setFrozenRows(1);
    sheet.setFrozenColumns(Math.min(2, present.length));
    sheet.getRange(1, 1, 1, present.length).setFontWeight('bold').setBackground('#1f4e5f').setFontColor('#ffffff').setWrap(true);
    if (whole('Level')) whole('Level').setDataValidation(levels);
    if (whole('Status')) whole('Status').setDataValidation(statuses);
    if (whole('ID')) {
      whole('ID').setBackground('#eeeeee').setFontColor('#777777');
      sheet.getProtections(SpreadsheetApp.ProtectionType.RANGE).forEach(function (old) {
        if (old.getDescription() === 'ID') old.remove();
      });
      whole('ID').protect().setDescription('ID').setWarningOnly(true);
    }
    ['Meaning (Mizo)', 'Example (Mizo)', 'Question (Mizo)', 'Explanation (Mizo)', 'Note', 'Sentence (Mizo)'].forEach(function (heading) {
      if (column(heading) > 0) sheet.setColumnWidth(column(heading), 280);
    });
    if (key === 'words') {
      sheet.setColumnWidth(column('English'), 200);
      whole('Category').setDataValidation(SpreadsheetApp.newDataValidation()
        .requireValueInList(CATEGORIES.map(function (c) { return c[1]; }), true).build());
      GAMES.forEach(function (game) {
        if (column(game[1]) > 0) {
          whole(game[1]).insertCheckboxes();
          sheet.setColumnWidth(column(game[1]), 90);
        }
      });
      var status = sheet.getRange(2, column('Status')).getA1Notation().replace(/\d+/, '');
      var rules = ['Word', 'Meaning (Mizo)', 'English', 'Example (Mizo)', 'Category', 'Level'].map(function (heading) {
        var cell = sheet.getRange(2, column(heading)).getA1Notation();
        return SpreadsheetApp.newConditionalFormatRule()
          .whenFormulaSatisfied('=AND($' + status + '2="' + STATUS.live + '",' + cell + '="")')
          .setBackground('#f8d7da').setRanges([whole(heading)]).build();
      });
      sheet.setConditionalFormatRules(rules);
    }
    if (key === 'questions') {
      whole('Right answer (1-4)').setDataValidation(SpreadsheetApp.newDataValidation()
        .requireValueInList(['1', '2', '3', '4'], true).build());
    }
    if (key === 'gameText') {
      whole('Game').setDataValidation(SpreadsheetApp.newDataValidation().requireValueInList(GAME_TEXT_IDS, true).build());
    }
    if (key === 'appText') {
      // Where it shows and the built-in text come from the app: read only.
      ['Where', 'Built-in text'].forEach(function (heading) {
        if (!whole(heading)) return;
        whole(heading).setBackground('#eeeeee').setFontColor('#555555');
        sheet.getProtections(SpreadsheetApp.ProtectionType.RANGE).forEach(function (old) {
          if (old.getDescription() === heading) old.remove();
        });
        whole(heading).protect().setDescription(heading).setWarningOnly(true);
      });
      ['Built-in text', 'Text'].forEach(function (heading) {
        if (column(heading) > 0) sheet.setColumnWidth(column(heading), 320);
      });
    }
  });

  pictureFolder(true);
  writeHelp(ss);
  SpreadsheetApp.getUi().alert('The sheet is set up. Pictures folder: “' + PICTURE_FOLDER + '”.');
}

function writeHelp(ss) {
  var sheet = ss.getSheetByName(TABS.help) || ss.insertSheet(TABS.help, 0);
  sheet.clear();
  var lines = [
    ['How to edit Hnahsin content'],
    [''],
    ['Adding a new word'],
    ['1. On the “Words” tab, write a new row at the bottom. Leave ID empty: it is filled in when you publish.'],
    ['2. Fill in Word, Meaning (Mizo), English and Example (Mizo) (an example sentence).'],
    ['3. Pick Category and Level (1 = easiest, 7 = hardest) from the dropdowns.'],
    ['4. Emoji: only for things you can see (🐕, 🌳). Leave it empty for things you cannot see (happiness, thoughts).'],
    ['5. Picture: put a PNG/JPEG in the “Hnahsin thlalak” (pictures) folder and write its file name here (e.g. word.lu.png). A picture is shown instead of the emoji.'],
    ['6. Games: tick the games the word should appear in. If you tick none, it appears in every game.'],
    ['7. Status: “Live” = shown in the app. “In review” = still being written, not shown. “Removed” = taken out of the app.'],
    [''],
    ['Sending changes to the app'],
    ['1. Use the menu “Hnahsin → ✅ Check for problems”. Any problems are listed with their row. Click “(open)” and fix them.'],
    ['2. When there are no problems, use “Hnahsin → 🚀 Publish to the app”.'],
    ['3. When it says “It is in the app ✅”, open apps get the changes within 1 minute, from their next game round. The app does not need an update.'],
    [''],
    ['If you make a mistake'],
    ['Go back to an earlier version with File → Version history → See version history, then publish again.'],
    [''],
    ['Pink cells'],
    ['A required cell is empty in a “Live” row. Please fill it in.'],
    [''],
    ['Questions tab: questions for the Tawng Upa game. Write 4 answers and pick the number (1–4) of the right one in “Right answer”.'],
    ['Sentences tab: sentences for Sentence Builder. A Mizo sentence and its English meaning.'],
    ['Game text tab: each game’s title and how to play. An empty cell keeps the app’s own text.'],
    ['App text tab: every label, button and message in the app. Change the “Text” column, then publish. “Built-in text” is the app’s own wording: if Text is empty or the same, that is shown.'],
    ['In App text, {n}, {word} and the like are filled in by the app with a number or a word. “Text” must have exactly the same ones as “Built-in text”.'],
  ];
  sheet.getRange(1, 1, lines.length, 1).setValues(lines).setWrap(true);
  sheet.setColumnWidth(1, 820);
  sheet.getRange(1, 1).setFontSize(16).setFontWeight('bold');
  [3, 12, 17, 20].forEach(function (row) { sheet.getRange(row, 1).setFontWeight('bold').setFontSize(12); });
}
