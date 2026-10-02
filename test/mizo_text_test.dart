import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/data.dart';

void main() {
  group('Mizo word units', () {
    test('normalizes whitespace and case', () => expect(normalizeMizo('  NULA '), 'nula'));
    test('splits words into Mizo alphabet letters', () {
      expect(firstMizoUnit('Ngur'), 'ng');
      expect(lastMizoUnit('Thing'), 'ng');
      expect(firstMizoUnit('Chaw'), 'ch');
      expect(lastMizoUnit('Chaw'), 'aw');
      // th, tl, hm… are two letters of the alphabet, not one.
      expect(firstMizoUnit('Tlawmngaihna'), 't');
      expect(firstMizoUnit('Thing'), 't');
      expect(lastMizoUnit('nghilh'), 'h');
      expect(mizoUnits('hmun'), ['h', 'm', 'u', 'n']);
    });
    test('circumflexes stay the same letter, ṭ is its own', () {
      expect(mizoUnits('sâwm'), ['s', 'aw', 'm']);
      expect(lastMizoUnit('nâ'), 'a');
      expect(firstMizoUnit('ṭhian'), 'ṭ');
    });
    test('supports word-chain comparison', () {
      expect(lastMizoUnit('In'), firstMizoUnit('Nula'));
      expect(lastMizoUnit('Nula'), firstMizoUnit('Aizawl'));
    });
    test('definitions drop an opening that names the word', () {
      expect(meaningWithoutWord('Bilh tih hi puan a khim dan a ni.', 'bilh'), 'Puan a khim dan a ni.');
      expect(meaningWithoutWord('Bauh chu ui au dan a ni.', 'Bauh'), 'Ui au dan a ni.');
      expect(meaningWithoutWord('Thlêng chu, ei dawn atana hmanraw.', 'thleng'), 'Ei dawn atana hmanraw.');
      expect(meaningWithoutWord('A farnu an ti.', 'farnu'), 'A …… an ti.');
      expect(meaningWithoutWord('Hla sak.', 'zai'), 'Hla sak.');
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
