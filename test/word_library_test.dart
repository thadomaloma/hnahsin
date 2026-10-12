import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/screens.dart';

void main() {
  testWidgets('a word keeps its line even beside a long English meaning',
      (tester) async {
    tester.view.physicalSize = const Size(320, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = QuestController(repository: InMemoryQuestRepository());
    await tester.pumpWidget(
        MaterialApp(home: WordBankScreen(controller: controller)));
    await tester.pump();

    expect(tester.takeException(), isNull);
    for (final entry in controller.wordCatalog.take(10)) {
      final word = find.text(entry.word);
      if (word.evaluate().isEmpty) continue;
      // One line high: the word isn't broken into letters.
      expect(tester.getSize(word.first).height, lessThan(30), reason: entry.word);
    }
  });
}
