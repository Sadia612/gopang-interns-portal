import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/attendance_controller.dart';

/// Screen responsible for displaying daily attendance status, available user actions,
/// historical logs, and summary metrics.
class AttendanceView extends GetView<AttendanceController> {
  const AttendanceView({super.key});

  // UI Theme Colors
  static const Color _background = Color(0xFF09090B);
  static const Color _surface = Color(0xFF18181B);
  static const Color _border = Color(0xFF27272A);
  static const Color _muted = Color(0xFFA1A1AA);
  static const Color _primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              debugPrint('Refreshing attendance status...');
              controller.loadStatus(refresh: true);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        // Initial Loading State
        if (controller.isLoading.value &&
            controller.statusData.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }

        // Error State
        if (controller.statusData.value == null &&
            controller.errorMessage.value != null) {
          return _ErrorState(
            message: controller.errorMessage.value!,
            onRetry: () {
              debugPrint('Retrying status load...');
              controller.loadStatus();
            },
          );
        }

        // Main Attendance Screen Layout
        return RefreshIndicator(
          color: _primary,
          onRefresh: () async {
            debugPrint('Pull-to-refresh triggered');
            await controller.loadStatus(refresh: true);
            await controller.loadHistory(page: 1);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _header(),
              const SizedBox(height: 20),
              _todayCard(),
              const SizedBox(height: 16),
              _actionCard(),
              const SizedBox(height: 24),
              _historyHeader(),
              const SizedBox(height: 12),
              _historyFilters(),
              const SizedBox(height: 12),
              _historySection(),
            ],
          ),
        );
      }),
    );
  }

  /// Displays screen title and current date header.
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's overview",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _currentDate(),
          style: const TextStyle(color: _muted, fontSize: 13),
        ),
      ],
    );
  }

  /// Displays today's attendance status, progress bar, worked time, and check-in/out times.
  Widget _todayCard() {
    return Obx(() {
      final today = controller.today;

      if (today == null) {
        return const _Panel(
          child: Text(
            'Today attendance information is not available.',
            style: TextStyle(color: _muted),
          ),
        );
      }

      final progress = controller.progress;
      final progressValue = progress == null
          ? null
          : (progress.clamp(0, 100) / 100).toDouble();

      final status = today['status']?.toString() ?? 'unknown';
      final human = today['human']?.toString();
      final remaining = today['remaining_human']?.toString();
      final breakHuman = today['break_human']?.toString();

      return _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Working hours',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              human ?? 'Not provided by server',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            if (progressValue != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 7,
                  backgroundColor: _border,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Progress: $progress%',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ] else
              const Text(
                'Progress is not available.',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            const SizedBox(height: 20),
            const Divider(color: _border),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Remaining',
                    value: remaining ?? 'Not available',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Break taken',
                    value: breakHuman ?? 'Not available',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Check-in',
                    value: _formatDateTime(
                      today['check_in'] ?? controller.record?['check_in'],
                    ),
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Check-out',
                    value: _formatDateTime(
                      today['check_out'] ?? controller.record?['check_out'],
                    ),
                  ),
                ),
              ],
            ),
            if (controller.isRefreshing.value) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(
                minHeight: 2,
                color: _primary,
                backgroundColor: _border,
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Displays interactive action buttons for checking in, taking breaks, and checking out.
  Widget _actionCard() {
    return Obx(() {
      final checkedIn = controller.checkedIn;
      final checkedOut = controller.checkedOut;
      final onBreak = controller.onBreak;
      final busy = controller.isActionLoading.value;

      return _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Actions are processed by the attendance server.',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            if (!checkedIn)
              _ActionButton(
                label: 'Check in',
                icon: Icons.login_rounded,
                enabled: !busy,
                loading: busy,
                onPressed: () {
                  debugPrint('User initiated Check-In');
                  controller.checkIn();
                },
              )
            else if (!checkedOut) ...[
              _ActionButton(
                label: onBreak ? 'On break' : 'Checked in',
                icon: onBreak
                    ? Icons.coffee_rounded
                    : Icons.check_circle_outline_rounded,
                enabled: false,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              if (onBreak)
                _ActionButton(
                  label: 'Resume work',
                  icon: Icons.play_arrow_rounded,
                  enabled: !busy,
                  loading: busy,
                  onPressed: () {
                    debugPrint('User initiated Resume Work');
                    controller.endBreak();
                  },
                )
              else ...[
                _ActionButton(
                  label: 'Start break',
                  icon: Icons.coffee_rounded,
                  enabled: !busy,
                  loading: busy,
                  onPressed: () {
                    debugPrint('User initiated Start Break');
                    controller.startBreak();
                  },
                  outlined: true,
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  label: 'Check out',
                  icon: Icons.logout_rounded,
                  enabled: !busy,
                  loading: busy,
                  onPressed: () {
                    debugPrint('User initiated Check-Out');
                    controller.checkOut();
                  },
                  outlined: true,
                ),
              ],
            ] else
              _ActionButton(
                label: 'Checked out',
                icon: Icons.check_circle_rounded,
                enabled: false,
                onPressed: () {},
              ),
            if (controller.errorMessage.value != null) ...[
              const SizedBox(height: 12),
              Text(
                controller.errorMessage.value!,
                style: const TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Title section for history logs.
  Widget _historyHeader() {
    return const Text(
      'Attendance history',
      style: TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// Dropdown filter controls for date ranges and status categories.
  Widget _historyFilters() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _Dropdown(
              value: controller.selectedRange.value,
              items: const {
                'week': 'This week',
                'month': 'This month',
                'all': 'All records',
              },
              onChanged: (value) {
                if (value != null) {
                  debugPrint('Date range filter changed to: $value');
                  controller.changeRange(value);
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Dropdown(
              value: controller.selectedStatus.value,
              items: const {
                'all': 'All statuses',
                'late': 'Late',
                'completed': 'Completed',
                'incomplete': 'Incomplete',
              },
              onChanged: (value) {
                if (value != null) {
                  debugPrint('Status filter changed to: $value');
                  controller.changeStatus(value);
                }
              },
            ),
          ),
        ],
      );
    });
  }

  /// History list section presenting daily records, pagination, and period summaries.
  Widget _historySection() {
    return Obx(() {
      if (controller.isHistoryLoading.value &&
          controller.historyData.value == null) {
        return const _Panel(
          child: Center(
            child: CircularProgressIndicator(color: _primary),
          ),
        );
      }

      if (controller.historyError.value != null &&
          controller.historyData.value == null) {
        return _ErrorState(
          message: controller.historyError.value!,
          onRetry: () {
            debugPrint('Retrying history load...');
            controller.loadHistory();
          },
        );
      }

      final records = controller.attendanceRecords;

      return Column(
        children: [
          if (controller.historyError.value != null)
            _Panel(
              child: Text(
                controller.historyError.value!,
                style: const TextStyle(color: Color(0xFFFCA5A5)),
              ),
            ),
          if (records.isEmpty)
            const _Panel(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        color: _muted,
                        size: 32,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No attendance records found.',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Try changing the selected filters.',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...records.map(_historyItem),
          const SizedBox(height: 12),
          _pagination(),
          _summarySection(),
        ],
      );
    });
  }

  /// Individual attendance record card.
  Widget _historyItem(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? 'unknown';
    final date = _formatDate(item['work_date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Check-in',
                  value: _formatDateTime(item['check_in']),
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Check-out',
                  value: _formatDateTime(item['check_out']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Metric(
            label: 'Worked minutes',
            value: item['worked_minutes']?.toString() ?? 'Not available',
          ),
        ],
      ),
    );
  }

  /// Pagination controls for browsing history pages.
  Widget _pagination() {
    return Obx(() {
      final page = controller.attendancePage;

      if (page == null) return const SizedBox.shrink();

      final current = page['current_page']?.toString() ?? '—';
      final last = page['last_page']?.toString() ?? '—';
      final hasPrevious = page['prev_page_url'] != null;
      final hasNext = page['next_page_url'] != null;

      return Row(
        children: [
          IconButton(
            onPressed: hasPrevious && !controller.isHistoryLoading.value
                ? () {
              debugPrint('Navigating to previous page');
              controller.previousPage();
            }
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              'Page $current of $last',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: hasNext && !controller.isHistoryLoading.value
                ? () {
              debugPrint('Navigating to next page');
              controller.nextPage();
            }
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
            color: Colors.white,
          ),
        ],
      );
    });
  }

  /// Displays aggregated weekly and monthly statistics.
  Widget _summarySection() {
    return Obx(() {
      final data = controller.summary;
      if (data == null) return const SizedBox.shrink();

      final week = data['week'];
      final month = data['month'];

      Map<String, dynamic>? map(dynamic value) {
        return value is Map
            ? Map<String, dynamic>.from(value)
            : null;
      }

      final weekData = map(week);
      final monthData = map(month);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Period summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (weekData != null)
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Week',
                    style: TextStyle(color: _muted),
                  ),
                  const SizedBox(height: 8),
                  _Metric(
                    label: 'Worked',
                    value: weekData['human']?.toString() ?? 'Not available',
                  ),
                  _Metric(
                    label: 'Days present',
                    value: weekData['days_present']?.toString() ??
                        'Not available',
                  ),
                ],
              ),
            ),
          if (monthData != null) ...[
            const SizedBox(height: 10),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Month',
                    style: TextStyle(color: _muted),
                  ),
                  const SizedBox(height: 8),
                  _Metric(
                    label: 'Worked',
                    value: monthData['human']?.toString() ?? 'Not available',
                  ),
                  _Metric(
                    label: 'Days present',
                    value: monthData['days_present']?.toString() ??
                        'Not available',
                  ),
                  _Metric(
                    label: 'Attendance',
                    value: monthData['attendance_percent'] == null
                        ? 'Not available'
                        : '${monthData['attendance_percent']}%',
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Helper to format and retrieve today's date string.
  String _currentDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];

    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  /// Formats raw timestamp strings into standard 12-hour local time format.
  String _formatDateTime(dynamic value) {
    if (value is! String || value.isEmpty) return '—';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return '—';

    final date = parsed.toLocal();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  /// Formats raw date strings into standard DD/MM/YYYY local date format.
  String _formatDate(dynamic value) {
    if (value is! String || value.isEmpty) return 'Date unavailable';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return 'Date unavailable';

    final date = parsed.toLocal();
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Styled container panel wrapper.
class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AttendanceView._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AttendanceView._border),
      ),
      child: child,
    );
  }
}

/// Metric key-value text pairing display.
class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AttendanceView._muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual status badge indicator chip.
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final Color color = normalized == 'completed'
        ? const Color(0xFF4ADE80)
        : normalized == 'late'
        ? const Color(0xFFFBBF24)
        : normalized == 'incomplete'
        ? const Color(0xFFF87171)
        : AttendanceView._muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Reusable action button supporting active, loading, disabled, and outlined variants.
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final bool loading;
  final bool outlined;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = outlined ? Colors.white : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: outlined ? Colors.transparent : AttendanceView._primary,
          side: BorderSide(
            color: enabled
                ? (outlined ? AttendanceView._border : AttendanceView._primary)
                : AttendanceView._border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: loading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Styled filter dropdown menu component.
class _Dropdown extends StatelessWidget {
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: items.containsKey(value) ? value : items.keys.first,
      dropdownColor: AttendanceView._surface,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        filled: true,
        fillColor: AttendanceView._surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AttendanceView._border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AttendanceView._primary),
        ),
      ),
      items: items.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

/// Error state component displaying retry controls.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFF87171),
              size: 42,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load attendance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AttendanceView._muted,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}