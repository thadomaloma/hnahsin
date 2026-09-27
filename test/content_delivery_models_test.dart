import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/features/content_sync/domain/delivery_models.dart';

void main() {
  test('canonical JSON is stable across object key order', () {
    final first = canonicalJson(<String, Object?>{
      'b': 2,
      'a': <String, Object?>{'z': true, 'c': 1},
    });
    final second = canonicalJson(<String, Object?>{
      'a': <String, Object?>{'c': 1, 'z': true},
      'b': 2,
    });

    expect(first, second);
  });

  test('content envelope requires Mizo schema and matching checksum', () {
    final body = <String, Object?>{'mizo': 'In'};
    final manifest = <String, Object?>{
      'schema_version': '1.0',
      'language': 'lus',
      'pack_version': '1.0.0',
      'items': <Object?>[
        <String, Object?>{
          'stable_id': 'word.in',
          'checksum':
              sha256.convert(utf8.encode(canonicalJson(body))).toString(),
          'body': body,
        },
      ],
    };
    final checksum =
        sha256.convert(utf8.encode(canonicalJson(manifest))).toString();
    final envelope = PackEnvelope.parse(
      <String, Object?>{
        'id': 'pack.001',
        'version': '1.0.0',
        'checksum': checksum,
        'manifest': manifest,
      },
      kind: DeliveryPackKind.content,
    );

    expect(envelope.version, '1.0.0');
    expect(
      () => PackEnvelope.parse(
        <String, Object?>{
          'id': 'pack.001',
          'version': '1.0.0',
          'checksum': _repeat('0', 64),
          'manifest': manifest,
        },
        kind: DeliveryPackKind.content,
      ),
      throwsFormatException,
    );

    final tamperedManifest = Map<String, Object?>.from(manifest);
    tamperedManifest['items'] = <Object?>[
      <String, Object?>{
        'stable_id': 'word.in',
        'checksum': sha256.convert(utf8.encode(canonicalJson(body))).toString(),
        'body': <String, Object?>{'mizo': 'Inn'},
      },
    ];
    expect(
      () => PackEnvelope.parse(
        <String, Object?>{
          'id': 'pack.002',
          'version': '1.0.0',
          'checksum': sha256
              .convert(utf8.encode(canonicalJson(tamperedManifest)))
              .toString(),
          'manifest': tamperedManifest,
        },
        kind: DeliveryPackKind.content,
      ),
      throwsFormatException,
    );
  });

  test('reviewed word bodies map into the runtime delivery catalog', () {
    final words = DeliveredWord.parseAll(<Object?>[
      <String, Object?>{
        'stable_id': 'in',
        'content_type': 'word',
        'body': <String, Object?>{
          'word': 'In',
          'meaning_mizo': 'Mihring chenna hmun',
          'english_gloss': 'House',
          'example_mizo': 'Kan inah lo kal rawh.',
          'emoji': '🏠',
          'category': 'chhungkua',
          'difficulty': 1,
        },
      },
    ]);

    expect(words.single.englishGloss, 'House');
  });

  test(
      'nested Content Schema V2 bodies map seed_category via the fallback table',
      () {
    // Regression test for the 2026-09-19 fix: every seed_category value
    // actually used in the CSV content packs must resolve to one of the
    // six delivery categories, or the word silently disappears from the
    // catalog even after full review and publish. 'food' was one of the
    // 17 values missing before that fix (affecting 76 words alone).
    final words = DeliveredWord.parseAll(<Object?>[
      <String, Object?>{
        'stable_id': 'word.chhangban',
        'content_type': 'word',
        'body': <String, Object?>{
          'content': <String, Object?>{
            'canonical_form': 'Chhangban',
            'definition_mizo': 'Ei thei thil',
            'glosses': <String, Object?>{'en': 'Rice'},
            'example_mizo': 'Chhangban ei rawh.',
            'emoji': '🍚',
          },
          'learning': <String, Object?>{
            'difficulty': 1,
            'categories': <String>['food'],
          },
        },
      },
    ]);

    expect(words.single.category, 'khawvel');
    expect(words.single.englishGloss, 'Rice');
  });

  test('reviewed words without a curated emoji stay in the catalog', () {
    // Most Kumtluang words have no emoji; requiring one silently dropped
    // 706 published words from every game.
    final words = DeliveredWord.parseAll(<Object?>[
      <String, Object?>{
        'stable_id': 'word.tlawmngaihna',
        'content_type': 'word',
        'body': <String, Object?>{
          'content': <String, Object?>{
            'canonical_form': 'Tlawmngaihna',
            'definition_mizo': 'Mahni hmasial lova mi dang ṭanpui',
            'glosses': <String, Object?>{'en': 'Selflessness'},
            'example_mizo': 'Tlawmngaihna hi Mizo nunphung a ni.',
            'emoji': '',
          },
          'learning': <String, Object?>{
            'difficulty': 2,
            'categories': <String>['values'],
          },
        },
      },
    ]);

    expect(words.single.word, 'Tlawmngaihna');
    expect(words.single.emoji, isEmpty);
  });
}

String _repeat(String value, int count) =>
    List<String>.filled(count, value).join();
