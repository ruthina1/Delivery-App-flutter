import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage favorite products - uses Firestore only
class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Set<String> _favoriteProductIds = {};
  bool _isInitialized = false;
  String? _currentUserId; // Track current user to detect changes

  Set<String> get favoriteProductIds => _favoriteProductIds;

  /// Initialize - load favorites from Firestore
  Future<void> initialize() async {
    final user = _firebaseAuth.currentUser;
    final userId = user?.uid;
    
    // If same user and already initialized, skip
    if (_isInitialized && _currentUserId == userId) {
      debugPrint('🟡 [FavoriteService] Already initialized for user: $userId');
      return;
    }
    
    // If user changed, reset
    if (_currentUserId != null && _currentUserId != userId) {
      debugPrint('🟡 [FavoriteService] User changed from $_currentUserId to $userId, resetting...');
      _favoriteProductIds = {};
      _isInitialized = false;
    }
    
    _currentUserId = userId;
    
    try {
      // Load from Firestore only
      if (user != null) {
        await _loadFavoritesFromFirestore(user.uid);
      } else {
        _favoriteProductIds = {};
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('🔴 [FavoriteService] Firestore load failed: $e');
      _favoriteProductIds = {};
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Load favorites from Firestore
  Future<void> _loadFavoritesFromFirestore(String userId) async {
    try {
      final favoritesDoc = await _firestore.collection('favorites').doc(userId).get();
      if (favoritesDoc.exists && favoritesDoc.data() != null) {
        final data = favoritesDoc.data()!;
        final favoritesList = data['productIds'] as List<dynamic>? ?? [];
        _favoriteProductIds = favoritesList.map((e) => e.toString()).toSet();
        debugPrint('✅ [FavoriteService] Loaded ${_favoriteProductIds.length} favorites from Firestore');
      } else {
        // Create empty document
        await _firestore.collection('favorites').doc(userId).set({
          'productIds': [],
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _favoriteProductIds = {};
      }
    } catch (e) {
      debugPrint('🔴 [FavoriteService] Error loading favorites from Firestore: $e');
      rethrow;
    }
  }
  
  /// Save favorites to Firestore
  Future<void> _saveFavoritesToFirestore() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore.collection('favorites').doc(user.uid).set({
        'productIds': _favoriteProductIds.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ [FavoriteService] Favorites saved to Firestore');
    } catch (e) {
      debugPrint('🔴 [FavoriteService] Error saving favorites to Firestore: $e');
    }
  }

  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  Future<void> toggleFavorite(String productId) async {
    if (_favoriteProductIds.contains(productId)) {
      await removeFavorite(productId);
    } else {
      await addFavorite(productId);
    }
  }

  Future<void> addFavorite(String productId) async {
    if (_favoriteProductIds.contains(productId)) return;
    
    _favoriteProductIds.add(productId);
    notifyListeners();

    try {
      // Save to Firestore only
      await _saveFavoritesToFirestore();
      debugPrint('✅ [FavoriteService] Favorite added: $productId');
    } catch (e) {
      // Revert on error
      _favoriteProductIds.remove(productId);
      notifyListeners();
      debugPrint('🔴 [FavoriteService] Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String productId) async {
    if (!_favoriteProductIds.contains(productId)) return;
    
    _favoriteProductIds.remove(productId);
    notifyListeners();

    try {
      // Save to Firestore only
      await _saveFavoritesToFirestore();
      debugPrint('✅ [FavoriteService] Favorite removed: $productId');
    } catch (e) {
      // Revert on error
      _favoriteProductIds.add(productId);
      notifyListeners();
      debugPrint('🔴 [FavoriteService] Error removing favorite: $e');
      rethrow;
    }
  }

  int get count => _favoriteProductIds.length;
}
