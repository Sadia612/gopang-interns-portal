import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Custom exception class thrown during attendance service operations and network failures.
class AttendanceException implements Exception {
  final String message;

  const AttendanceException(this.message);

  @override
  String toString() => message;
}

/// Service class handling network communications and data processing for employee attendance.
class AttendanceService {
  static const String _baseUrl = 'https://portal.gopangitsolution.com';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const Duration _timeout = Duration(seconds: 20);

  /// Fetches the current attendance status of the authenticated user.
  Future<Map<String, dynamic>> getStatus() {
    return _request(
      method: 'GET',
      path: '/api/attendance/status',
    );
  }

  /// Retrieves historical attendance logs based on applied date range, page, and status filters.
  Future<Map<String, dynamic>> getHistory({
    String range = 'month',
    String? from,
    String? to,
    String? status,
    int page = 1,
  }) {
    final query = <String, String>{
      'range': range,
      'page': page.toString(),
    };

    if (from != null && from.isNotEmpty) {
      query['from'] = from;
    }

    if (to != null && to.isNotEmpty) {
      query['to'] = to;
    }

    if (status != null && status.isNotEmpty && status != 'all') {
      query['status'] = status;
    }

    return _request(
      method: 'GET',
      path: '/api/attendance',
      query: query,
    );
  }

  /// Submits a check-in request for the user.
  Future<Map<String, dynamic>> checkIn() {
    return _request(
      method: 'POST',
      path: '/api/attendance/check-in',
    );
  }

  /// Submits a check-out request for the user.
  Future<Map<String, dynamic>> checkOut() {
    return _request(
      method: 'POST',
      path: '/api/attendance/check-out',
    );
  }

  /// Submits a request to start a break session.
  Future<Map<String, dynamic>> startBreak() {
    return _request(
      method: 'POST',
      path: '/api/attendance/break-start',
    );
  }

  /// Submits a request to end an ongoing break session.
  Future<Map<String, dynamic>> endBreak() {
    return _request(
      method: 'POST',
      path: '/api/attendance/break-end',
    );
  }

  /// Helper method handling secure token retrieval, network execution, and response parsing.
  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Map<String, String>? query,
  }) async {
    // Read secure authorization token
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.trim().isEmpty) {
      throw const AttendanceException(
        'Session token not found. Please log in again.',
      );
    }

    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: query,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      late http.Response response;

      // Dispatch request based on specified method
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(_timeout);
          break;

        case 'POST':
          response = await http.post(uri, headers: headers).timeout(_timeout);
          break;

        default:
          throw const AttendanceException(
            'Unsupported HTTP method provided.',
          );
      }

      dynamic decoded;

      // Parse JSON response body
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw const AttendanceException(
          'The server did not return a valid JSON response.',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw const AttendanceException(
          'Invalid response format received from the server.',
        );
      }

      // Check HTTP status code and response flags
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['ok'] != true) {
        final message = decoded['message'];

        if (response.statusCode == 401) {
          throw const AttendanceException(
            'Your session may have expired. Please log in again.',
          );
        }

        if (response.statusCode == 403) {
          throw const AttendanceException(
            'You do not have permission to access attendance features.',
          );
        }

        if (message is String && message.trim().isNotEmpty) {
          throw AttendanceException(message);
        }

        throw AttendanceException(
          'Attendance request failed (HTTP ${response.statusCode}).',
        );
      }

      return decoded;
    } on AttendanceException {
      rethrow;
    } on TimeoutException {
      throw const AttendanceException(
        'Server is taking too long to respond. Please try again.',
      );
    } on SocketException {
      throw const AttendanceException(
        'No internet connection. Please check your network.',
      );
    } on http.ClientException {
      throw const AttendanceException(
        'Could not connect to the server.',
      );
    } on FormatException {
      throw const AttendanceException(
        'Failed to process server response format.',
      );
    }
  }
}