import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thumal_quest/features/content_sync/application/content_transport.dart';

void main() {
  test('production transport rejects an insecure non-local origin', () {
    expect(
      () => HttpContentTransport(baseUri: Uri.parse('http://example.test')),
      throwsArgumentError,
    );
  });

  test('transport sends ETag and preserves a 304 response', () async {
    final client = MockClient((request) async {
      expect(request.headers['If-None-Match'], '"pack-etag"');
      return http.Response('', 304);
    });
    final transport = HttpContentTransport(
      baseUri: Uri.parse('https://staging.example.test'),
      client: client,
    );

    final response = await transport.fetchLatest(
      '/api/v1/content_packs/latest',
      etag: '"pack-etag"',
    );

    expect(response.notModified, isTrue);
    expect(response.etag, '"pack-etag"');
    transport.close();
  });

  test('oversized pack response is rejected before JSON parsing', () async {
    final body = utf8.decode(
      List<int>.filled(HttpContentTransport.maximumPackBytes + 1, 32),
    );
    final transport = HttpContentTransport(
      baseUri: Uri.parse('https://staging.example.test'),
      client: MockClient((_) async => http.Response(body, 200)),
    );

    expect(
      () => transport.fetchLatest('/api/v1/content_packs/latest'),
      throwsA(isA<ContentDeliveryException>()),
    );
    transport.close();
  });
}
