import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../error/exceptions.dart';

/// Thin wrapper around [http.Client].
///
/// Single responsibility: perform a GET request and translate transport /
/// HTTP-level problems into typed exceptions. It knows nothing about
/// weather — any feature can reuse it.
class ApiClient {
  ApiClient(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 15);

  /// Performs a GET and returns the decoded JSON body as a map.
  ///
  /// Throws:
  /// - [NetworkException] when offline or timed out,
  /// - [CityNotFoundException] for weatherapi error code 1006,
  /// - [ServerException] for any other non-200 response or bad body.
  Future<Map<String, dynamic>> getJson(Uri uri) async {
    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }

    final body = _decode(response.body);

    if (response.statusCode == 200) return body;

    // weatherapi.com returns {"error": {"code": 1006, "message": "..."}}
    final errorCode = (body['error'] as Map<String, dynamic>?)?['code'];
    if (errorCode == 1006) throw const CityNotFoundException();

    throw ServerException('Server error (${response.statusCode})');
  }

  Map<String, dynamic> _decode(String body) {
    try {
      return json.decode(body) as Map<String, dynamic>;
    } on FormatException {
      throw const ServerException('Invalid response from server');
    }
  }
}
