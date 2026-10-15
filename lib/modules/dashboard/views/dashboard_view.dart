
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/dashboard_controller.dart';
import '../../../app/app_routes.dart';
import '../../profile/views/profile_view.dart';

class DashboardView extends StatefulWidget {
const DashboardView({super.key});

@override
State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
final DashboardController controller = Get.put(DashboardController());

int selectedIndex = 0;

final List<String> titles = const [
'Home',
'Attendance',
'Reports',
'Profile',
];

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppTheme.background,
drawer: _buildDrawer(context),
appBar: AppBar(
backgroundColor: AppTheme.surface,
surfaceTintColor: Colors.transparent,
elevation: 0,
titleSpacing: 8,
leading: Builder(
builder: (context) => IconButton(
tooltip: 'Open menu',
onPressed: () => Scaffold.of(context).openDrawer(),
icon: const Icon(
Icons.menu_rounded,
color: AppTheme.primary,
),
),
),
title: Row(
children: [
Container(
height: 38,
width: 38,
padding: const EdgeInsets.all(4),
decoration: BoxDecoration(
color: AppTheme.blueLight,
borderRadius: BorderRadius.circular(12),
),
child: Image.asset(
'assets/images/gopang_logo.png',
fit: BoxFit.contain,
errorBuilder: (_, _, _) => const Icon(
Icons.business_rounded,
color: AppTheme.primary,
),
),
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Gopang Interns Portal',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.w800,
color: AppTheme.primary,
),
),
Text(
titles[selectedIndex].toUpperCase(),
style: const TextStyle(
fontSize: 9,
fontWeight: FontWeight.w700,
letterSpacing: 1.5,
color: AppTheme.mediumBlue,
),
),
],
),
),
],
),
actions: const [],
),

  body: IndexedStack(
    index: selectedIndex,
    children: [
      _buildHome(),
      _buildAttendance(),
      _buildReports(),
    ],
  ),

bottomNavigationBar: Container(
decoration: BoxDecoration(
color: AppTheme.surface,
border: const Border(
top: BorderSide(color: AppTheme.border),
),
boxShadow: [
BoxShadow(
color: AppTheme.primary.withValues(alpha: 0.06),
blurRadius: 16,
offset: const Offset(0, -4),
),
],
),
child: SafeArea(
top: false,
child: NavigationBar(
height: 66,
backgroundColor: AppTheme.surface,
surfaceTintColor: Colors.transparent,
elevation: 0,
selectedIndex: selectedIndex,
onDestinationSelected: _selectTab,
indicatorColor: AppTheme.blueLight,
labelBehavior:
NavigationDestinationLabelBehavior.alwaysShow,
destinations: const [
NavigationDestination(
icon: Icon(Icons.home_outlined),
selectedIcon: Icon(Icons.home_rounded),
label: 'Home',
),
NavigationDestination(
                icon: Icon(Icons.access_time_outlined),
                selectedIcon: Icon(Icons.access_time_filled_rounded),
                label: 'Attendance',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description_rounded),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }




void _selectTab(int index) {
  if (index == 2) {
    Get.toNamed(AppRoutes.reports);
    return;
  }

  if (index == 3) {
    Get.to(() => const ProfileView());
    return;
  }

  setState(() => selectedIndex = index);

  if (index == 1) {
    controller.loadAttendanceHistory(range: 'month');
  }
}


Future<void> _refreshCurrentPage() async {
    switch (selectedIndex) {
      case 0:
        await controller.refreshDashboard();
        break;
      case 1:
        await controller.loadAttendanceHistory(range: 'month');
        break;
      case 2:
        await controller.loadReports();
        break;
      case 3:
        await controller.loadProfile();
        break;
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.brandGradient,
              ),
              child: Obx(() {
                final name =
                    controller.user['name']?.toString() ?? 'Employee';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Image.asset(
                        'assets/images/gopang_logo.png',
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.business_rounded,
                          color: AppTheme.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Gopang IT Solutions',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'INTERNS PORTAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 12),
            _drawerItem(
              icon: Icons.home_rounded,
              title: 'Home',
              selected: selectedIndex == 0,
              onTap: () => _drawerNavigate(context, 0),
            ),
            _drawerItem(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              selected: selectedIndex == 3,
              onTap: () => _drawerNavigate(context, 3),
            ),
            _drawerItem(
              icon: Icons.history_rounded,
              title: 'Attendance History',
              selected: selectedIndex == 1,
              onTap: () => _drawerNavigate(context, 1),
            ),
            _drawerItem(
              icon: Icons.description_outlined,
              title: 'Reports',
              selected: selectedIndex == 2,
              onTap: () => _drawerNavigate(context, 2),
            ),
            _drawerItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                Get.to(
                      () => const _NotificationsPage(),
                  binding: BindingsBuilder(() {
                    Get.lazyPut<DashboardController>(
                          () => controller,
                    );
                  }),
                );
              },
            ),
            _drawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Get.to(
                      () => _SettingsPage(controller: controller),
                );
              },
            ),
            const Spacer(),
            const Divider(color: AppTheme.border),
            _drawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              iconColor: AppTheme.error,
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Logout',
                  'Logout still needs to be connected to the server API through the AuthController.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        selected: selected,
        selectedTileColor: AppTheme.blueLight,
        leading: Icon(
          icon,
          color: iconColor ??
              (selected ? AppTheme.primary : AppTheme.textSecondary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: iconColor ??
                (selected ? AppTheme.primary : AppTheme.textPrimary),
          ),
        ),
        trailing: selected
            ? const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.primary,
        )
            : null,
        onTap: onTap,
      ),
    );
  }

  void _drawerNavigate(BuildContext context, int index) {
    Navigator.pop(context);
    _selectTab(index);
  }

  Widget _buildHome() {
    return Obx(() {
      final data = controller.dashboard.value;

      if (controller.isLoading.value && data == null) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppTheme.mediumBlue,
          ),
        );
      }

      if (data == null) {
        return _errorState(
          message: controller.errorMessage.value.isEmpty
              ? 'Dashboard data could not be loaded.'
              : controller.errorMessage.value,
          onRetry: controller.refreshDashboard,
        );
      }

      final user = controller.user;
      final employee = controller.employee;
      final today = controller.today;
      final week = controller.week;
      final month = controller.month;

      final name = user['name']?.toString() ?? 'Employee';
      final designation =
          employee['designation']?.toString() ?? 'Employee';
      final department =
          employee['department']?.toString() ?? 'Gopang IT Solutions';
      final employeeCode =
          employee['employee_code']?.toString() ?? '';

      final checkedIn = today['checked_in'] == true;
      final checkedOut = today['checked_out'] == true;
      final isLate = today['is_late'] == true;
      final onBreak = today['on_break'] == true;

      final progress = ((today['progress'] as num?) ?? 0)
          .toDouble()
          .clamp(0.0, 100.0) / 100;

      return RefreshIndicator(
        onRefresh: controller.refreshDashboard,
        color: AppTheme.mediumBlue,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_greeting()},',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Ready to make today count?',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _avatar(name, 54),
              ],
            ),
            const SizedBox(height: 22),
            _surfaceCard(
              child: Row(
                children: [
                  _iconBox(Icons.work_outline_rounded, AppTheme.purple),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          designation,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          department,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (employeeCode.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Employee ID: $employeeCode',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppTheme.cyan,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const _SectionHeading(
              title: "Today's attendance",
              subtitle: 'Your working hours at a glance',
              accent: AppTheme.cyan,
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.mediumBlue.withValues(alpha: 0.20),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Text(
                          'TOTAL TIME WORKED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      _statusBadge(
                        onBreak
                            ? 'On break'
                            : checkedOut
                            ? 'Completed'
                            : isLate && checkedIn
                            ? 'Late'
                            : checkedIn
                            ? 'Working'
                            : 'Not checked in',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    today['human']?.toString() ?? '0h 00m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${today['remaining_human'] ?? '6h 00m'} remaining · 6-hour target',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progress * 100).round()}% completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _timeTile(
                          'CHECK-IN',
                          _formatTime(today['check_in']),
                          Icons.login_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _timeTile(
                          'CHECK-OUT',
                          _formatTime(today['check_out']),
                          Icons.logout_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (!checkedIn)
                    _actionButton(
                      label: 'Check in',
                      icon: Icons.login_rounded,
                      loading: controller.isActionLoading.value,
                      onPressed: controller.checkIn,
                    )
                  else if (!checkedOut) ...[
                    _actionButton(
                      label: onBreak ? 'Resume work' : 'Start break',
                      icon: onBreak
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      loading: controller.isActionLoading.value,
                      onPressed: onBreak
                          ? controller.endBreak
                          : controller.startBreak,
                    ),
                    const SizedBox(height: 10),
                    _actionButton(
                      label: 'Check out',
                      icon: Icons.logout_rounded,
                      loading: controller.isActionLoading.value,
                      onPressed: onBreak ? null : controller.checkOut,
                    ),
                  ] else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 9),
                          Text(
                            'Attendance completed',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 27),
            const _SectionHeading(
              title: 'Attendance summary',
              subtitle: 'Your recorded working hours',
              accent: AppTheme.purple,
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    'This week',
                    week['human']?.toString() ?? '—',
                    '${week['days_present'] ?? 0} days present',
                    Icons.date_range_rounded,
                    AppTheme.mediumBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard(
                    'This month',
                    month['human']?.toString() ?? '—',
                    '${month['days_present'] ?? 0} days present',
                    Icons.calendar_month_rounded,
                    AppTheme.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 27),
            const _SectionHeading(
              title: 'Weekly activity',
              subtitle: 'Working hours from the server',
              accent: AppTheme.cyan,
            ),
            const SizedBox(height: 13),
            _weeklyChart(
              controller.dailyLabels,
              controller.dailyHours,
            ),

            const SizedBox(height: 13),

            const SizedBox(height: 26),
            const Center(
              child: Text(
                'Gopang IT Solutions · Interns Portal',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAttendance() {
    return Obx(() {
      final records = controller.attendanceHistory;
      final week = controller.historyWeek;
      final month = controller.historyMonth;

      if (controller.isAttendanceHistoryLoading.value &&
          records.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppTheme.mediumBlue,
          ),
        );
      }

      if (controller.attendanceHistoryError.value.isNotEmpty &&
          records.isEmpty) {
        return _errorState(
          message: controller.attendanceHistoryError.value,
          onRetry: () => controller.loadAttendanceHistory(
            range: 'month',
          ),
        );
      }

      final weeklyHours = week['human']?.toString() ?? '—';
      final monthlyHours = month['human']?.toString() ?? '—';
      final weeklyDays = week['days_present']?.toString() ?? '0';
      final monthlyDays = month['days_present']?.toString() ?? '0';
      final attendancePercent =
      month['attendance_percent']?.toString();

      return RefreshIndicator(
        onRefresh: () => controller.loadAttendanceHistory(
          range: 'month',
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Attendance history',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Your attendance records and working-hour summary from the company server.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Total records returned by the API.
            _surfaceCard(
              child: Row(
                children: [
                  _iconBox(
                    Icons.history_rounded,
                    AppTheme.mediumBlue,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total attendance records',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.attendanceHistoryTotal.value}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh attendance history',
                    onPressed:
                    controller.isAttendanceHistoryLoading.value
                        ? null
                        : () => controller.loadAttendanceHistory(
                      range: 'month',
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const _SectionHeading(
              title: 'Working-hour summary',
              subtitle: 'Summary returned by the attendance history API',
              accent: AppTheme.purple,
            ),
            const SizedBox(height: 13),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _metricCard(
                    'This week',
                    weeklyHours,
                    '$weeklyDays days present',
                    Icons.date_range_rounded,
                    AppTheme.mediumBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard(
                    'This month',
                    monthlyHours,
                    '$monthlyDays days present',
                    Icons.calendar_month_rounded,
                    AppTheme.purple,
                  ),
                ),
              ],
            ),

            if (attendancePercent != null) ...[
              const SizedBox(height: 12),
              _surfaceCard(
                child: Row(
                  children: [
                    _iconBox(
                      Icons.pie_chart_outline_rounded,
                      AppTheme.cyan,
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly attendance',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Percentage reported by the server',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$attendancePercent%',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),

            const _SectionHeading(
              title: 'Attendance records',
              subtitle: 'Records returned by the server for this period',
              accent: AppTheme.cyan,
            ),
            const SizedBox(height: 13),

            if (controller.isAttendanceHistoryLoading.value &&
                records.isNotEmpty) ...[
              const LinearProgressIndicator(
                color: AppTheme.mediumBlue,
                backgroundColor: AppTheme.blueLight,
              ),
              const SizedBox(height: 12),
            ],

            if (records.isEmpty)
              _emptyState(
                Icons.event_busy_rounded,
                'No attendance records',
                'The server returned no attendance records for this period.',
              )
            else
              ...records.map((item) {
                final record = _asMap(item);

                final checkIn = record['check_in'];
                final checkOut = record['check_out'];

                // The API may provide work_date rather than date.
                final recordDate = record['work_date'] ??
                    record['date'] ??
                    record['attendance_date'] ??
                    checkIn;

                final status = record['status']?.toString() ??
                    (checkOut != null ? 'Completed' : 'Incomplete');

                final workedTime = record['human']?.toString() ??
                    record['worked_human']?.toString() ??
                    _minutesText(record['worked_minutes']);

                final lateMinutes = record['late_minutes'];
                final isLate = record['is_late'] == true ||
                    status.toLowerCase().contains('late');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _surfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _iconBox(
                              Icons.calendar_today_rounded,
                              AppTheme.mediumBlue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _formatDate(recordDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            _statusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 17),
                        Row(
                          children: [
                            Expanded(
                              child: _detailLine(
                                'Check-in',
                                _formatTime(checkIn),
                              ),
                            ),
                            Expanded(
                              child: _detailLine(
                                'Check-out',
                                _formatTime(checkOut),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _detailLine(
                          'Working time',
                          workedTime,
                        ),
                        if (isLate && lateMinutes != null) ...[
                          const SizedBox(height: 12),
                          _detailLine(
                            'Late by',
                            '$lateMinutes minutes',
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

            if (controller.attendanceHistoryError.value.isNotEmpty)
              _inlineError(
                controller.attendanceHistoryError.value,
              ),

            const SizedBox(height: 12),
            const Text(
              'Attendance information is displayed as returned by the company API.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.5,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    });
  }


  Widget _buildReports() {
    return Obx(() {
      if (controller.isReportsLoading.value &&
          controller.reports.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppTheme.mediumBlue,
          ),
        );
      }

      if (controller.reportsError.value.isNotEmpty &&
          controller.reports.isEmpty) {
        return _errorState(
          message: controller.reportsError.value,
          onRetry: controller.loadReports,
        );
      }

      final reports = controller.reports;

      return RefreshIndicator(
        onRefresh: controller.loadReports,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Work reports',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'View your reports loaded from the company API.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _surfaceCard(
              child: Row(
                children: [
                  _iconBox(
                    Icons.description_outlined,
                    AppTheme.purple,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total reports',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.reportsTotal.value}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),
            if (reports.isEmpty)
              _emptyState(
                Icons.description_outlined,
                'No reports found',
                'Your API returned no reports. Your submitted reports will appear here when available.',
              )
            else
              ...reports.map((item) {
                final report = _asMap(item);
                final title =
                    report['title']?.toString() ?? 'Work report';
                final status =
                    report['status']?.toString() ?? 'Submitted';
                final description =
                    report['description']?.toString() ??
                        report['work_description']?.toString() ??
                        '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _surfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _iconBox(
                              Icons.article_outlined,
                              AppTheme.purple,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            _statusBadge(status),
                          ],
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'Submitted: ${_formatDate(report['created_at'])}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            if (controller.reportsError.value.isNotEmpty)
              _inlineError(controller.reportsError.value),
          ],
        ),
      );
    });
  }



  Widget _surfaceCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }

  Widget _statusBadge(String label) {
    final value = label.toLowerCase();

    final Color foreground;
    final Color background;

    if (value.contains('late') ||
        value.contains('reject') ||
        value.contains('incomplete')) {
      foreground = AppTheme.warning;
      background = AppTheme.warningLight;
    } else if (value.contains('working') ||
        value.contains('approved') ||
        value.contains('completed') ||
        value.contains('active')) {
      foreground = AppTheme.success;
      background = AppTheme.successLight;
    } else {
      foreground = AppTheme.primary;
      background = AppTheme.blueLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool loading,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: FilledButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primary,
          ),
        )
            : Icon(icon),
        label: Text(
          loading ? 'Processing...' : label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryDark,
          disabledBackgroundColor: Colors.white70,
          disabledForegroundColor: AppTheme.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _timeTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white70),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
      String title,
      String value,
      String subtitle,
      IconData icon,
      Color color,
      ) {
    return _surfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(icon, color),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyChart(List<dynamic> labels, List<dynamic> hours) {
    final values = hours
        .map((value) => value is num ? value.toDouble() : 0.0)
        .toList();

    final count = math.min(labels.length, values.length);

    if (count == 0) {
      return _emptyState(
        Icons.bar_chart_rounded,
        'No weekly activity',
        'No chart data was returned by the dashboard API.',
      );
    }

    final maxValue = values.fold<double>(
      0,
          (current, value) => current > value ? current : value,
    );

    return _surfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              _iconBox(Icons.bar_chart_rounded, AppTheme.mediumBlue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hours worked',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${values.take(count).fold<double>(0, (a, b) => a + b).toStringAsFixed(1)}h',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(count, (index) {
                final value = values[index];
                final height = maxValue == 0
                    ? 5.0
                    : math.max(5.0, value / maxValue * 75);

                final color = index.isEven
                    ? AppTheme.purple
                    : AppTheme.cyan;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: height.toDouble(),
                          decoration: BoxDecoration(
                            color: value > 0
                                ? color
                                : AppTheme.blueLight,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[index].toString().split(' ').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentReports(List<dynamic> reports) {
    if (reports.isEmpty) {
      return _emptyState(
        Icons.description_outlined,
        'No recent reports',
        'There are no recent reports in the dashboard response.',
      );
    }

    return _surfaceCard(
      child: Column(
        children: reports.map((item) {
          final report = _asMap(item);

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _iconBox(
              Icons.description_outlined,
              AppTheme.purple,
            ),
            title: Text(
              report['title']?.toString() ?? 'Work report',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            subtitle: Text(
              report['status']?.toString() ?? 'Submitted',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _profileRow(IconData icon, String title, dynamic value) {
    final text = value?.toString().trim() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.mediumBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text.isEmpty ? 'Not provided' : text,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileDivider() {
    return const Divider(height: 1, color: AppTheme.border);
  }

  Widget _detailLine(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(
      IconData icon,
      String title,
      String message,
      ) {
    return _surfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            _iconBox(icon, AppTheme.mediumBlue),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState({
    required String message,
    required Future<void> Function() onRetry,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconBox(Icons.cloud_off_rounded, AppTheme.error),
            const SizedBox(height: 17),
            const Text(
              'Unable to load data',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _inlineError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        style: const TextStyle(
          color: AppTheme.error,
          fontSize: 12,
        ),
      ),
    );
  }


  Widget _avatar(
      String name,
      double size, {
        bool white = false,
      }) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.isNotEmpty
        ? name[0].toUpperCase()
        : 'G';

    final user = controller.user;
    final profile = controller.profile.value ?? {};
    final profileUser = _asMap(profile['user']).isNotEmpty
        ? _asMap(profile['user'])
        : profile;

    final avatarUrl = (
        profileUser['avatar_url'] ??
            user['avatar_url']
    )?.toString();

    Widget initialsAvatar() {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: white ? null : AppTheme.purpleGradient,
          color: white ? Colors.white : null,
          borderRadius: BorderRadius.circular(size * 0.32),
        ),
        child: Text(
          initials,
          style: TextStyle(
            color: white ? AppTheme.primary : Colors.white,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    if (avatarUrl == null ||
        avatarUrl.isEmpty ||
        avatarUrl == 'null') {
      return SizedBox(
        height: size,
        width: size,
        child: initialsAvatar(),
      );
    }

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: white ? null : AppTheme.purpleGradient,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: white
            ? null
            : [
          BoxShadow(
            color: AppTheme.purple.withValues(alpha: 0.15),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.32),
        child: Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => initialsAvatar(),
        ),
      ),
    );
  }


  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  static String _formatTime(dynamic value) {
    if (value is! String || value.isEmpty) return '--:--';

    final date = DateTime.tryParse(value);
    if (date == null) return '--:--';

    return DateFormat('hh:mm a').format(date.toLocal());
  }

  static String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'Date unavailable';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return DateFormat('EEE, d MMM yyyy').format(date.toLocal());
  }

  static String _minutesText(dynamic value) {
    final minutes = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;

    return '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}m';
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 39,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          Card(
            color: AppTheme.surface,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.mediumBlue,
                  ),
                  title: const Text('Notification settings'),
                  subtitle: const Text(
                    'View notifications from the company server',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.to(
                          () => const _NotificationsPage(),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: AppTheme.mediumBlue,
                  ),
                  title: const Text('My profile'),
                  subtitle: const Text(
                    'View your account details',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: controller.loadProfile,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.palette_outlined,
                    color: AppTheme.mediumBlue,
                  ),
                  title: const Text('App appearance'),
                  subtitle: const Text(
                    'Theme switching needs app-wide theme persistence',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.snackbar(
                      'Theme settings',
                      'The global light/dark theme controller is not configured yet.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppTheme.error,
                  ),
                  title: const Text('Logout'),
                  subtitle: const Text('Sign out of your account'),
                  onTap: () {
                    Get.snackbar(
                      'Logout',
                      'Server logout needs to be connected to AuthController.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: controller.markAllNotificationsRead,
            child: const Text('Read all'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isNotificationsLoading.value &&
            controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.mediumBlue,
            ),
          );
        }

        if (controller.notificationsError.value.isNotEmpty &&
            controller.notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                controller.notificationsError.value,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text('No notifications returned by the server.'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, _) =>
            const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              final notification = item is Map
                  ? Map<String, dynamic>.from(item)
                  : <String, dynamic>{};

              final id = notification['id'];
              final title =
                  notification['title']?.toString() ?? 'Notification';
              final message =
                  notification['message']?.toString() ?? '';
              final read = notification['read_at'] != null;

              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: AppTheme.border),
                ),
                child: ListTile(
                  leading: Icon(
                    read
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_active_rounded,
                    color: read
                        ? AppTheme.textMuted
                        : AppTheme.mediumBlue,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  trailing: read
                      ? const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppTheme.success,
                    size: 20,
                  )
                      : IconButton(
                    tooltip: 'Mark as read',
                    onPressed: id is num
                        ? () => controller.markNotificationRead(
                      id.toInt(),
                    )
                        : null,
                    icon: const Icon(
                      Icons.mark_email_read_outlined,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
