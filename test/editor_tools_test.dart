import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/src/editor_tools.dart';

void main() {
  testWidgets('players never see the Studio button', (tester) async {
    // Test and player builds don't pass THUMAL_QUEST_EDITOR_TOOLS.
    expect(EditorTools.enabled, isFalse);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StudioFixButton(contentId: 'word.auh'))));
    expect(find.byType(TextButton), findsNothing);
  });

  test('links to the Studio item by stable id', () {
    expect(EditorTools.studioLink('word.auh').path, '/editorial/open/word.auh');
    expect(EditorTools.studioLink('sentence.word.word.bâwng').path,
        '/editorial/open/sentence.word.word.b%C3%A2wng');
  });
}
