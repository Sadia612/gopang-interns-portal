import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  runApp(const GopangInternsPortal());
}

class GopangInternsPortal extends StatelessWidget {
  const GopangInternsPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gopang Interns Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}