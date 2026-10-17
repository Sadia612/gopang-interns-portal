import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final isDarkMode = false.obs;

  void toggleTheme(bool enabled) {
    isDarkMode.value = enabled;

    Get.changeThemeMode(
      enabled ? ThemeMode.dark : ThemeMode.light,
    );
  }
}