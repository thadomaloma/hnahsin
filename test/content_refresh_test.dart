import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/content_sync/application/content_sync_service.dart';
import 'package:thumal_quest/features/content_sync/application/content_transport.dart';
import 'package:thumal_quest/features/content_sync/data/offline_pack_store.dart';
import 'package:thumal_quest/src/controller.dart';

/// Counts pack requests; answers as if offline, which still records a sync
/// attempt.
class _CountingTransport implements ContentTransport {
  int requests = 0;

  @override
  Future<PackResponse> fetchLatest(String path, {String? etag}) async {
    requests += 1;
    throw const ContentDeliveryException('offline');
  }

  @override
  Future<List<int>> download(String path, {required int maximumBytes}) async => const <int>[];

  @override
  void close() {}
}

void main() {
  test('coming back to the app checks for new content at most every 5 minutes', () async {
    final transport = _CountingTransport();
    final controller = QuestController(
      repository: InMemoryQuestRepository(),
      contentSyncService: ContentSyncService(transport: transport, store: MemoryOfflinePackStore()),
    );

    await controller.refreshContentIfStale();
    expect(transport.requests, 1, reason: 'never checked yet');

    final checked = DateTime.now().toUtc();
    await controller.refreshContentIfStale(now: checked.add(const Duration(minutes: 2)));
    expect(transport.requests, 1, reason: 'checked 2 minutes ago');

    await controller.refreshContentIfStale(now: checked.add(QuestController.contentRecheckAfter));
    expect(transport.requests, 2, reason: '5 minutes have passed');
  });

  test('without a content URL there is nothing to check', () async {
    await QuestController(repository: InMemoryQuestRepository()).refreshContentIfStale();
  });
}
