import 'package:flutter/material.dart';
import 'repository/data_repository.dart';

/// Service to manage favorite products
class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final _dataRepository = DataRepository();
  Set<String> _favoriteProductIds = {};
  bool _isInitialized = false;

  Set<String> get favoriteProductIds => _favoriteProductIds;

  /// Initialize - load favorites from repository
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _favoriteProductIds = await _dataRepository.getFavorites();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing favorites: $e');
      _favoriteProductIds = {};
      _isInitialized = true;
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
      await _dataRepository.addFavorite(productId);
    } catch (e) {
      // Revert on error
      _favoriteProductIds.remove(productId);
      notifyListeners();
      debugPrint('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String productId) async {
    if (!_favoriteProductIds.contains(productId)) return;
    
    _favoriteProductIds.remove(productId);
    notifyListeners();

    try {
      await _dataRepository.removeFavorite(productId);
    } catch (e) {
      // Revert on error
      _favoriteProductIds.add(productId);
      notifyListeners();
      debugPrint('Error removing favorite: $e');
    }
  }

  int get count => _favoriteProductIds.length;
}
