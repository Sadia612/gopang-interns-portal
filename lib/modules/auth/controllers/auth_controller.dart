
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../../../app/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoading = false.obs;
  final loggedInUser = Rxn<Map<String, dynamic>>();

  Future<void> login({
    required String email,
    required String password,
    required GlobalKey<FormState> formKey,
  }) async {
    if (isLoading.value) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isLoading.value = true;

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      final user = response['user'];

      if (user is! Map<String, dynamic>) {
        await _authService.clearSession();

        throw const AuthException(
          'User information was not found in the login response.',
        );
      }

      // Save actual user information from the API response.
      loggedInUser.value = user;

      Get.snackbar(
        'Login successful',
        'Welcome back${user['name'] is String ? ', ${user['name']}' : ''}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
        margin: const EdgeInsets.all(16),
      );

      // Open dashboard and remove login screen from the route stack.
      Get.offAllNamed(AppRoutes.dashboard);
    } on AuthException catch (error) {
      Get.snackbar(
        'Sign in failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'Unexpected Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.clearSession();

    loggedInUser.value = null;

    Get.offAllNamed(AppRoutes.login);
  }
}
