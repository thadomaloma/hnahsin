// Opening the web build straight into one game, for the Hnahsin web site's Playground.
// `app/?game=spelling` opens Spelling; when the player leaves the game, the page goes
// back to the Playground. Phones never get a link like that, so the app is unchanged there.
export 'leave_stub.dart' if (dart.library.js_interop) 'leave_web.dart';

/// The game the web address asks for, if any.
String? linkedGameId() {
  final id = Uri.base.queryParameters['game'];
  return id == null || id.isEmpty ? null : id;
}
