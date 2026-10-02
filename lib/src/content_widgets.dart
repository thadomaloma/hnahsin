import 'package:flutter/material.dart';

import '../features/content_sync/domain/delivery_models.dart';
import 'controller.dart';
import 'theme.dart';
import 'widgets.dart';
import 'app_text.dart';

class ContentDeliveryStatusCard extends StatelessWidget {
  const ContentDeliveryStatusCard({super.key, required this.controller});

  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.contentSyncState;
    final safe = state.outcome != ContentSyncOutcome.invalidRejected;
    return PremiumCard(
      gradient: LinearGradient(
        colors: safe
            ? const <Color>[Color(0xFFDDF3FF), Color(0xFFF6FCFB)]
            : const <Color>[Color(0xFFFCE4EC), Color(0xFFFFF8F6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                safe ? Icons.offline_pin_rounded : Icons.gpp_bad_rounded,
                color: safe ? QuestColors.tealDark : QuestColors.coral,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppText.of('content.offline'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
              ),
              if (state.isChecking)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            // No message yet: only the built-in words, no pack checked.
            state.message.isEmpty ? AppText.of('sync.builtInReady') : state.message,
            style: const TextStyle(color: QuestColors.slate),
          ),
          if (state.hasRemotePack) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              <String>[
                if (state.contentVersion != null) AppText.of('content.version', {'version': state.contentVersion}),
              ].join(' • '),
              style: const TextStyle(
                color: QuestColors.tealDark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: !controller.contentSyncEnabled || state.isChecking
                ? null
                : controller.refreshContent,
            icon: const Icon(Icons.sync_rounded),
            label: Text(
              controller.contentSyncEnabled ? AppText.of('content.check') : AppText.of('content.builtIn'),
            ),
          ),
        ],
      ),
    );
  }
}

class ContentReportButton extends StatelessWidget {
  const ContentReportButton({
    super.key,
    required this.controller,
    required this.contentId,
  });

  final QuestController controller;
  final String contentId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final reported =
            controller.learningState.reportedContentIds.contains(contentId);
        return TextButton.icon(
          onPressed: reported
              ? null
              : () => showContentReportSheet(
                    context,
                    controller: controller,
                    contentId: contentId,
                  ),
          icon: Icon(
            reported ? Icons.flag_rounded : Icons.outlined_flag_rounded,
          ),
          label: Text(reported ? AppText.of('report.done') : AppText.of('report.open')),
        );
      },
    );
  }
}

Future<void> showContentReportSheet(
  BuildContext context, {
  required QuestController controller,
  required String contentId,
}) async {
  var reason = 'Mizo spelling or wording';
  final submitted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppText.of('report.title'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                AppText.of('report.privacy'),
                style: const TextStyle(color: QuestColors.slate),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  // The saved reason is the English key; the label can change.
                  for (final (option, textId) in const <(String, String)>[
                    ('Mizo spelling or wording', 'report.spelling'),
                    ('Meaning or translation', 'report.meaning'),
                    ('Picture does not match', 'report.picture'),
                    ('Cultural context', 'report.culture'),
                  ])
                    ChoiceChip(
                      label: Text(AppText.of(textId)),
                      selected: reason == option,
                      onSelected: (_) =>
                          setSheetState(() => reason = option),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await controller.reportContent(contentId, reason: reason);
                    if (context.mounted) Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: Text(AppText.of('report.save')),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (submitted == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppText.of('report.saved'))),
    );
  }
}
