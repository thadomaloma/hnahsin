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
    .addItem('✅ Endik (dik lo awm em?)', 'checkRows')
    .addItem('🚀 Chhuah (app-ah thlen)', 'publishPack')
    .addSeparator()
    .addSubMenu(SpreadsheetApp.getUi().createMenu('⚙️ Developer')
      .addItem('Sheet siam ṭha (format, dropdown)', 'setUpSheet')
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
  return { words: readTab('words'), questions: readTab('questions'), sentences: readTab('sentences'), gameText: readTab('gameText') };
}

function hex(bytes) {
  return bytes.map(function (b) { return ('0' + (b & 0xff).toString(16)).slice(-2); }).join('');
}

function sha256Hex(string) {
  return hex(Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, string, Utilities.Charset.UTF_8));
}

/** Pictures in the “Hnahsin thlalak” folder by file name, read on demand. */
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

function checkRows() {
  var result = build(pictureReader());
  if (result.problems.length) return showProblems(result.problems);
  SpreadsheetApp.getUi().alert('A dik vek e! ✅',
    'Thumal ' + result.counts.words + ', zawhna ' + result.counts.questions + ', sentence ' + result.counts.sentences +
    ', game thu ' + result.counts.gameText + ' chhuah theih a ni.\n\nApp-ah thlen tur chuan “🚀 Chhuah” hmet rawh.',
    SpreadsheetApp.getUi().ButtonSet.OK);
}

function publishPack() {
  var ui = SpreadsheetApp.getUi();
  var settings = gitHubSettings();
  if (!settings) {
    ui.alert('GitHub settings a la awm lo. Developer-in “⚙️ Developer → GitHub settings” a dah phawt tur a ni.');
    return;
  }
  var pictures = pictureReader();
  var result = build(pictures);
  if (result.problems.length) return showProblems(result.problems);

  var answer = ui.alert('App-ah thlen dawn',
    'Thumal ' + result.counts.words + ', zawhna ' + result.counts.questions + ', sentence ' + result.counts.sentences +
    ', game thu ' + result.counts.gameText + ' app-ah thlen a ni dawn.\n\nI chhuah ngei dawn em?',
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

  ui.alert('Chhuah a ni e! 🎉',
    'Version ' + result.envelope.version + ' chu chhuah a ni ta (thlalak thar ' + uploaded + ').\n\n' +
    'Minute 10 vel hnuah app hawngtu zawng zawngin an hmu ang.', ui.ButtonSet.OK);
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
    return '<li><b>' + escapeHtml(where) + '</b>' + (link ? ' <a href="' + link + '" target="_blank">(en rawh)</a>' : '') +
      '<br>' + escapeHtml(p.message) + '</li>';
  }).join('');
  var more = problems.length > 150 ? '<p>… leh ' + (problems.length - 150) + ' dang.</p>' : '';
  var html = HtmlService.createHtmlOutput(
    '<div style="font-family:sans-serif;font-size:14px;line-height:1.45">' +
    '<p>Dik lo <b>' + problems.length + '</b> a awm. Siam ṭha la, “✅ Endik” leh rawh. ' +
    'Engmah app-ah thlen a la ni lo.</p><ol>' + items + '</ol>' + more + '</div>')
    .setWidth(560).setHeight(520);
  SpreadsheetApp.getUi().showModalDialog(html, 'Siam ṭhat ngai');
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
  var token = ui.prompt('GitHub token', 'Fine-grained token, Contents: Read and write, he repo chauh:', ui.ButtonSet.OK_CANCEL);
  if (token.getSelectedButton() !== ui.Button.OK) return;
  props.setProperties({
    GITHUB_REPO: repo.getResponseText().trim(),
    GITHUB_TOKEN: token.getResponseText().trim(),
    GITHUB_BRANCH: props.getProperty('GITHUB_BRANCH') || 'main',
  });
  ui.alert('Dah a ni e.');
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
    throw new Error('GitHub-ah dah theih a ni lo (' + response.getResponseCode() + '). Developer hrilh rawh.\n' + response.getContentText());
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
    if (whole('Dinhmun')) whole('Dinhmun').setDataValidation(statuses);
    if (whole('ID')) {
      whole('ID').setBackground('#eeeeee').setFontColor('#777777');
      sheet.getProtections(SpreadsheetApp.ProtectionType.RANGE).forEach(function (old) {
        if (old.getDescription() === 'ID') old.remove();
      });
      whole('ID').protect().setDescription('ID').setWarningOnly(true);
    }
    ['Awmzia (Mizo)', 'Entirna', 'Hrilhfiahna', 'Hriattirna', 'Sentence (Mizo)'].forEach(function (heading) {
      if (column(heading) > 0) sheet.setColumnWidth(column(heading), 280);
    });
    if (key === 'words') {
      sheet.setColumnWidth(column('English'), 200);
      whole('Pawl').setDataValidation(SpreadsheetApp.newDataValidation()
        .requireValueInList(CATEGORIES.map(function (c) { return c[1]; }), true).build());
      GAMES.forEach(function (game) {
        if (column(game[1]) > 0) {
          whole(game[1]).insertCheckboxes();
          sheet.setColumnWidth(column(game[1]), 90);
        }
      });
      var status = sheet.getRange(2, column('Dinhmun')).getA1Notation().replace(/\d+/, '');
      var rules = ['Thumal', 'Awmzia (Mizo)', 'English', 'Entirna', 'Pawl', 'Level'].map(function (heading) {
        var cell = sheet.getRange(2, column(heading)).getA1Notation();
        return SpreadsheetApp.newConditionalFormatRule()
          .whenFormulaSatisfied('=AND($' + status + '2="' + STATUS.live + '",' + cell + '="")')
          .setBackground('#f8d7da').setRanges([whole(heading)]).build();
      });
      sheet.setConditionalFormatRules(rules);
    }
    if (key === 'questions') {
      whole('Chhanna dik (1-4)').setDataValidation(SpreadsheetApp.newDataValidation()
        .requireValueInList(['1', '2', '3', '4'], true).build());
    }
    if (key === 'gameText') {
      whole('Game').setDataValidation(SpreadsheetApp.newDataValidation().requireValueInList(GAME_TEXT_IDS, true).build());
    }
  });

  pictureFolder(true);
  writeHelp(ss);
  SpreadsheetApp.getUi().alert('Sheet siam ṭhat a ni e. Thlalak folder: “' + PICTURE_FOLDER + '”.');
}

function writeHelp(ss) {
  var sheet = ss.getSheetByName(TABS.help) || ss.insertSheet(TABS.help, 0);
  sheet.clear();
  var lines = [
    ['Hnahsin content enkawl dan'],
    [''],
    ['Thumal thar dah dan'],
    ['1. “Thumal” tab-ah a hnuai berah row thar ziak rawh. ID chu ruak takin dah rawh: Chhuah hunah a inziak ang.'],
    ['2. Thumal, Awmzia (Mizo), English leh Entirna (sentence entirna) ziak vek rawh.'],
    ['3. Pawl leh Level (1 = awlsam ber, 7 = har ber) dropdown aṭangin thlang rawh.'],
    ['4. Emoji: thil hmuh theih a nih chauhin dah rawh (🐕, 🌳). Thil hmuh theih loh (hlimna, rilru) chu ruak takin dah rawh.'],
    ['5. Thlalak: “Hnahsin thlalak” folder-ah PNG/JPEG dah la, a file hming (e.g. word.lu.png) he column-ah ziak rawh. Thlalak hi emoji aiin a hmasa.'],
    ['6. Game: thumal hi engteng game-ah nge a lan ang tih tick rawh. Pakhatmah i tick loh chuan game zawng zawngah a lang ang.'],
    ['7. Dinhmun: “Chhuah” = app-ah a lang ang. “Endik mek” = la ziak mek, app-ah a la lang lo. “Paih” = app aṭanga paih.'],
    [''],
    ['App-ah thlen dan'],
    ['1. Menu “Hnahsin → ✅ Endik” hmet rawh. Dik lo awm chu row number nen a lang ang. “(en rawh)” hmet la, siam ṭha rawh.'],
    ['2. Dik lo a awm tawh loh chuan “Hnahsin → 🚀 Chhuah” hmet rawh.'],
    ['3. Minute 10 vel hnuah app hawngtu zawng zawngin an hmu ang. App hi update a ngai lo.'],
    [''],
    ['Thil dik lo i tih palh chuan'],
    ['File → Version history → See version history aṭangin a hma lam version-ah kîr leh la, “🚀 Chhuah” leh rawh.'],
    [''],
    ['Row sen (pink) awmzia'],
    ['“Chhuah” row-ah a ruak theih loh column a ruak tihna a ni. Dah khat rawh.'],
    [''],
    ['Zawhna tab: Tawng Upa game zawhna. Chhanna 4 ziak la, a dik zawk number (1–4) “Chhanna dik”-ah thlang rawh.'],
    ['Sentence tab: Sentence Builder sentence. Mizo sentence leh a English awmzia.'],
    ['Game thu tab: game tina thupui leh khelh dan. A ruak chuan app-a thu awm sa a hmang.'],
  ];
  sheet.getRange(1, 1, lines.length, 1).setValues(lines).setWrap(true);
  sheet.setColumnWidth(1, 820);
  sheet.getRange(1, 1).setFontSize(16).setFontWeight('bold');
  [3, 12, 17, 20].forEach(function (row) { sheet.getRange(row, 1).setFontWeight('bold').setFontSize(12); });
}
