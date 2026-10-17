import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Exception thrown for authentication service errors and network failures.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Service handling user authentication network requests, session storage, and tokens.
class AuthService {
  static const String _baseUrl = 'https://portal.gopangitsolution.com';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const Duration _requestTimeout = Duration(seconds: 20);

  /// Authenticates a user with email and password, returning account details and saving credentials.
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
          .timeout(_requestTimeout);

      final decoded = _decodeResponse(response.body);

      // Validate HTTP status code and response success flags
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['ok'] == true) {
        final token = decoded['token'];

        if (token is! String || token.isEmpty) {
          throw const AuthException(
            'Unable to sign in. Please try again.',
          );
        }

        // Store authentication token securely
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
        } else {
          await _secureStorage.delete(
            key: 'auth_token_expires_at',
          );
        }

        return decoded;
      }

      if (response.statusCode == 401) {
        throw const AuthException(
          'Invalid email or password.',
        );
      }

      if (response.statusCode == 403) {
        throw const AuthException(
          'You are not authorized to access this account.',
        );
      }

      final message = decoded['message'];

      if (message is String && message.trim().isNotEmpty) {
        throw AuthException(message.trim());
      }

      throw const AuthException(
        'Unable to sign in. Please try again.',
      );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw const AuthException(
        'The request timed out. Please try again.',
      );
    } on SocketException {
      throw const AuthException(
        'Unable to connect. Check your internet connection.',
      );
    } on http.ClientException {
      throw const AuthException(
        'A connection error occurred. Please try again.',
      );
    } on FormatException {
      throw const AuthException(
        'Unable to process the response. Please try again.',
      );
    }
  }

  /// Revokes the current session token on the authentication server.
  Future<void> logout() async {
    final token = await getSavedToken();

    if (token == null || token.isEmpty) {
      throw const AuthException(
        'Your session has expired. Please sign in again.',
      );
    }

    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/api/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(_requestTimeout);

      final decoded = _decodeResponse(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['ok'] == true) {
        return;
      }

      final message = decoded['message'];

      if (message is String && message.trim().isNotEmpty) {
        throw AuthException(message.trim());
      }

      throw const AuthException(
        'Unable to sign out. Please try again.',
      );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw const AuthException(
        'The request timed out. Please try again.',
      );
    } on SocketException {
      throw const AuthException(
        'Unable to connect. Check your internet connection.',
      );
    } on http.ClientException {
      throw const AuthException(
        'A connection error occurred. Please try again.',
      );
    } on FormatException {
      throw const AuthException(
        'Unable to complete the request. Please try again.',
      );
    }
  }

  /// Parses JSON response strings into a structured dynamic map.
  Map<String, dynamic> _decodeResponse(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      throw const AuthException(
        'Unable to process the response. Please try again.',
      );
    }

    throw const AuthException(
      'Unable to process the response. Please try again.',
    );
  }

  /// Removes saved session credentials and tokens from secure storage.
  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'auth_token_expires_at');
  }

  /// Reads the stored authentication token from secure storage.
  Future<String?> getSavedToken() async {
    return _secureStorage.read(key: 'auth_token');
  }
}