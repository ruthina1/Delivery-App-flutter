import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_settings_service.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? type; // 'order', 'promotion', 'general'
  final String? orderId; // For order-related notifications

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type,
    this.orderId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'orderId': orderId,
    };
  }

  factory NotificationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      type: data['type']?.toString(),
      orderId: data['orderId']?.toString(),
    );
  }
}

/// Global notification service - uses Firestore
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final List<NotificationModel> _notifications = [];
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  bool _isInitialized = false;

  String? _currentUserId; // Track current user to detect changes
  
  /// Initialize - listen to Firestore notifications
  Future<void> initialize() async {
    final user = _firebaseAuth.currentUser;
    final userId = user?.uid;
    
    // If same user and already initialized, skip
    if (_isInitialized && _currentUserId == userId) {
      debugPrint('🟡 [NotificationService] Already initialized for user: $userId');
      return;
    }
    
    // If user changed, cancel old subscription and reset
    if (_currentUserId != null && _currentUserId != userId) {
      debugPrint('🟡 [NotificationService] User changed from $_currentUserId to $userId, resetting...');
      _notificationsSubscription?.cancel();
      _notifications.clear();
      _isInitialized = false;
    }
    
    _currentUserId = userId;
    
    if (user == null) {
      debugPrint('🟡 [NotificationService] No user logged in');
      _notifications.clear();
      _isInitialized = true;
      notifyListeners();
      return;
    }
    
    try {
      debugPrint('🟢 [NotificationService] Initializing Firestore listener for user: ${user.uid}');
      
      // Listen to real-time notifications from Firestore
      _notificationsSubscription = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
        _notifications.clear();
        _notifications.addAll(
          snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc.id, doc.data())),
        );
        notifyListeners();
        debugPrint('✅ [NotificationService] Loaded ${_notifications.length} notifications');
      });
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('🔴 [NotificationService] Error initializing: $e');
      _notifications.clear();
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Dispose - cancel subscriptions
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  /// Add notification to Firestore
  Future<void> addNotification(NotificationModel notification) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('🟡 [NotificationService] Cannot add notification - no user');
      return;
    }
    
    try {
      final notificationData = notification.toFirestore();
      notificationData['userId'] = user.uid;
      
      await _firestore.collection('notifications').add(notificationData);
      debugPrint('✅ [NotificationService] Notification added to Firestore');
    } catch (e) {
      debugPrint('🔴 [NotificationService] Error adding notification: $e');
      // Fallback: add to local list
      _notifications.insert(0, notification);
      notifyListeners();
    }
  }
  
  /// Create order status notification
  Future<void> createOrderNotification({
    required String orderId,
    required String orderNumber,
    required String status,
  }) async {
    // Check if notifications are enabled
    final settingsService = NotificationSettingsService();
    if (!settingsService.notificationsEnabled) {
      debugPrint('🟡 [NotificationService] Notifications disabled, skipping notification');
      return;
    }
    
    String title;
    String message;
    
    switch (status.toLowerCase()) {
      case 'placed':
        title = 'Order Placed';
        message = 'Your order #$orderNumber has been placed successfully. Tap to track your order.';
        break;
      case 'confirmed':
        title = 'Order Confirmed';
        message = 'Your order #$orderNumber has been confirmed and is being prepared. Tap to track.';
        break;
      case 'preparing':
        title = 'Order Preparing';
        message = 'Your order #$orderNumber is being prepared. Tap to track progress.';
        break;
      case 'ontheway':
      case 'on_the_way':
        title = 'Order On The Way';
        message = 'Your order #$orderNumber is on the way to you! Tap to track delivery.';
        break;
      case 'delivered':
        title = 'Order Delivered';
        message = 'Your order #$orderNumber has been delivered. Enjoy your meal!';
        break;
      case 'cancelled':
      case 'canceled':
        title = 'Order Cancelled';
        message = 'Your order #$orderNumber has been cancelled.';
        break;
      default:
        title = 'Order Update';
        message = 'Your order #$orderNumber status has been updated. Tap to view details.';
    }
    
    await addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: 'order',
      orderId: orderId,
    ));
  }

  Future<void> markAsRead(String notificationId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      debugPrint('✅ [NotificationService] Notification marked as read');
    } catch (e) {
      debugPrint('🔴 [NotificationService] Error marking as read: $e');
      // Fallback: update local list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          timestamp: _notifications[index].timestamp,
          isRead: true,
          type: _notifications[index].type,
          orderId: _notifications[index].orderId,
        );
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    try {
      final batch = _firestore.batch();
      final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
      
      for (final notification in unreadNotifications) {
        final ref = _firestore.collection('notifications').doc(notification.id);
        batch.update(ref, {'isRead': true});
      }
      
      await batch.commit();
      debugPrint('✅ [NotificationService] All notifications marked as read');
    } catch (e) {
      debugPrint('🔴 [NotificationService] Error marking all as read: $e');
      // Fallback: update local list
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = NotificationModel(
            id: _notifications[i].id,
            title: _notifications[i].title,
            message: _notifications[i].message,
            timestamp: _notifications[i].timestamp,
            isRead: true,
            type: _notifications[i].type,
            orderId: _notifications[i].orderId,
          );
        }
      }
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      debugPrint('✅ [NotificationService] Notification deleted');
    } catch (e) {
      debugPrint('🔴 [NotificationService] Error deleting notification: $e');
      // Fallback: remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    try {
      final batch = _firestore.batch();
      for (final notification in _notifications) {
        final ref = _firestore.collection('notifications').doc(notification.id);
        batch.delete(ref);
      }
      await batch.commit();
      debugPrint('✅ [NotificationService] All notifications cleared');
    } catch (e) {
      debugPrint('🔴 [NotificationService] Error clearing notifications: $e');
      // Fallback: clear local list
      _notifications.clear();
      notifyListeners();
    }
  }
}

