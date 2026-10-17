
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../dashboard/services/dashboard_service.dart';

class ProfileService {
  ProfileService();

  final DashboardService _dashboardService = DashboardService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> getProfile() {
    return _dashboardService.getProfile();
  }

  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    if (!await imageFile.exists()) {
      throw Exception('Selected image file could not be found.');
    }

    final fileSize = await imageFile.length();

    if (fileSize > 2 * 1024 * 1024) {
      throw Exception('Image size must not exceed 2 MB.');
    }

    final extension =
    imageFile.path.split('.').last.toLowerCase();

    final MediaType contentType;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = MediaType('image', 'jpeg');
        break;
      case 'png':
        contentType = MediaType('image', 'png');
        break;
      case 'webp':
        contentType = MediaType('image', 'webp');
        break;
      default:
        throw Exception('Choose a JPG, PNG, or WEBP image.');
    }

    final storedToken = await _storage.read(key: 'auth_token');

    if (storedToken == null || storedToken.trim().isEmpty) {
      throw Exception('Session token not found. Please log in again.');
    }

    final token = storedToken.startsWith('Bearer ')
        ? storedToken
        : 'Bearer $storedToken';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://portal.gopangitsolution.com/api/profile/avatar',
      ),
    );

    request.headers.addAll({
      'Authorization': token,
      'Accept': 'application/json',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
        contentType: contentType,
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final responseBody = await streamedResponse.stream.bytesToString();

    Map<String, dynamic> responseData;

    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is! Map) {
        throw const FormatException('Unexpected response format.');
      }

      responseData = Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw Exception(
        'Avatar API returned an unreadable response '
            '(HTTP ${streamedResponse.statusCode}).',
      );
    }

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300 ||
        responseData['ok'] != true) {
      throw Exception(
        responseData['message']?.toString() ??
            'Avatar upload failed (HTTP ${streamedResponse.statusCode}).',
      );
    }

    final avatarUrl = responseData['avatar_url']?.toString();

    if (avatarUrl == null || avatarUrl.isEmpty) {
      throw Exception(
        'Upload response did not contain avatar_url.',
      );
    }

    return responseData;
  }
}
