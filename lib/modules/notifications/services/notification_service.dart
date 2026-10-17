import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/app_notification.dart';

class NotificationException implements Exception {
  const NotificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NotificationService {
  static const String _baseUrl = 'https://portal.gopangitsolution.com';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const Duration _timeout = Duration(seconds: 20);

  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Map<String, String>? query,
  }) async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.trim().isEmpty) {
      throw const NotificationException(
        'Your session has expired. Please log in again.',
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

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers).timeout(_timeout);
          break;
        default:
          throw const NotificationException('Unsupported HTTP method.');
      }

      final dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw const NotificationException(
          'The server returned an invalid response.',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw const NotificationException(
          'Invalid notification response received.',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['ok'] != true) {
        if (response.statusCode == 401) {
          throw const NotificationException(
            'Your session has expired. Please log in again.',
          );
        }

        final message = decoded['message'];
        throw NotificationException(
          message is String && message.isNotEmpty
              ? message
              : 'Notification request failed (HTTP ${response.statusCode}).',
        );
      }

      return decoded;
    } on NotificationException {
      rethrow;
    } on TimeoutException {
      throw const NotificationException(
        'The server took too long to respond. Please retry.',
      );
    } on SocketException {
      throw const NotificationException(
        'No internet connection. Please check your network.',
      );
    } on http.ClientException {
      throw const NotificationException(
        'Could not connect to the notification service.',
      );
    }
  }

  Future<List<AppNotification>> getNotifications({
    int page = 1,
    bool unreadOnly = false,
  }) async {
    final response = await _request(
      method: 'GET',
      path: '/api/notifications',
      query: {
        'unread_only': unreadOnly.toString(),
        'page': page.toString(),
      },
    );

    final payload = response['notifications'];
    if (payload is! Map) {
      throw const NotificationException(
        'The server did not return a notification list.',
      );
    }

    final data = payload['data'];
    if (data is! List) {
      throw const NotificationException(
        'The server returned an invalid notification list.',
      );
    }

    return data
        .whereType<Map>()
        .map(
          (item) => AppNotification.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _request(
      method: 'GET',
      path: '/api/notifications/feed',
    );

    final unread = response['unread'];
    if (unread is int) return unread;
    if (unread is num) return unread.toInt();

    return int.tryParse(unread?.toString() ?? '') ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _request(
      method: 'POST',
      path: '/api/notifications/$id/read',
    );
  }

  Future<void> markAllAsRead() async {
    await _request(
      method: 'POST',
      path: '/api/notifications/read-all',
    );
  }
}