
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/dashboard_service.dart';

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

List<dynamic> _toList(dynamic value) {
  if (value is List) {
    return value;
  }

  final map = _toMap(value);

  if (map != null && map['data'] is List) {
    return map['data'] as List<dynamic>;
  }

  return [];
}

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();

  final dashboard = Rxn<Map<String, dynamic>>();
  final attendance = Rxn<Map<String, dynamic>>();

  final isLoading = false.obs;
  final isActionLoading = false.obs;
  final errorMessage = ''.obs;

  // Attendance history
  final attendanceHistory = <dynamic>[].obs;
  final isAttendanceHistoryLoading = false.obs;
  final attendanceHistoryError = ''.obs;
  final attendanceHistoryPage = 1.obs;
  final attendanceHistoryTotal = 0.obs;

  // Summary returned by the attendance history API.
  // Kept separate from the dashboard summary and live status.
  final attendanceHistorySummary =
  Rxn<Map<String, dynamic>>();

  final reports = <dynamic>[].obs;
  final isReportsLoading = false.obs;
  final reportsError = ''.obs;
  final reportsPage = 1.obs;
  final reportsTotal = 0.obs;

  final profile = Rxn<Map<String, dynamic>>();
  final isProfileLoading = false.obs;
  final profileError = ''.obs;

  final notifications = <dynamic>[].obs;
  final isNotificationsLoading = false.obs;
  final notificationsError = ''.obs;
  final unreadNotificationsCount = 0.obs;
  final notificationsPage = 1.obs;

  final tasks = <dynamic>[].obs;
  final isTasksLoading = false.obs;
  final tasksError = ''.obs;

  Map<String, dynamic> get user =>
      _toMap(dashboard.value?['user']) ?? {};

  Map<String, dynamic> get employee =>
      _toMap(user['employee']) ?? {};

  Map<String, dynamic> get summary =>
      _toMap(dashboard.value?['summary']) ?? {};

  // Live attendance status from GET /api/attendance/status.
  Map<String, dynamic> get today =>
      attendance.value ??
          _toMap(summary['today']) ??
          <String, dynamic>{};

  Map<String, dynamic> get week =>
      _toMap(summary['week']) ?? {};

  Map<String, dynamic> get month =>
      _toMap(summary['month']) ?? {};

  // History endpoint summary from GET /api/attendance.
  Map<String, dynamic> get historySummary =>
      attendanceHistorySummary.value ?? {};

  Map<String, dynamic> get historyToday =>
      _toMap(historySummary['today']) ?? {};

  Map<String, dynamic> get historyWeek =>
      _toMap(historySummary['week']) ?? {};

  Map<String, dynamic> get historyMonth =>
      _toMap(historySummary['month']) ?? {};

  List<dynamic> get dailyHours =>
      _toMap(dashboard.value?['daily_hours'])?['hours']
      as List<dynamic>? ??
          [];

  List<dynamic> get dailyLabels =>
      _toMap(dashboard.value?['daily_hours'])?['labels']
      as List<dynamic>? ??
          [];

  List<dynamic> get recentReports =>
      _toList(dashboard.value?['recent_reports']);

  bool get isCheckedIn => today['checked_in'] == true;

  bool get isCheckedOut => today['checked_out'] == true;

  bool get isOnBreak => today['on_break'] == true;

  bool get isAttendanceCompleted => today['completed'] == true;

  int get remainingMinutes =>
      _toInt(today['remaining_minutes']);

  int get workedMinutes =>
      _toInt(today['minutes'] ?? today['worked_minutes']);

  int get lateMinutes => _toInt(today['late_minutes']);

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard({
    bool showLoading = true,
  }) async {
    if (showLoading) {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      final response = await _service.getDashboard();
      dashboard.value = response;

      try {
        await refreshAttendanceStatus();
      } catch (error) {
        errorMessage.value = error.toString();
      }
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  Future<void> refreshAttendanceStatus() async {
    final response = await _service.getAttendanceStatus();

    attendance.value =
        _toMap(response['today']) ??
            _toMap(response['attendance']) ??
            response;
  }

  Future<void> checkIn() async {
    if (isActionLoading.value || isCheckedIn) {
      return;
    }

    await _performAttendanceAction(isCheckIn: true);
  }

  Future<void> checkOut() async {
    if (isActionLoading.value ||
        !isCheckedIn ||
        isCheckedOut ||
        isOnBreak) {
      return;
    }

    await _performAttendanceAction(isCheckIn: false);
  }

  Future<void> _performAttendanceAction({
    required bool isCheckIn,
  }) async {
    isActionLoading.value = true;

    try {
      final response = isCheckIn
          ? await _service.checkIn()
          : await _service.checkOut();

      attendance.value =
          _toMap(response['today']) ??
              _toMap(response['attendance']) ??
              _toMap(response['summary']) ??
              attendance.value;

      final message = response['message'];

      Get.snackbar(
        isCheckIn ? 'Check-in successful' : 'Check-out successful',
        message is String && message.isNotEmpty
            ? message
            : 'Attendance updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
        margin: const EdgeInsets.all(16),
      );

      await loadDashboard(showLoading: false);
    } catch (error) {
      Get.snackbar(
        'Attendance action failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> startBreak() async {
    if (isActionLoading.value ||
        !isCheckedIn ||
        isCheckedOut ||
        isOnBreak) {
      return;
    }

    await _performBreakAction(start: true);
  }

  Future<void> endBreak() async {
    if (isActionLoading.value || !isOnBreak) {
      return;
    }

    await _performBreakAction(start: false);
  }

  Future<void> _performBreakAction({
    required bool start,
  }) async {
    isActionLoading.value = true;

    try {
      final response = start
          ? await _service.startBreak()
          : await _service.endBreak();

      attendance.value =
          _toMap(response['today']) ??
              _toMap(response['attendance']) ??
              attendance.value;

      Get.snackbar(
        start ? 'Break started' : 'Break resumed',
        response['message'] is String
            ? response['message'] as String
            : start
            ? 'Your break has started.'
            : 'Your working session has resumed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDBEAFE),
        colorText: const Color(0xFF1E40AF),
        margin: const EdgeInsets.all(16),
      );

      await loadDashboard(showLoading: false);
    } catch (error) {
      Get.snackbar(
        'Break action failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> loadAttendanceHistory({
    String? range,
    String? from,
    String? to,
    String? status,
    int page = 1,
  }) async {
    isAttendanceHistoryLoading.value = true;
    attendanceHistoryError.value = '';

    try {
      final response = await _service.getAttendanceHistory(
        range: range,
        from: from,
        to: to,
        status: status,
        page: page,
      );

      // Keep history summary separate from live attendance status.
      attendanceHistorySummary.value =
          _toMap(response['summary']);

      final attendanceData = response['attendances'];
      final receivedRecords = _toList(attendanceData);

      attendanceHistory.assignAll(receivedRecords);

      final pagination = _toMap(attendanceData);

      attendanceHistoryPage.value = _toInt(
        pagination?['current_page'] ?? page,
      );

      attendanceHistoryTotal.value = _toInt(
        pagination?['total'],
      );
    } catch (error) {
      attendanceHistoryError.value = error.toString();
    } finally {
      isAttendanceHistoryLoading.value = false;
    }
  }

  Future<void> loadReports({
    String? status,
    String? search,
    String? from,
    String? to,
    int page = 1,
  }) async {
    isReportsLoading.value = true;
    reportsError.value = '';

    try {
      final response = await _service.getReports(
        status: status,
        search: search,
        from: from,
        to: to,
        page: page,
      );

      final reportData = response['reports'];

      reports.assignAll(_toList(reportData));

      final pagination = _toMap(reportData);

      reportsPage.value = _toInt(
        pagination?['current_page'] ?? page,
      );

      reportsTotal.value = _toInt(pagination?['total']);
    } catch (error) {
      reportsError.value = error.toString();
    } finally {
      isReportsLoading.value = false;
    }
  }

  Future<void> loadProfile() async {
    isProfileLoading.value = true;
    profileError.value = '';

    try {
      final response = await _service.getProfile();

      profile.value =
          _toMap(response['user']) ??
              _toMap(response['profile']) ??
              response;
    } catch (error) {
      profileError.value = error.toString();
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> loadNotifications({
    bool unreadOnly = false,
    int page = 1,
  }) async {
    isNotificationsLoading.value = true;
    notificationsError.value = '';

    try {
      final response = await _service.getNotifications(
        unreadOnly: unreadOnly,
        page: page,
      );

      final notificationData = response['notifications'];

      notifications.assignAll(_toList(notificationData));

      final pagination = _toMap(notificationData);

      notificationsPage.value = _toInt(
        pagination?['current_page'] ?? page,
      );

      if (unreadOnly) {
        unreadNotificationsCount.value =
            _toList(notificationData).length;
      } else {
        unreadNotificationsCount.value =
            notifications.where((item) {
              final notification = _toMap(item) ?? {};
              return notification['read_at'] == null;
            }).length;
      }
    } catch (error) {
      notificationsError.value = error.toString();
    } finally {
      isNotificationsLoading.value = false;
    }
  }

  Future<void> markNotificationRead(
      int notificationId,
      ) async {
    try {
      await _service.markNotificationRead(notificationId);
      await loadNotifications();
    } catch (error) {
      Get.snackbar(
        'Could not update notification',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _service.markAllNotificationsRead();
      await loadNotifications();
    } catch (error) {
      Get.snackbar(
        'Could not update notifications',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadTasks() async {
    isTasksLoading.value = true;
    tasksError.value = '';

    try {
      final response = await _service.getTasks();
      tasks.assignAll(_toList(response['tasks']));
    } catch (error) {
      tasksError.value = error.toString();
    } finally {
      isTasksLoading.value = false;
    }
  }

  Future<void> updateTaskStatus(
      int taskId,
      Map<String, dynamic> data,
      ) async {
    try {
      await _service.updateTaskStatus(taskId, data);
      await loadTasks();
    } catch (error) {
      Get.snackbar(
        'Could not update task',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
