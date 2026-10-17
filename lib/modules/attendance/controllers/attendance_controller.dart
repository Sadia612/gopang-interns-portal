import 'package:get/get.dart';

import '../services/attendance_service.dart';
import '../../notifications/controllers/notifications_controller.dart';

/// GetX Controller for managing attendance status, history, and actions.
class AttendanceController extends GetxController {
  final AttendanceService _service = AttendanceService();

  // Observable state flags
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isActionLoading = false.obs;
  final isHistoryLoading = false.obs;

  // Observable state response data holders
  final statusData = Rxn<Map<String, dynamic>>();
  final historyData = Rxn<Map<String, dynamic>>();

  // Observable error message states
  final errorMessage = RxnString();
  final historyError = RxnString();

  // Pagination and filter states
  final selectedRange = 'month'.obs;
  final selectedStatus = 'all'.obs;
  final currentPage = 1.obs;

  /// Returns today's attendance summary map from status data.
  Map<String, dynamic>? get today {
    final data = statusData.value?['today'];

    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// Returns today's detailed attendance record.
  Map<String, dynamic>? get record {
    final data = today?['record'];

    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// Returns the paginated history data map.
  Map<String, dynamic>? get attendancePage {
    final data = historyData.value?['attendances'];

    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// Returns a structured list of attendance history items.
  List<Map<String, dynamic>> get attendanceRecords {
    final data = attendancePage?['data'];

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Returns the overall attendance history summary.
  Map<String, dynamic>? get summary {
    final data = historyData.value?['summary'];

    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  // Attendance status getters
  bool get checkedIn => today?['checked_in'] == true;
  bool get checkedOut => today?['checked_out'] == true;
  bool get onBreak => today?['on_break'] == true;
  bool get completed => today?['completed'] == true;
  bool get isLate => today?['is_late'] == true;

  // Duration and progress metrics getters
  int? get workedMinutes => _intValue(today?['minutes']);
  int? get remainingMinutes => _intValue(today?['remaining_minutes']);
  int? get progress => _intValue(today?['progress']);

  /// Safely converts dynamic numeric or string inputs into an integer.
  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Loads both current status and historical records in parallel.
  Future<void> loadInitialData() async {
    await Future.wait([
      loadStatus(),
      loadHistory(),
    ]);
  }

  /// Fetches the user's current attendance status.
  Future<void> loadStatus({bool refresh = false}) async {
    if (isLoading.value || isRefreshing.value) return;

    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    errorMessage.value = null;

    try {
      final response = await _service.getStatus();
      statusData.value = response;
    } on AttendanceException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value =
      'Failed to load attendance status. Please try again.';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Fetches attendance history records according to selected filters and page.
  Future<void> loadHistory({int? page}) async {
    if (isHistoryLoading.value) return;

    isHistoryLoading.value = true;
    historyError.value = null;

    try {
      final response = await _service.getHistory(
        range: selectedRange.value,
        status: selectedStatus.value,
        page: page ?? currentPage.value,
      );

      historyData.value = response;

      final serverPage = _intValue(
        attendancePageFrom(response)?['current_page'],
      );

      currentPage.value = serverPage ?? page ?? currentPage.value;
    } on AttendanceException catch (error) {
      historyError.value = error.message;
    } catch (_) {
      historyError.value = 'Failed to load attendance history.';
    } finally {
      isHistoryLoading.value = false;
    }
  }

  /// Helper method to extract the paginated attendance payload.
  Map<String, dynamic>? attendancePageFrom(
      Map<String, dynamic> response,
      ) {
    final data = response['attendances'];

    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// Changes the time range filter and reloads history records.
  Future<void> changeRange(String value) async {
    selectedRange.value = value;
    currentPage.value = 1;
    await loadHistory(page: 1);
  }

  /// Changes the attendance status filter and reloads history records.
  Future<void> changeStatus(String value) async {
    selectedStatus.value = value;
    currentPage.value = 1;
    await loadHistory(page: 1);
  }

  /// Navigates to the previous page of history records if available.
  Future<void> previousPage() async {
    final page = attendancePage;
    if (page == null || isHistoryLoading.value) return;

    final previous = page['prev_page_url'];

    if (previous == null) return;

    await loadHistory(page: currentPage.value - 1);
  }

  /// Navigates to the next page of history records if available.
  Future<void> nextPage() async {
    final page = attendancePage;
    if (page == null || isHistoryLoading.value) return;

    final next = page['next_page_url'];

    if (next == null) return;

    await loadHistory(page: currentPage.value + 1);
  }

  /// Performs user check-in action.
  Future<void> checkIn() async {
    if (checkedIn || isActionLoading.value) return;

    await _performAction(
      action: _service.checkIn,
      successMessage: 'Check-in successful.',
      onSuccess: _addCheckInNotification,
    );
  }

  /// Performs user check-out action.
  Future<void> checkOut() async {
    if (!checkedIn ||
        checkedOut ||
        onBreak ||
        isActionLoading.value) {
      return;
    }

    await _performAction(
      action: _service.checkOut,
      successMessage: 'Check-out successful.',
    );
  }

  /// Performs start break action.
  Future<void> startBreak() async {
    if (!checkedIn ||
        checkedOut ||
        onBreak ||
        isActionLoading.value) {
      return;
    }

    await _performAction(
      action: _service.startBreak,
      successMessage: 'Break started successfully.',
      onSuccess: () async {
        final controller = Get.isRegistered<NotificationsController>()
            ? Get.find<NotificationsController>()
            : Get.put(NotificationsController());

        await controller.loadNotifications();
        await controller.refreshNotifications();
      },
    );
  }

  /// Performs end break action.
  Future<void> endBreak() async {
    if (!onBreak || isActionLoading.value) return;

    await _performAction(
      action: _service.endBreak,
      successMessage: 'Break ended successfully.',
      onSuccess: () async {
        final controller = Get.isRegistered<NotificationsController>()
            ? Get.find<NotificationsController>()
            : Get.put(NotificationsController());

        await controller.loadNotifications();
        await controller.refreshNotifications();
      },
    );
  }

  /// Triggers notification refresh after check-in.
  Future<void> _addCheckInNotification() async {
    final attendanceRecord = record;
    final todayData = today;

    final recordStatus =
    attendanceRecord?['status']?.toString().toLowerCase();

    final late = attendanceRecord?['is_late'] == true ||
        todayData?['is_late'] == true ||
        recordStatus == 'late';

    final lateMinutes = _intValue(
      attendanceRecord?['late_minutes'],
    ) ??
        _intValue(todayData?['late_minutes']) ??
        0;

    final rawCheckInTime = attendanceRecord?['check_in'] ??
        attendanceRecord?['check_in_time'] ??
        todayData?['check_in'];

    final checkInTime = _formatNotificationTime(rawCheckInTime);

    final notificationsController =
    Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController());

    await notificationsController.loadNotifications();
    await notificationsController.refreshNotifications();
  }

  /// Formats raw time string into a 12-hour display string.
  String _formatNotificationTime(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Time unavailable';
    }

    final rawValue = value.toString();
    final parsed = DateTime.tryParse(rawValue);

    if (parsed == null) return rawValue;

    final time = parsed.toLocal();
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  /// Helper method to execute attendance action calls and refresh state.
  Future<void> _performAction({
    required Future<Map<String, dynamic>> Function() action,
    required String successMessage,
    Future<void> Function()? onSuccess,
  }) async {
    if (isActionLoading.value) return;

    isActionLoading.value = true;

    try {
      await action();

      Get.snackbar(
        'Attendance Updated',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

      await Future.wait([
        loadStatus(),
        loadHistory(page: 1),
      ]);

      if (onSuccess != null) {
        await onSuccess();
      }
    } on AttendanceException catch (error) {
      Get.snackbar(
        'Action Failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Unable to complete the action. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActionLoading.value = false;
    }
  }
}