import 'package:get/get.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationService _service = NotificationService();

  final notifications = <AppNotification>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final errorMessage = ''.obs;
  final unreadCount = 0.obs;
  final currentPage = 1.obs;
  final hasMore = false.obs;

  bool _loadingList = false;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (_loadingList) return;

    _loadingList = true;

    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      final page = refresh ? 1 : currentPage.value;

      final results = await Future.wait([
        _service.getNotifications(page: page),
        _service.getUnreadCount(),
      ]);

      final items = results[0] as List<AppNotification>;
      final unread = results[1] as int;

      if (refresh || page == 1) {
        notifications.assignAll(items);
        currentPage.value = 1;
      } else {
        final existingIds = notifications.map((item) => item.id).toSet();
        notifications.addAll(
          items.where((item) => !existingIds.contains(item.id)),
        );
      }

      unreadCount.value = unread;
      hasMore.value = items.length >= 20;
    } on NotificationException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Could not load notifications. Please retry.';
    } finally {
      _loadingList = false;
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }

  Future<void> loadNextPage() async {
    if (_loadingList || !hasMore.value) return;

    currentPage.value++;
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index == -1 || notifications[index].isRead) return;

    try {
      await _service.markAsRead(id);

      notifications[index] = notifications[index].copyWith(isRead: true);
      if (unreadCount.value > 0) unreadCount.value--;
      errorMessage.value = '';
    } on NotificationException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Could not mark the notification as read.';
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();

      notifications.assignAll(
        notifications.map((item) => item.copyWith(isRead: true)),
      );

      unreadCount.value = 0;
      errorMessage.value = '';
    } on NotificationException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Could not mark notifications as read.';
    }
  }

  Future<void> clearAll() async {
    errorMessage.value =
    'Notifications are managed by the server. No delete endpoint has been confirmed.';
  }
}