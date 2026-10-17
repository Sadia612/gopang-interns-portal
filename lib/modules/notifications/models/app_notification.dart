class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.level = 'info',
    this.timeLabel,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final String level;
  final String? timeLabel;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      level: level,
      timeLabel: timeLabel,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawDate = json['created_at'] ?? json['createdAt'];

    return AppNotification(
      id: rawId.toString(),
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      createdAt: DateTime.tryParse(rawDate?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      isRead: json['is_read'] == true ||
          json['read_at'] != null ||
          json['isRead'] == true,
      level: json['level']?.toString() ?? 'info',
      timeLabel: json['time']?.toString(),
    );
  }
}