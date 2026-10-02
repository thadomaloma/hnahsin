import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/data.dart';

void main() {
  test('draft content is never playable', () {
    expect(ContentPolicy.playable(ContentReview.draft), isFalse);
  });

  test('approved content remains playable in internal builds', () {
    expect(ContentPolicy.playable(ContentReview.approved), isTrue);
  });
}
