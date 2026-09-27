import 'package:flutter/material.dart';

import '../features/content_sync/domain/delivery_models.dart';
import 'controller.dart';
import 'theme.dart';
import 'widgets.dart';

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
            ? const <Color>[Color(0xFFE3F8F5), Color(0xFFF6FCFB)]
            : const <Color>[Color(0xFFFFE8E4), Color(0xFFFFF8F6)],
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
              const Expanded(
                child: Text(
                  'Offline content',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
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
          Text(state.message, style: const TextStyle(color: QuestColors.slate)),
          if (state.hasRemotePack) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              <String>[
                if (state.contentVersion != null) 'Content ${state.contentVersion}',
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
              controller.contentSyncEnabled ? 'Check for Updates' : 'Built-in Pack',
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
          label: Text(reported ? 'Issue reported' : 'Report content issue'),
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
                'Report a content issue',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              const Text(
                'No personal message is collected. The content reference and reason stay on this device for the review queue.',
                style: TextStyle(color: QuestColors.slate),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final option in const <String>[
                    'Mizo spelling or wording',
                    'Meaning or translation',
                    'Picture does not match',
                    'Cultural context',
                  ])
                    ChoiceChip(
                      label: Text(option),
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
                  label: const Text('Save Report'),
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
      const SnackBar(content: Text('Report saved to the local review queue.')),
    );
  }
}
