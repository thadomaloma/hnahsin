import 'package:flutter/foundation.dart';

import 'application/content_sync_service.dart';
import 'application/content_transport.dart';
import 'data/offline_pack_store.dart';

Future<ContentSyncService?> createContentSyncService() async {
  // THUMAL_QUEST_API_BASE_URL is the name used before the rename; builds
  // that still pass it keep getting content.
  const configured = String.fromEnvironment(
    'HNAHSIN_API_BASE_URL',
    defaultValue: String.fromEnvironment('THUMAL_QUEST_API_BASE_URL'),
  );
  if (configured.trim().isEmpty) return null;
  final baseUri = Uri.tryParse(configured);
  if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty)
    return null;
  try {
    // File storage needs dart:io, which web builds lack; web keeps the
    // verified pack in memory and re-syncs on each launch.
    final OfflinePackStore store =
        kIsWeb ? MemoryOfflinePackStore() : await FileOfflinePackStore.open();
    return ContentSyncService(
      transport: HttpContentTransport(baseUri: baseUri),
      store: store,
    );
  } catch (_) {
    // A delivery configuration or storage failure must not block bundled play.
    return null;
  }
}
