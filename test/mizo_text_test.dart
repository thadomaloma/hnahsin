import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/src/data.dart';

void main() {
  group('Mizo word units', () {
    test('normalizes whitespace and case', () => expect(normalizeMizo('  NULA '), 'nula'));
    test('treats common consonant clusters as one unit', () {
      expect(firstMizoUnit('Ngur'), 'ng');
      expect(lastMizoUnit('Thing'), 'ng');
      expect(firstMizoUnit('Tlawmngaihna'), 'tl');
    });
    test('supports word-chain comparison', () {
      expect(lastMizoUnit('In'), firstMizoUnit('Nula'));
      expect(lastMizoUnit('Nula'), firstMizoUnit('Aizawl'));
    });
    test('folds circumflexes and ṭ for typed answers', () {
      expect(foldMizo(' Hmûn '), 'hmun');
      expect(foldMizo('ṬÂNG'), 'tang');
      expect(foldMizo('nula'), 'nula');
    });
    test('keeps Mizo cloud language code explicit', () {
      expect(MizoCloudConfig.translationLanguageCode, 'lus');
      expect(MizoCloudConfig.backendOnly, isTrue);
    });
  });
}
