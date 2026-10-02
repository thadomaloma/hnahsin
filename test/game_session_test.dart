import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/game_session.dart';

void main() {
  test('combo increases score and wrong answer removes a heart', () {
    final session = GameSession();
    session.registerAnswer(true);
    session.registerAnswer(true);
    session.registerAnswer(false);
    expect(session.score, 225);
    expect(session.bestCombo, 2);
    expect(session.combo, 0);
    expect(session.hearts, 2);
  });

  test('result calculates accuracy, stars and XP', () {
    final session = GameSession();
    session.registerAnswer(true);
    session.registerAnswer(true);
    session.registerAnswer(true);
    final result = session.finish(baseXp: 40);
    expect(result.accuracy, 1);
    expect(result.stars, 3);
    expect(result.xp, 40);
  });
}
