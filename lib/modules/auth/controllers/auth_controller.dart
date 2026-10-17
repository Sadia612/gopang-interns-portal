import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../../../app/app_routes.dart';

/// GetX Controller managing user authentication state, sign-in, and sign-out flows.
class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Observable state flags
  final isLoading = false.obs;
  final isLoggingOut = false.obs;
  final loggedInUser = Rxn<Map<String, dynamic>>();

  /// Handles user sign-in validation, request execution, and route navigation.
  Future<void> login({
    required String email,
    required String password,
    required GlobalKey<FormState> formKey,
  }) async {
    if (isLoading.value || isLoggingOut.value) return;

    // Dismiss active keyboard input
    FocusManager.instance.primaryFocus?.unfocus();

    // Validate form inputs before proceeding
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
          'Unable to sign in. Please try again.',
        );
      }

      loggedInUser.value = user;

      Get.snackbar(
        'Welcome',
        'Welcome back${user['name'] is String ? ', ${user['name']}' : ''}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
        margin: const EdgeInsets.all(16),
      );

      // Navigate to main application dashboard
      Get.offAllNamed(AppRoutes.dashboard);
    } on AuthException catch (error) {
      Get.snackbar(
        'Sign In Failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'Unable to Sign In',
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

  /// Handles user sign-out, session cleanup, and redirection to the login view.
  Future<void> logout() async {
    if (isLoggingOut.value) return;

    isLoggingOut.value = true;

    String? errorMessage;

    try {
      await _authService.logout();
    } on AuthException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Unable to complete sign out. Please try again.';
    }

    try {
      await _authService.clearSession();
    } catch (_) {
      errorMessage = 'Unable to clear your session. Please try again.';
    }

    loggedInUser.value = null;
    isLoading.value = false;

    try {
      // Redirect user back to the authentication screen
      await Get.offAllNamed(AppRoutes.login);

      if (errorMessage != null) {
        Get.snackbar(
          'Sign Out',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          'Signed Out',
          'You have successfully signed out.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      }
    } finally {
      isLoggingOut.value = false;
    }
  }
}