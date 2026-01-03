import 'package:flutter/foundation.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? type; // 'order', 'promotion', 'general'

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type,
  });
}

/// Global notification service
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        type: _notifications[index].type,
      );
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          title: _notifications[i].title,
          message: _notifications[i].message,
          timestamp: _notifications[i].timestamp,
          isRead: true,
          type: _notifications[i].type,
        );
      }
    }
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Initialize with some mock notifications
  void initializeMockNotifications() {
    if (_notifications.isEmpty) {
      _notifications.addAll([
        NotificationModel(
          id: 'notif_1',
          title: 'Order Confirmed',
          message: 'Your order #BK2024001 has been confirmed and is being prepared.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          type: 'order',
        ),
        NotificationModel(
          id: 'notif_2',
          title: 'Special Offer',
          message: 'Get 20% off on all burgers this weekend! Use code WEEKEND20',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'promotion',
        ),
        NotificationModel(
          id: 'notif_3',
          title: 'Order Delivered',
          message: 'Your order #BK2024000 has been delivered. Enjoy your meal!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          type: 'order',
        ),
      ]);
      notifyListeners();
    }
  }
}

