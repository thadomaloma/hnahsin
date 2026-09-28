import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data.dart';

/// Shortcuts for the content team, compiled in only with
/// `--dart-define=THUMAL_QUEST_EDITOR_TOOLS=true` (see run_local.command).
/// Player builds never pass it, and production builds switch it off
/// regardless, so players never see these.
abstract final class EditorTools {
  static const _requested = bool.fromEnvironment('THUMAL_QUEST_EDITOR_TOOLS');
  static const _studio = String.fromEnvironment('THUMAL_QUEST_API_BASE_URL');

  static bool get enabled =>
      _requested && !ContentPolicy.isProduction && _studio.trim().isNotEmpty;

  /// The Studio page for the content a game shows as [contentId].
  static Uri studioLink(String contentId) => Uri.parse(_studio.trim())
      .resolve('/editorial/open/${Uri.encodeComponent(contentId)}');
}

/// “Fix in Studio” for the word, question or sentence on screen; nothing at
/// all unless [EditorTools.enabled].
class StudioFixButton extends StatelessWidget {
  const StudioFixButton({super.key, required this.contentId});

  final String? contentId;

  @override
  Widget build(BuildContext context) {
    final id = contentId;
    if (!EditorTools.enabled || id == null || id.isEmpty) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => launchUrl(EditorTools.studioLink(id),
            webOnlyWindowName: 'hnahsinStudio'),
        icon: const Icon(Icons.edit_note_rounded),
        label: Text('Studio-ah fix rawh ($id)'),
      ),
    );
  }
}
