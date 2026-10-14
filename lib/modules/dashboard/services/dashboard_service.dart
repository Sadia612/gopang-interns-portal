
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DashboardApiException implements Exception {
  const DashboardApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DashboardService {
  static const String _baseUrl =
      'https://portal.gopangitsolution.com';

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  Future<Map<String, dynamic>> _sendRequest(
      String method,
      String path, {
        Map<String, dynamic>? body,
      }) async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) {
      throw const DashboardApiException(
        'Your session has expired. Please sign in again.',
      );
    }

    final uri = Uri.parse('$_baseUrl$path');

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
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 20));
          break;

        case 'POST':
          response = await http
              .post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
              .timeout(const Duration(seconds: 20));
          break;

        case 'PUT':
          response = await http
              .put(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
              .timeout(const Duration(seconds: 20));
          break;

        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 20));
          break;

        default:
          throw const DashboardApiException(
            'Unsupported request method.',
          );
      }

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw const DashboardApiException(
          'The server returned an invalid response.',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw const DashboardApiException(
          'The server response format is invalid.',
        );
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['ok'] == true) {
        return decoded;
      }

      if (response.statusCode == 401) {
        throw const DashboardApiException(
          'Your session has expired. Please sign in again.',
        );
      }

      final message = decoded['message'];

      if (message is String && message.trim().isNotEmpty) {
        throw DashboardApiException(message);
      }

      throw DashboardApiException(
        'Request failed (HTTP ${response.statusCode}).',
      );
    } on DashboardApiException {
      rethrow;
    } on TimeoutException {
      throw const DashboardApiException(
        'The server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw const DashboardApiException(
        'Unable to connect. Please check your internet connection.',
      );
    } on http.ClientException {
      throw const DashboardApiException(
        'Could not connect to the server.',
      );
    }
  }

  String _withQuery(
      String path,
      Map<String, String?> parameters,
      ) {
    final query = <String, String>{};

    parameters.forEach((key, value) {
      if (value != null && value.trim().isNotEmpty) {
        query[key] = value;
      }
    });

    if (query.isEmpty) return path;

    return '$path?${Uri(queryParameters: query).query}';
  }

  // Dashboard

  Future<Map<String, dynamic>> getDashboard() {
    return _sendRequest('GET', '/api/dashboard');
  }

  // Profile

  Future<Map<String, dynamic>> getMe() {
    return _sendRequest('GET', '/api/me');
  }

  Future<Map<String, dynamic>> getProfile() {
    return _sendRequest('GET', '/api/profile');
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data,
      ) {
    return _sendRequest(
      'PUT',
      '/api/profile',
      body: data,
    );
  }

  // Attendance

  Future<Map<String, dynamic>> getAttendanceStatus() {
    return _sendRequest(
      'GET',
      '/api/attendance/status',
    );
  }

  Future<Map<String, dynamic>> checkIn() {
    return _sendRequest(
      'POST',
      '/api/attendance/check-in',
    );
  }

  Future<Map<String, dynamic>> checkOut() {
    return _sendRequest(
      'POST',
      '/api/attendance/check-out',
    );
  }

  Future<Map<String, dynamic>> startBreak() {
    return _sendRequest(
      'POST',
      '/api/attendance/break-start',
    );
  }

  Future<Map<String, dynamic>> endBreak() {
    return _sendRequest(
      'POST',
      '/api/attendance/break-end',
    );
  }

  Future<Map<String, dynamic>> getAttendanceHistory({
    String? range,
    String? from,
    String? to,
    String? status,
    int page = 1,
  }) {
    final path = _withQuery(
      '/api/attendance',
      {
        'range': range,
        'from': from,
        'to': to,
        'status': status,
        'page': page.toString(),
      },
    );

    return _sendRequest('GET', path);
  }

  // Reports

  Future<Map<String, dynamic>> getReports({
    String? status,
    String? search,
    String? from,
    String? to,
    int page = 1,
  }) {
    final path = _withQuery(
      '/api/reports',
      {
        'status': status,
        'search': search,
        'from': from,
        'to': to,
        'page': page.toString(),
      },
    );

    return _sendRequest('GET', path);
  }

  Future<Map<String, dynamic>> getReportDetails(
      int reportId,
      ) {
    return _sendRequest(
      'GET',
      '/api/reports/$reportId',
    );
  }

  Future<Map<String, dynamic>> createReport(
      Map<String, dynamic> data,
      ) {
    return _sendRequest(
      'POST',
      '/api/reports',
      body: data,
    );
  }

  Future<Map<String, dynamic>> updateReport(
      int reportId,
      Map<String, dynamic> data,
      ) {
    return _sendRequest(
      'PUT',
      '/api/reports/$reportId',
      body: data,
    );
  }

  Future<Map<String, dynamic>> deleteReport(
      int reportId,
      ) {
    return _sendRequest(
      'DELETE',
      '/api/reports/$reportId',
    );
  }

  // Tasks

  Future<Map<String, dynamic>> getTasks() {
    return _sendRequest('GET', '/api/tasks');
  }

  Future<Map<String, dynamic>> updateTaskStatus(
      int taskId,
      Map<String, dynamic> data,
      ) {
    return _sendRequest(
      'POST',
      '/api/tasks/$taskId/status',
      body: data,
    );
  }

  // Notifications

  Future<Map<String, dynamic>> getNotificationFeed() {
    return _sendRequest(
      'GET',
      '/api/notifications/feed',
    );
  }

  Future<Map<String, dynamic>> getNotifications({
    bool unreadOnly = false,
    int page = 1,
  }) {
    final path = _withQuery(
      '/api/notifications',
      {
        'unread_only': unreadOnly.toString(),
        'page': page.toString(),
      },
    );

    return _sendRequest('GET', path);
  }

  Future<Map<String, dynamic>> markNotificationRead(
      int notificationId,
      ) {
    return _sendRequest(
      'POST',
      '/api/notifications/$notificationId/read',
    );
  }

  Future<Map<String, dynamic>> markAllNotificationsRead() {
    return _sendRequest(
      'POST',
      '/api/notifications/read-all',
    );
  }

  // Logout

  Future<Map<String, dynamic>> logoutFromServer() {
    return _sendRequest(
      'POST',
      '/api/logout',
    );
  }
}
