import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ReportsApiException implements Exception {
  const ReportsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ReportsService {
  ReportsService({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const String _baseUrl =
      'https://portal.gopangitsolution.com';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<String> _getToken() async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) {
      throw const ReportsApiException(
        'Your session has expired. Please sign in again.',
      );
    }

    return token;
  }

  Future<Map<String, dynamic>> _request(
      String method,
      String path, {
        Map<String, String?>? query,
        Map<String, dynamic>? body,
      }) async {
    final token = await _getToken();

    final filteredQuery = <String, String>{};

    query?.forEach((key, value) {
      if (value != null && value.trim().isNotEmpty) {
        filteredQuery[key] = value.trim();
      }
    });

    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: filteredQuery.isEmpty ? null : filteredQuery,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }

    try {
      late http.Response response;

      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 20));
          break;

        case 'POST':
          response = await _client
              .post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
              .timeout(const Duration(seconds: 20));
          break;

        case 'PUT':
          response = await _client
              .put(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
              .timeout(const Duration(seconds: 20));
          break;

        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 20));
          break;

        default:
          throw const ReportsApiException(
            'Unsupported request method.',
          );
      }

      return _decodeResponse(response);
    } on ReportsApiException {
      rethrow;
    } on TimeoutException {
      throw const ReportsApiException(
        'The server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw const ReportsApiException(
        'Unable to connect. Please check your internet connection.',
      );
    } on http.ClientException {
      throw const ReportsApiException(
        'Could not connect to the server.',
      );
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final responseText = response.body.trim();
    dynamic decoded;

    if (responseText.isNotEmpty) {
      try {
        decoded = jsonDecode(responseText);
      } on FormatException {
        if (response.statusCode >= 200 &&
            response.statusCode < 300) {
          throw const ReportsApiException(
            'The server returned an unexpected response.',
          );
        }
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (decoded == null) {
        return <String, dynamic>{};
      }

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw const ReportsApiException(
        'The server response format is not supported.',
      );
    }

    if (response.statusCode == 401) {
      throw const ReportsApiException(
        'Your session is invalid or expired. Please sign in again.',
      );
    }

    if (response.statusCode == 403) {
      throw const ReportsApiException(
        'You are not authorized to perform this action.',
      );
    }

    if (decoded is Map) {
      final errors = decoded['errors'];

      if (errors is Map) {
        final messages = <String>[];

        for (final value in errors.values) {
          if (value is List) {
            messages.addAll(
              value.map((item) => item.toString()),
            );
          } else if (value != null) {
            messages.add(value.toString());
          }
        }

        if (messages.isNotEmpty) {
          throw ReportsApiException(messages.join('\n'));
        }
      }

      final message = decoded['message'];

      if (message is String && message.trim().isNotEmpty) {
        throw ReportsApiException(message);
      }
    }

    throw ReportsApiException(
      'Request failed (HTTP ${response.statusCode}).',
    );
  }

  Future<Map<String, dynamic>> getReports({
    String? status,
    String? search,
    String? from,
    String? to,
    int page = 1,
  }) {
    return _request(
      'GET',
      '/api/reports',
      query: {
        'status': status,
        'search': search,
        'from': from,
        'to': to,
        'page': page.toString(),
      },
    );
  }

  Future<Map<String, dynamic>> getReportDetails(int reportId) {
    return _request(
      'GET',
      '/api/reports/$reportId',
    );
  }

  // Create Report: multipart/form-data with the confirmed API keys.
  Future<Map<String, dynamic>> createReport(
      Map<String, dynamic> data, {
        File? attachment,
      }) async {
    final token = await _getToken();

    final uri = Uri.parse('$_baseUrl/api/reports');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'attachment',
          attachment.path,
        ),
      );
    }

    try {
      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));

      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(const Duration(seconds: 20));

      return _decodeResponse(response);
    } on ReportsApiException {
      rethrow;
    } on TimeoutException {
      throw const ReportsApiException(
        'The server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw const ReportsApiException(
        'Unable to connect. Please check your internet connection.',
      );
    } on http.ClientException {
      throw const ReportsApiException(
        'Could not connect to the server.',
      );
    }
  }

  Future<Map<String, dynamic>> updateReport(
      int reportId,
      Map<String, dynamic> data,
      ) {
    return _request(
      'PUT',
      '/api/reports/$reportId',
      body: data,
    );
  }

  Future<Map<String, dynamic>> deleteReport(int reportId) {
    return _request(
      'DELETE',
      '/api/reports/$reportId',
    );
  }

  void dispose() {
    _client.close();
  }
}