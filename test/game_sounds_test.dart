import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/game_sounds.dart';

void main() {
  test('every game sound has its file in assets', () {
    for (final sound in GameSound.values) {
      expect(File('assets/${sound.asset}').existsSync(), isTrue, reason: sound.name);
    }
  });
}
