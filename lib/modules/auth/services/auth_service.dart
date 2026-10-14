
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const String _baseUrl = 'https://portal.gopangitsolution.com';

  static const FlutterSecureStorage _secureStorage =
  FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/api/login'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 20));

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw const AuthException(
          'Server ne unexpected response bheja. Please try again.',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw const AuthException(
          'Server response ka format valid nahi hai.',
        );
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['ok'] == true) {
        final token = decoded['token'];

        if (token is! String || token.isEmpty) {
          throw const AuthException(
            'Login response mein access token nahi mila.',
          );
        }

        await _secureStorage.write(
          key: 'auth_token',
          value: token,
        );

        final expiresAt = decoded['expires_at'];

        if (expiresAt is String) {
          await _secureStorage.write(
            key: 'auth_token_expires_at',
            value: expiresAt,
          );
        }

        return decoded;
      }

      final message = decoded['message'];

      if (message is String && message.trim().isNotEmpty) {
        throw AuthException(message);
      }

      if (response.statusCode == 401) {
        throw const AuthException(
          'Email ya password sahi nahi hai.',
        );
      }

      if (response.statusCode == 403) {
        throw const AuthException(
          'Aapko access nahi diya gaya. Company se contact karein.',
        );
      }

      throw AuthException(
        'Login failed (HTTP ${response.statusCode}). Please try again.',
      );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw const AuthException(
        'Server response mein time lag raha hai. Dobara try karein.',
      );
    } on SocketException {
      throw const AuthException(
        'Internet connection check karein.',
      );
    } on http.ClientException {
      throw const AuthException(
        'Server se connection nahi ho saka.',
      );
    } on FormatException {
      throw const AuthException(
        'Server response process nahi ho saka.',
      );
    }
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'auth_token_expires_at');
  }

  Future<String?> getSavedToken() async {
    return _secureStorage.read(key: 'auth_token');
  }
}
