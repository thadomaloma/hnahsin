// node --test content_studio/test
// UPDATE_FIXTURE=1 also rewrites test/fixtures/sheet_pack.json, which the
// app's test/sheet_pack_test.dart parses with the real pack validator.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const P = require('../Pack.js');
const sha256Hex = (s) => createHash('sha256').update(s, 'utf8').digest('hex');
const options = {
  sha256Hex,
  picture: (name) => (name === 'lu.png' ? { checksum: 'a'.repeat(64), content_type: 'image/png', byte_size: 1200 } : null),
  version: '2.20261001.120000',
  id: '00000000-0000-4000-8000-000000000000',
  now: '2026-10-01T12:00:00Z',
};

function word(n, extra = {}) {
  return {
    row: n + 1, id: `word.w${n}`, word: `thumal${n}`, meaning: 'Awmzia a ni.', english: `meaning ${n}`,
    example: `Thumal${n} hi a ṭha.`, emoji: '', picture: '', category: 'Khawvel', level: n <= 5 ? 1 : 3,
    status: 'Live', ...extra,
  };
}

function tabs() {
  return {
    words: [
      ...Array.from({ length: 21 }, (_, i) => word(i + 1)),
      word(22, { id: '', word: 'Lû', picture: 'lu.png', picture_match: true, thumal_kawp: true }),
      word(23, { status: 'In review', english: '' }),
    ],
    questions: [{
      row: 2, id: '', prompt: '“Thufing” tih hian eng nge a kawh?', option1: 'Finna thu tawi', option2: 'Thawnthu sei',
      option3: 'Hla thu', option4: 'Thu hriattîrna', answer: 1, explanation: 'Thufing chu finna thu tawi a ni.', emoji: '',
      level: '1', status: 'Live',
    }],
    sentences: [{ row: 2, id: 'sentence.001', text: 'Ka nu chu a hlim.', english: 'My mother is happy.', level: 1, status: 'Live' }],
    gameText: [{ row: 2, id: 'game.common', game: 'common', correct_feedback: 'A dik e!', retry_feedback: '', step1: '', status: 'Live' }],
    appText: [
      { row: 2, id: 'home.play', where: 'Home', default: 'Khel rawh', text: 'Khel nghal rawh', note: '' },
      { row: 3, id: 'home.streak', where: 'Home', default: '{n} day streak', text: 'Ni {n} indawt', note: '' },
      { row: 4, id: 'nav.home', where: 'Navigation', default: 'Home', text: 'Home', note: '' },
      { row: 5, id: 'nav.games', where: 'Navigation', default: 'Games', text: '', note: '' },
    ],
  };
}

test('builds a pack from the live rows and gives new rows an ID', () => {
  const result = P.buildPack(tabs(), options);
  assert.deepEqual(result.problems, []);
  assert.deepEqual(result.counts, { words: 22, questions: 1, sentences: 1, gameText: 1, appText: 2 });
  assert.deepEqual(result.newIds.map((n) => n.id), ['word.lu', 'question.thufingtihhianengngeakawh']);
  const items = result.envelope.manifest.items;
  const lu = items.find((i) => i.stable_id === 'word.lu');
  assert.deepEqual(lu.body.game_modes, ['picture_match', 'thumal_kawp']);
  assert.equal(lu.body.image.checksum, 'a'.repeat(64));
  assert.equal(items.find((i) => i.content_type === 'question').body.answer, 'Finna thu tawi');
  assert.equal(result.envelope.checksum, sha256Hex(P.canonicalJson(result.envelope.manifest)));
  if (process.env.UPDATE_FIXTURE) {
    writeFileSync(new URL('../../test/fixtures/sheet_pack.json', import.meta.url), JSON.stringify(result.envelope, null, 1) + '\n');
  }
});

test('reports problems in Mizo with the row, and builds nothing', () => {
  const t = tabs();
  t.words[3].english = '';
  t.words[4].level = 9;
  t.words[5].picture = 'awm-lo.png';
  t.questions[0].option2 = 'Finna thu tawi';
  const result = P.buildPack(t, options);
  assert.equal(result.envelope, null);
  assert.deepEqual(result.problems.map((p) => [p.tab, p.row]), [
    ['Words', 5], ['Words', 6], ['Words', 7], ['Questions', 2],
  ]);
  assert.match(result.problems[0].message, /English.*empty/);
});

test('a pack with too few words is refused, since the app would ignore it', () => {
  const t = tabs();
  t.words = t.words.slice(0, 5);
  assert.match(P.buildPack(t, options).problems.at(-1).message, /at least 20/);
});

test('a repeated ID is reported', () => {
  const t = tabs();
  t.words[1].id = 'word.w1';
  assert.match(P.buildPack(t, options).problems[0].message, /word\.w1/);
});

test('app text reaches the pack only when it was changed', () => {
  const items = P.buildPack(tabs(), options).envelope.manifest.items.filter((i) => i.content_type === 'app_text');
  assert.deepEqual(items.map((i) => [i.stable_id, i.body]), [
    ['app.home.play', { text_id: 'home.play', text: 'Khel nghal rawh' }],
    ['app.home.streak', { text_id: 'home.streak', text: 'Ni {n} indawt' }],
  ]);
});

test('app text must keep the built-in placeholders, and only those', () => {
  const t = tabs();
  t.appText[1].text = 'Ni indawt';
  t.appText[0].text = 'Khel {now} rawh';
  const problems = P.buildPack(t, options).problems;
  assert.deepEqual(problems.map((p) => [p.tab, p.row]), [['App text', 2], ['App text', 3]]);
  assert.match(problems[1].message, /\{n\}/);
});

test('an app text row the app does not know is reported', () => {
  const t = tabs();
  t.appText.push({ row: 6, id: 'home.typo', where: '', default: '', text: 'Chibai', note: '' });
  assert.match(P.buildPack(t, options).problems[0].message, /home\.typo/);
});
