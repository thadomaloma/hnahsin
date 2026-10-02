import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/content_sync/domain/delivery_models.dart';

/// test/fixtures/sheet_pack.json is built by content_studio/Pack.js (the
/// Google Sheet's Publish) in content_studio/test/pack.test.mjs, so this
/// checks the sheet's packs pass the app's own validation.
void main() {
  test('a pack published from the Google Sheet passes the app\'s checks', () {
    final payload = jsonDecode(File('test/fixtures/sheet_pack.json').readAsStringSync()) as Map<String, Object?>;
    final envelope = PackEnvelope.parse(payload, kind: DeliveryPackKind.content);
    final items = envelope.manifest['items'];

    final words = DeliveredWord.parseAll(items);
    expect(words, hasLength(22));
    final lu = words.singleWhere((word) => word.id == 'word.lu');
    expect(lu.word, 'Lû');
    expect(lu.category, 'khawvel');
    expect(lu.gameModes, {'picture_match', 'thumal_kawp'});
    expect(lu.image?.checksum, 'a' * 64);

    final question = DeliveredQuestion.parseAll(items).single;
    expect(question.answer, 'Finna thu tawi');
    expect(question.options, hasLength(4));
    expect(DeliveredSentence.parseAll(items).single.textMizo, 'Ka nu chu a hlim.');
    final common = DeliveredGameCopy.parseAll(items)['common']!;
    expect(common.fields, {'correct_feedback': 'A dik e!'});
  });
}
