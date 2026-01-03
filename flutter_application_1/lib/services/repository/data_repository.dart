import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/models.dart';
import '../api/product_api_service.dart';
import '../api/category_api_service.dart';
import '../api/address_api_service.dart';
import '../api/favorite_api_service.dart';
import '../../core/exceptions/api_exception.dart';

/// Data Repository - Manages data flow with caching and offline support
class DataRepository extends ChangeNotifier {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;
  DataRepository._internal();

  final _productApi = ProductApiService();
  final _categoryApi = CategoryApiService();
  final _addressApi = AddressApiService();
  final _favoriteApi = FavoriteApiService();

  // Cache
  List<ProductModel>? _cachedProducts;
  List<CategoryModel>? _cachedCategories;
  List<AddressModel>? _cachedAddresses;
  Set<String>? _cachedFavorites;

  // Loading states
  bool _isLoadingProducts = false;
  bool _isLoadingCategories = false;
  bool _isLoadingAddresses = false;

  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingAddresses => _isLoadingAddresses;

  // Cache keys
  static const String _productsCacheKey = 'cached_products';
  static const String _categoriesCacheKey = 'cached_categories';
  static const String _addressesCacheKey = 'cached_addresses';
  static const String _favoritesCacheKey = 'cached_favorites';

  /// Initialize repository - load cached data
  Future<void> initialize() async {
    await _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cached products
      final productsJson = prefs.getString(_productsCacheKey);
      if (productsJson != null) {
        final List<dynamic> productsList = jsonDecode(productsJson);
        _cachedProducts = productsList
            .map((json) => _productFromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Load cached categories
      final categoriesJson = prefs.getString(_categoriesCacheKey);
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = jsonDecode(categoriesJson);
        _cachedCategories = categoriesList
            .map((json) => _categoryFromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Load cached addresses
      final addressesJson = prefs.getString(_addressesCacheKey);
      if (addressesJson != null) {
        final List<dynamic> addressesList = jsonDecode(addressesJson);
        _cachedAddresses = addressesList
            .map((json) => _addressFromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Load cached favorites
      final favoritesJson = prefs.getString(_favoritesCacheKey);
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = jsonDecode(favoritesJson);
        _cachedFavorites = favoritesList.map((e) => e.toString()).toSet();
      } else {
        _cachedFavorites = <String>{};
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  Future<void> _saveProductsCache(List<ProductModel> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = jsonEncode(
        products.map((p) => _productToJson(p)).toList(),
      );
      await prefs.setString(_productsCacheKey, productsJson);
      _cachedProducts = products;
    } catch (e) {
      debugPrint('Error saving products cache: $e');
    }
  }

  Future<void> _saveCategoriesCache(List<CategoryModel> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = jsonEncode(
        categories.map((c) => _categoryToJson(c)).toList(),
      );
      await prefs.setString(_categoriesCacheKey, categoriesJson);
      _cachedCategories = categories;
    } catch (e) {
      debugPrint('Error saving categories cache: $e');
    }
  }

  Future<void> _saveAddressesCache(List<AddressModel> addresses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = jsonEncode(
        addresses.map((a) => _addressToJson(a)).toList(),
      );
      await prefs.setString(_addressesCacheKey, addressesJson);
      _cachedAddresses = addresses;
    } catch (e) {
      debugPrint('Error saving addresses cache: $e');
    }
  }

  Future<void> _saveFavoritesCache(Set<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = jsonEncode(favorites.toList());
      await prefs.setString(_favoritesCacheKey, favoritesJson);
      _cachedFavorites = favorites;
    } catch (e) {
      debugPrint('Error saving favorites cache: $e');
    }
  }

  // Products
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    bool? isPopular,
    bool? isFeatured,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedProducts != null) {
      var products = _cachedProducts!;
      if (categoryId != null) {
        products = products.where((p) => p.categoryId == categoryId).toList();
      }
      if (isPopular != null) {
        products = products.where((p) => p.isPopular == isPopular).toList();
      }
      if (isFeatured != null) {
        products = products.where((p) => p.isFeatured == isFeatured).toList();
      }
      return products;
    }

    _isLoadingProducts = true;
    notifyListeners();

    try {
      final products = await _productApi.getProducts(
        categoryId: categoryId,
        isPopular: isPopular,
        isFeatured: isFeatured,
      );
      await _saveProductsCache(products);
      _isLoadingProducts = false;
      notifyListeners();
      return products;
    } catch (e) {
      _isLoadingProducts = false;
      notifyListeners();
      // Return cached data if available, even if API fails
      if (_cachedProducts != null) {
        return _cachedProducts!;
      }
      rethrow;
    }
  }

  Future<ProductModel> getProductById(String id) async {
    // Check cache first
    if (_cachedProducts != null) {
      try {
        return _cachedProducts!.firstWhere((p) => p.id == id);
      } catch (_) {}
    }

    try {
      return await _productApi.getProductById(id);
    } catch (e) {
      throw ApiException('Product not found: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      return await _productApi.searchProducts(query);
    } catch (e) {
      // Fallback to local search if API fails
      if (_cachedProducts != null) {
        final queryLower = query.toLowerCase();
        return _cachedProducts!.where((p) {
          return p.name.toLowerCase().contains(queryLower) ||
              p.description.toLowerCase().contains(queryLower);
        }).toList();
      }
      rethrow;
    }
  }

  // Categories
  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCategories != null) {
      return _cachedCategories!;
    }

    _isLoadingCategories = true;
    notifyListeners();

    try {
      final categories = await _categoryApi.getCategories();
      await _saveCategoriesCache(categories);
      _isLoadingCategories = false;
      notifyListeners();
      return categories;
    } catch (e) {
      _isLoadingCategories = false;
      notifyListeners();
      if (_cachedCategories != null) {
        return _cachedCategories!;
      }
      rethrow;
    }
  }

  Future<CategoryModel> getCategoryById(String id) async {
    if (_cachedCategories != null) {
      try {
        return _cachedCategories!.firstWhere((c) => c.id == id);
      } catch (_) {}
    }

    try {
      return await _categoryApi.getCategoryById(id);
    } catch (e) {
      throw ApiException('Category not found: ${e.toString()}');
    }
  }

  // Addresses
  Future<List<AddressModel>> getAddresses({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedAddresses != null) {
      return _cachedAddresses!;
    }

    _isLoadingAddresses = true;
    notifyListeners();

    try {
      final addresses = await _addressApi.getAddresses();
      await _saveAddressesCache(addresses);
      _isLoadingAddresses = false;
      notifyListeners();
      return addresses;
    } catch (e) {
      _isLoadingAddresses = false;
      notifyListeners();
      if (_cachedAddresses != null) {
        return _cachedAddresses!;
      }
      rethrow;
    }
  }

  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final newAddress = await _addressApi.createAddress(address);
      if (_cachedAddresses != null) {
        _cachedAddresses!.add(newAddress);
        await _saveAddressesCache(_cachedAddresses!);
      }
      notifyListeners();
      return newAddress;
    } catch (e) {
      rethrow;
    }
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      final updatedAddress = await _addressApi.updateAddress(address);
      if (_cachedAddresses != null) {
        final index = _cachedAddresses!.indexWhere((a) => a.id == address.id);
        if (index != -1) {
          _cachedAddresses![index] = updatedAddress;
          await _saveAddressesCache(_cachedAddresses!);
        }
      }
      notifyListeners();
      return updatedAddress;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _addressApi.deleteAddress(id);
      if (_cachedAddresses != null) {
        _cachedAddresses!.removeWhere((a) => a.id == id);
        await _saveAddressesCache(_cachedAddresses!);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Favorites
  Future<Set<String>> getFavorites({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedFavorites != null) {
      return _cachedFavorites!;
    }

    try {
      final favorites = await _favoriteApi.getFavorites();
      _cachedFavorites = favorites.toSet();
      await _saveFavoritesCache(_cachedFavorites!);
      notifyListeners();
      return _cachedFavorites!;
    } catch (e) {
      if (_cachedFavorites != null) {
        return _cachedFavorites!;
      }
      return <String>{};
    }
  }

  Future<void> addFavorite(String productId) async {
    try {
      await _favoriteApi.addFavorite(productId);
      _cachedFavorites ??= <String>{};
      _cachedFavorites!.add(productId);
      await _saveFavoritesCache(_cachedFavorites!);
      notifyListeners();
    } catch (e) {
      // Optimistically update UI
      _cachedFavorites ??= <String>{};
      _cachedFavorites!.add(productId);
      await _saveFavoritesCache(_cachedFavorites!);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      await _favoriteApi.removeFavorite(productId);
      _cachedFavorites?.remove(productId);
      if (_cachedFavorites != null) {
        await _saveFavoritesCache(_cachedFavorites!);
      }
      notifyListeners();
    } catch (e) {
      // Optimistically update UI
      _cachedFavorites?.remove(productId);
      if (_cachedFavorites != null) {
        await _saveFavoritesCache(_cachedFavorites!);
      }
      notifyListeners();
      rethrow;
    }
  }

  bool isFavorite(String productId) {
    return _cachedFavorites?.contains(productId) ?? false;
  }

  // Getters for cached data
  List<ProductModel>? get cachedProducts => _cachedProducts;
  List<CategoryModel>? get cachedCategories => _cachedCategories;
  List<AddressModel>? get cachedAddresses => _cachedAddresses;

  // JSON conversion helpers
  Map<String, dynamic> _productToJson(ProductModel product) => {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'image': product.image,
        'price': product.price,
        'originalPrice': product.originalPrice,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'categoryId': product.categoryId,
        'ingredients': product.ingredients,
        'isPopular': product.isPopular,
        'isFeatured': product.isFeatured,
        'preparationTime': product.preparationTime,
        'calories': product.calories,
      };

  ProductModel _productFromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        originalPrice: (json['originalPrice'] as num?)?.toDouble(),
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        categoryId: json['categoryId']?.toString() ?? '',
        ingredients: (json['ingredients'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        isPopular: json['isPopular'] as bool? ?? false,
        isFeatured: json['isFeatured'] as bool? ?? false,
        preparationTime: (json['preparationTime'] as num?)?.toInt() ?? 0,
        calories: (json['calories'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> _categoryToJson(CategoryModel category) => {
        'id': category.id,
        'name': category.name,
        'icon': category.icon,
        'image': category.image,
      };

  CategoryModel _categoryFromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        icon: json['icon']?.toString() ?? '🍔',
        image: json['image']?.toString() ?? '',
      );

  Map<String, dynamic> _addressToJson(AddressModel address) => {
        'id': address.id,
        'label': address.label,
        'fullAddress': address.fullAddress,
        'street': address.street,
        'city': address.city,
        'zipCode': address.zipCode,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'isDefault': address.isDefault,
      };

  AddressModel _addressFromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        fullAddress: json['fullAddress']?.toString() ?? '',
        street: json['street']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        zipCode: json['zipCode']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

