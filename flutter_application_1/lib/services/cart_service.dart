import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/models.dart';

/// Global cart service for managing shopping cart state
class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItemModel> _cartItems = [];
  static const String _cartPrefsKey = 'cart_items';

  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);
  
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get deliveryFee => subtotal > 1500 ? 0 : 50;
  
  double get total => subtotal + deliveryFee;

  /// Initialize - load saved cart
  Future<void> initialize() async {
    await _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartPrefsKey);
      if (cartJson != null) {
        final List<dynamic> cartList = jsonDecode(cartJson);
        _cartItems.clear();
        for (var itemJson in cartList) {
          try {
            final cartItem = _cartItemFromJson(itemJson as Map<String, dynamic>);
            _cartItems.add(cartItem);
          } catch (e) {
            debugPrint('Error loading cart item: $e');
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(
        _cartItems.map((item) => _cartItemToJson(item)).toList(),
      );
      await prefs.setString(_cartPrefsKey, cartJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  /// Add item to cart
  void addToCart(ProductModel product, {int quantity = 1, List<String> customizations = const []}) {
    // Check if product already exists in cart
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id && 
                 listEquals(item.customizations, customizations),
    );

    if (existingIndex != -1) {
      // Update quantity if item exists
      _cartItems[existingIndex].quantity += quantity;
    } else {
      // Add new item
      _cartItems.add(
        CartItemModel(
          product: product,
          quantity: quantity,
          customizations: customizations,
        ),
      );
    }
    _saveCart();
    notifyListeners();
  }

  /// Remove item from cart
  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      _saveCart();
      notifyListeners();
    }
  }

  /// Update item quantity
  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  /// Clear all items from cart
  void clearCart() {
    _cartItems.clear();
    _saveCart();
    notifyListeners();
  }

  /// Check if cart is empty
  bool get isEmpty => _cartItems.isEmpty;

  /// Get cart item count badge
  String? get cartBadge {
    final count = itemCount;
    return count > 0 ? count.toString() : null;
  }

  Map<String, dynamic> _cartItemToJson(CartItemModel item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'productImage': item.product.image,
        'productPrice': item.product.price,
        'quantity': item.quantity,
        'customizations': item.customizations,
        // Store full product data for offline access
        'product': {
          'id': item.product.id,
          'name': item.product.name,
          'description': item.product.description,
          'image': item.product.image,
          'price': item.product.price,
          'originalPrice': item.product.originalPrice,
          'rating': item.product.rating,
          'reviewCount': item.product.reviewCount,
          'categoryId': item.product.categoryId,
          'ingredients': item.product.ingredients,
          'isPopular': item.product.isPopular,
          'isFeatured': item.product.isFeatured,
          'preparationTime': item.product.preparationTime,
          'calories': item.product.calories,
        },
      };

  CartItemModel _cartItemFromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>? ?? {};
    final product = ProductModel(
      id: productJson['id']?.toString() ?? json['productId']?.toString() ?? '',
      name: productJson['name']?.toString() ?? json['productName']?.toString() ?? '',
      description: productJson['description']?.toString() ?? '',
      image: productJson['image']?.toString() ?? json['productImage']?.toString() ?? '',
      price: (productJson['price'] as num?)?.toDouble() ?? 
             (json['productPrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (productJson['originalPrice'] as num?)?.toDouble(),
      rating: (productJson['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (productJson['reviewCount'] as num?)?.toInt() ?? 0,
      categoryId: productJson['categoryId']?.toString() ?? '',
      ingredients: (productJson['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isPopular: productJson['isPopular'] as bool? ?? false,
      isFeatured: productJson['isFeatured'] as bool? ?? false,
      preparationTime: (productJson['preparationTime'] as num?)?.toInt() ?? 0,
      calories: (productJson['calories'] as num?)?.toInt() ?? 0,
    );

    return CartItemModel(
      product: product,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      customizations: (json['customizations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

