
import 'package:get/get.dart';

import '../../modules/splash/views/splash_view.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/attendance/views/attendance_view.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/tasks/views/tasks_view.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const attendance = '/attendance';
  static const reports = '/reports';
  static const notifications = '/notifications';
  static const tasks = '/tasks';

  static final pages = <GetPage>[
    GetPage(
      name: splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardView(),
    ),
    GetPage(
      name: attendance,
      page: () => const AttendanceView(),
    ),
    GetPage(
      name: reports,
      page: () => ReportsView(),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsView(),
    ),
    GetPage(
      name: tasks,
      page: () => const TasksView(),
    ),
  ];
}
