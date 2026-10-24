import 'dart:js_interop';

@JS('location.replace')
external void _replace(JSString url);

/// Back to the Playground's app section, next to the app's own folder.
void leaveToPlayground() => _replace(Uri.base.resolve('../playground.html#app').toString().toJS);
