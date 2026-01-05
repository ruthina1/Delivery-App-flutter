import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage notification settings
class NotificationSettingsService extends ChangeNotifier {
  static final NotificationSettingsService _instance = NotificationSettingsService._internal();
  factory NotificationSettingsService() => _instance;
  NotificationSettingsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static const String _prefsKey = 'notification_enabled';
  
  bool _notificationsEnabled = true;
  bool _isInitialized = false;

  bool get notificationsEnabled => _notificationsEnabled;

  /// Initialize - load notification settings
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        // Try Firestore first
        final settingsDoc = await _firestore
            .collection('userSettings')
            .doc(user.uid)
            .get();
        
        if (settingsDoc.exists && settingsDoc.data() != null) {
          final data = settingsDoc.data()!;
          _notificationsEnabled = data['notificationsEnabled'] as bool? ?? true;
        } else {
          // Load from local storage
          final prefs = await SharedPreferences.getInstance();
          _notificationsEnabled = prefs.getBool(_prefsKey) ?? true;
        }
      } catch (e) {
        debugPrint('🟡 [NotificationSettings] Error loading from Firestore: $e');
        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        _notificationsEnabled = prefs.getBool(_prefsKey) ?? true;
      }
    } else {
      // Load from local storage
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_prefsKey) ?? true;
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Toggle notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    
    final user = _firebaseAuth.currentUser;
    
    // Save to Firestore
    if (user != null) {
      try {
        await _firestore.collection('userSettings').doc(user.uid).set({
          'notificationsEnabled': enabled,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('✅ [NotificationSettings] Saved to Firestore: $enabled');
      } catch (e) {
        debugPrint('🔴 [NotificationSettings] Error saving to Firestore: $e');
      }
    }
    
    // Also save to local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, enabled);
    } catch (e) {
      debugPrint('🔴 [NotificationSettings] Error saving to local storage: $e');
    }
  }
}

