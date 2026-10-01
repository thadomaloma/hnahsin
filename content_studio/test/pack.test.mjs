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
    status: 'Chhuah', ...extra,
  };
}

function tabs() {
  return {
    words: [
      ...Array.from({ length: 21 }, (_, i) => word(i + 1)),
      word(22, { id: '', word: 'Lû', picture: 'lu.png', picture_match: true, thumal_kawp: true }),
      word(23, { status: 'Endik mek', english: '' }),
    ],
    questions: [{
      row: 2, id: '', prompt: '“Thufing” tih hian eng nge a kawh?', option1: 'Finna thu tawi', option2: 'Thawnthu sei',
      option3: 'Hla thu', option4: 'Thu hriattîrna', answer: 1, explanation: 'Thufing chu finna thu tawi a ni.', emoji: '',
      level: '1', status: 'Chhuah',
    }],
    sentences: [{ row: 2, id: 'sentence.001', text: 'Ka nu chu a hlim.', english: 'My mother is happy.', level: 1, status: 'Chhuah' }],
    gameText: [{ row: 2, id: 'game.common', game: 'common', correct_feedback: 'A dik e!', retry_feedback: '', step1: '', status: 'Chhuah' }],
  };
}

test('builds a pack from the live rows and gives new rows an ID', () => {
  const result = P.buildPack(tabs(), options);
  assert.deepEqual(result.problems, []);
  assert.deepEqual(result.counts, { words: 22, questions: 1, sentences: 1, gameText: 1 });
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
    ['Thumal', 5], ['Thumal', 6], ['Thumal', 7], ['Zawhna', 2],
  ]);
  assert.match(result.problems[0].message, /English.*ruak/);
});

test('a pack with too few words is refused, since the app would ignore it', () => {
  const t = tabs();
  t.words = t.words.slice(0, 5);
  assert.match(P.buildPack(t, options).problems.at(-1).message, /thumal 20 tal/);
});

test('a repeated ID is reported', () => {
  const t = tabs();
  t.words[1].id = 'word.w1';
  assert.match(P.buildPack(t, options).problems[0].message, /word\.w1/);
});
