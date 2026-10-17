import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/notifications_controller.dart';
import '../models/app_notification.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  static const Color darkBlue = Color(0xFF1A5490);
  static const Color mediumBlue = Color(0xFF178FB4);
  static const Color cyan = Color(0xFF2BB6C6);
  static const Color background = Color(0xFFF5F8FC);
  static const Color textColor = Color(0xFF18324D);
  static const Color mutedColor = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: textColor),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Notification options',
            onSelected: (value) async {
              if (value == 'read') {
                await controller.markAllAsRead();

                if (controller.errorMessage.value.isNotEmpty) {
                  Get.snackbar(
                    'Unable to update',
                    controller.errorMessage.value,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFFF0F0),
                    colorText: const Color(0xFFB42318),
                    margin: const EdgeInsets.all(16),
                  );
                } else {
                  Get.snackbar(
                    'Notifications updated',
                    'All notifications have been marked as read.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFE2F7EC),
                    colorText: const Color(0xFF16805D),
                    margin: const EdgeInsets.all(16),
                  );
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem<String>(
                value: 'read',
                child: Row(
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 20,
                      color: darkBlue,
                    ),
                    SizedBox(width: 10),
                    Text('Mark all as read'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: mediumBlue),
          );
        }

        return RefreshIndicator(
          color: mediumBlue,
          onRefresh: controller.refreshNotifications,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [darkBlue, mediumBlue, cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stay up to date',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            controller.unreadCount.value == 0
                                ? 'You are all caught up.'
                                : '${controller.unreadCount.value} unread notification(s)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent activity',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${controller.notifications.length} total',
                    style: const TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              if (controller.errorMessage.value.isNotEmpty) ...[
                _errorCard(controller.errorMessage.value),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: controller.refreshNotifications,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ),
              ],
              if (controller.notifications.isEmpty)
                _emptyState(
                  hasError: controller.errorMessage.value.isNotEmpty,
                )
              else
                ...controller.notifications.map(
                      (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _notificationCard(item, controller),
                  ),
                ),
              if (controller.hasMore.value) ...[
                const SizedBox(height: 4),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.loadNextPage,
                    icon: const Icon(Icons.expand_more_rounded),
                    label: const Text('Load more'),
                  ),
                ),
              ],
              if (controller.isRefreshing.value)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: mediumBlue,
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _notificationCard(
      AppNotification item,
      NotificationsController controller,
      ) {
    final Color accent;
    final Color iconBackground;
    final IconData icon;

    switch (item.type) {
      case 'check_in':
        accent = const Color(0xFF16805D);
        iconBackground = const Color(0xFFE2F7EC);
        icon = Icons.login_rounded;
        break;

      case 'break_start':
        accent = const Color(0xFF7652E8);
        iconBackground = const Color(0xFFF0EBFF);
        icon = Icons.coffee_rounded;
        break;

      case 'break_end':
        accent = const Color(0xFF16805D);
        iconBackground = const Color(0xFFE2F7EC);
        icon = Icons.play_circle_outline_rounded;
        break;

      case 'break':
        accent = item.title.toLowerCase().contains('ended')
            ? const Color(0xFF16805D)
            : const Color(0xFF7652E8);
        iconBackground = item.title.toLowerCase().contains('ended')
            ? const Color(0xFFE2F7EC)
            : const Color(0xFFF0EBFF);
        icon = Icons.coffee_rounded;
        break;

      case 'late':
        accent = const Color(0xFFB76E00);
        iconBackground = const Color(0xFFFFF0DC);
        icon = Icons.schedule_rounded;
        break;

      case 'check_out':
        accent = darkBlue;
        iconBackground = const Color(0xFFE5F2FF);
        icon = Icons.logout_rounded;
        break;

      default:
        accent = mediumBlue;
        iconBackground = const Color(0xFFEAF5FA);
        icon = Icons.notifications_outlined;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.isRead
            ? null
            : () async {
          await controller.markAsRead(item.id);
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.isRead
                  ? const Color(0xFFE7EDF5)
                  : mediumBlue.withValues(alpha: 0.30),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            margin: const EdgeInsets.only(
                              top: 4,
                              left: 6,
                            ),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: mediumBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.message,
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      item.timeLabel ?? _formatDate(item.createdAt),
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState({bool hasError = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EDF5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            size: 54,
            color: mediumBlue,
          ),
          const SizedBox(height: 14),
          Text(
            hasError ? 'Notifications unavailable' : 'No notifications yet',
            style: const TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            hasError
                ? 'Check your connection and try loading notifications again.'
                : 'Your attendance updates will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB42318),
          fontSize: 13,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year} • $hour:$minute $period';
  }
}