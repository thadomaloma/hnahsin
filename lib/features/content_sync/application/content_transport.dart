import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PackResponse {
  const PackResponse({required this.notModified, this.body, this.etag});

  final bool notModified;
  final Map<String, Object?>? body;
  final String? etag;
}

abstract interface class ContentTransport {
  Future<PackResponse> fetchLatest(String path, {String? etag});

  Future<List<int>> download(String path, {required int maximumBytes});


  void close();
}

class HttpContentTransport implements ContentTransport {
  HttpContentTransport({required this.baseUri, http.Client? client})
      : _client = client ?? http.Client() {
    final local =
        <String>{'localhost', '127.0.0.1', '10.0.2.2'}.contains(baseUri.host);
    if (baseUri.scheme != 'https' && !(local && baseUri.scheme == 'http')) {
      throw ArgumentError(
          'Content delivery requires HTTPS outside local development.');
    }
  }

  final Uri baseUri;
  final http.Client _client;
  static const maximumPackBytes = 5 * 1024 * 1024;

  /// [path] under the base URL, keeping the base's own folder: packs on
  /// GitHub Pages live under https://owner.github.io/<repo>/api/v1/….
  Uri _resolve(String path) {
    final folder = baseUri.path.endsWith('/') ? baseUri.path : '${baseUri.path}/';
    return baseUri.replace(path: folder).resolve(path.replaceFirst(RegExp(r'^/+'), ''));
  }

  @override
  Future<PackResponse> fetchLatest(String path, {String? etag}) async {
    final request = http.Request('GET', _resolve(path));
    // On web a manual If-None-Match forces a CORS preflight; the browser's
    // HTTP cache already revalidates with the ETag on its own.
    if (etag != null && !kIsWeb) request.headers['If-None-Match'] = etag;
    final response =
        await _client.send(request).timeout(const Duration(seconds: 12));
    if (response.statusCode == 304 || response.statusCode == 404) {
      await response.stream.drain<void>();
      return PackResponse(notModified: true, etag: etag);
    }
    if (response.statusCode != 200) {
      await response.stream.drain<void>();
      throw ContentDeliveryException(
          'Pack request failed (${response.statusCode}).');
    }
    final bytes = <int>[];
    await for (final chunk
        in response.stream.timeout(const Duration(seconds: 20))) {
      bytes.addAll(chunk);
      if (bytes.length > maximumPackBytes) {
        throw const ContentDeliveryException(
            'Pack response exceeded the safe limit.');
      }
    }
    final payload = jsonDecode(utf8.decode(bytes));
    if (payload is! Map)
      throw const FormatException('Pack response must be an object.');
    return PackResponse(
      notModified: false,
      body: Map<String, Object?>.from(payload),
      etag: response.headers['etag'],
    );
  }

  @override
  Future<List<int>> download(String path, {required int maximumBytes}) async {
    final request = http.Request('GET', _resolve(path));
    final response = await _client.send(request).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      await response.stream.drain<void>();
      throw ContentDeliveryException('Download failed (${response.statusCode}).');
    }
    final bytes = <int>[];
    await for (final chunk in response.stream.timeout(const Duration(seconds: 20))) {
      bytes.addAll(chunk);
      if (bytes.length > maximumBytes) {
        throw const ContentDeliveryException('Download exceeded its declared size.');
      }
    }
    return bytes;
  }

  @override
  void close() => _client.close();
}

class ContentDeliveryException implements Exception {
  const ContentDeliveryException(this.message);
  final String message;

  @override
  String toString() => message;
}
