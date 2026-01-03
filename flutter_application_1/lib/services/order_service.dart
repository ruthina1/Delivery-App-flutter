import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/models.dart';
import 'api/order_api_service.dart';
import '../core/exceptions/api_exception.dart';
import '../data/mock/mock_data.dart';

/// Order Service - Manages orders with API and local fallback
class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final _orderApi = OrderApiService();
  List<OrderModel> _localOrders = [];
  static const String _ordersPrefsKey = 'local_orders';

  /// Initialize - load local orders
  Future<void> initialize() async {
    await _loadLocalOrders();
  }

  Future<void> _loadLocalOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersPrefsKey);
      if (ordersJson != null) {
        final decoded = jsonDecode(ordersJson) as List<dynamic>;
        _localOrders = decoded.map((json) => _orderFromJson(json as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading local orders: $e');
      _localOrders = [];
    }
  }

  Future<void> _saveLocalOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = jsonEncode(_localOrders.map((order) => _orderToJson(order)).toList());
      await prefs.setString(_ordersPrefsKey, ordersJson);
    } catch (e) {
      debugPrint('Error saving local orders: $e');
    }
  }

  /// Create order - tries API first, falls back to local storage
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    required String addressId,
    required double subtotal,
    required double deliveryFee,
    double discount = 0,
    AddressModel? deliveryAddress,
  }) async {
    try {
      // Try API first
      return await _orderApi.createOrder(
        items: items,
        addressId: addressId,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: discount,
      );
    } catch (e) {
      // API failed, create local order
      debugPrint('API order creation failed, using local fallback: $e');
      return await _createLocalOrder(
        items: items,
        addressId: addressId,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: discount,
        deliveryAddress: deliveryAddress,
      );
    }
  }

  Future<OrderModel> _createLocalOrder({
    required List<Map<String, dynamic>> items,
    required String addressId,
    required double subtotal,
    required double deliveryFee,
    double discount = 0,
    AddressModel? deliveryAddress,
  }) async {
    // Load local orders
    await _loadLocalOrders();

    // Generate order ID and number
    final orderId = 'BK${DateTime.now().millisecondsSinceEpoch}';
    final orderNumber = 'BK${DateTime.now().year}${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Parse items
    final cartItems = items.map((itemJson) {
      // Try to get product from MockData first
      ProductModel? product;
      try {
        product = MockData.getProductById(itemJson['productId']?.toString() ?? '');
      } catch (_) {}

      // If not found, create a basic product
      product ??= ProductModel(
        id: itemJson['productId']?.toString() ?? '',
        name: itemJson['productName']?.toString() ?? 'Product',
        description: '',
        image: itemJson['productImage']?.toString() ?? '',
        price: (itemJson['price'] as num?)?.toDouble() ?? 0.0,
        rating: 0.0,
        reviewCount: 0,
        categoryId: '',
        ingredients: [],
        preparationTime: 0,
        calories: 0,
      );

      return CartItemModel(
        product: product,
        quantity: (itemJson['quantity'] as num?)?.toInt() ?? 1,
        customizations: (itemJson['customizations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    }).toList();

    // Get or create address
    AddressModel address;
    if (deliveryAddress != null) {
      address = deliveryAddress;
    } else {
      // Try to get from saved addresses or use default
      try {
        final savedAddresses = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('cached_addresses'))
            .then((json) {
          if (json != null) {
            final decoded = jsonDecode(json) as List<dynamic>;
            if (decoded.isNotEmpty) {
              final addrJson = decoded.first as Map<String, dynamic>;
              return AddressModel(
                id: addrJson['id']?.toString() ?? addressId,
                label: addrJson['label']?.toString() ?? 'Delivery',
                fullAddress: addrJson['fullAddress']?.toString() ?? '',
                street: addrJson['street']?.toString() ?? '',
                city: addrJson['city']?.toString() ?? 'Bahir Dar',
                zipCode: addrJson['zipCode']?.toString() ?? '',
                latitude: (addrJson['latitude'] as num?)?.toDouble() ?? 0.0,
                longitude: (addrJson['longitude'] as num?)?.toDouble() ?? 0.0,
                isDefault: addrJson['isDefault'] as bool? ?? false,
              );
            }
          }
          return null;
        });
        address = savedAddresses ?? MockData.addresses.first;
      } catch (e) {
        address = MockData.addresses.first;
      }
    }

    // Create order
    final order = OrderModel(
      id: orderId,
      orderNumber: orderNumber,
      items: cartItems,
      deliveryAddress: address,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: subtotal + deliveryFee - discount,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 30)),
      driverName: null, // Will be assigned later
      driverPhone: null,
    );

    // Simulate order progression
    _simulateOrderProgression(order);

    // Save locally
    _localOrders.insert(0, order);
    await _saveLocalOrders();
    notifyListeners();

    return order;
  }

  /// Simulate order status progression
  void _simulateOrderProgression(OrderModel order) {
    // Auto-confirm after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (_localOrders.any((o) => o.id == order.id)) {
        _updateOrderStatus(order.id, OrderStatus.confirmed);
      }
    });

    // Start preparing after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (_localOrders.any((o) => o.id == order.id && o.status == OrderStatus.confirmed)) {
        _updateOrderStatus(order.id, OrderStatus.preparing);
      }
    });

    // On the way after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (_localOrders.any((o) => o.id == order.id && o.status == OrderStatus.preparing)) {
        _updateOrderStatus(order.id, OrderStatus.onTheWay);
        // Assign driver
        _updateOrderDriver(order.id, 'Abebe Kebede', '+251 91 234 5678');
      }
    });

    // Delivered after 30 seconds (for demo purposes)
    Future.delayed(const Duration(seconds: 30), () {
      if (_localOrders.any((o) => o.id == order.id && o.status == OrderStatus.onTheWay)) {
        _updateOrderStatus(order.id, OrderStatus.delivered);
      }
    });
  }

  void _updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _localOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = _localOrders[index];
      _localOrders[index] = OrderModel(
        id: oldOrder.id,
        orderNumber: oldOrder.orderNumber,
        items: oldOrder.items,
        deliveryAddress: oldOrder.deliveryAddress,
        subtotal: oldOrder.subtotal,
        deliveryFee: oldOrder.deliveryFee,
        discount: oldOrder.discount,
        total: oldOrder.total,
        status: newStatus,
        createdAt: oldOrder.createdAt,
        estimatedDelivery: oldOrder.estimatedDelivery,
        driverName: oldOrder.driverName,
        driverPhone: oldOrder.driverPhone,
      );
      _saveLocalOrders();
      notifyListeners();
    }
  }

  void _updateOrderDriver(String orderId, String driverName, String driverPhone) {
    final index = _localOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = _localOrders[index];
      _localOrders[index] = OrderModel(
        id: oldOrder.id,
        orderNumber: oldOrder.orderNumber,
        items: oldOrder.items,
        deliveryAddress: oldOrder.deliveryAddress,
        subtotal: oldOrder.subtotal,
        deliveryFee: oldOrder.deliveryFee,
        discount: oldOrder.discount,
        total: oldOrder.total,
        status: oldOrder.status,
        createdAt: oldOrder.createdAt,
        estimatedDelivery: oldOrder.estimatedDelivery,
        driverName: driverName,
        driverPhone: driverPhone,
      );
      _saveLocalOrders();
      notifyListeners();
    }
  }

  /// Get all orders - tries API first, falls back to local
  Future<List<OrderModel>> getOrders() async {
    // Ensure local orders are loaded first
    await _loadLocalOrders();
    
    try {
      // Try API first
      final orders = await _orderApi.getOrders();
      // Merge with local orders (avoid duplicates)
      final apiOrderIds = orders.map((o) => o.id).toSet();
      final uniqueLocalOrders = _localOrders.where((o) => !apiOrderIds.contains(o.id)).toList();
      final allOrders = [...orders, ...uniqueLocalOrders];
      // Update local orders if API returned new ones
      if (orders.isNotEmpty) {
        _localOrders = allOrders;
        await _saveLocalOrders();
      }
      return allOrders;
    } catch (e) {
      // API failed, return local orders (already loaded)
      debugPrint('API getOrders failed, using local orders: $e');
      return List.from(_localOrders);
    }
  }

  /// Get order by ID - tries API first, falls back to local
  Future<OrderModel> getOrderById(String id) async {
    try {
      // Try API first
      return await _orderApi.getOrderById(id);
    } catch (e) {
      // API failed, check local orders
      debugPrint('API getOrderById failed, checking local orders: $e');
      await _loadLocalOrders();
      try {
        return _localOrders.firstWhere((order) => order.id == id);
      } catch (_) {
        throw ApiException('Order not found');
      }
    }
  }

  /// Cancel order
  Future<OrderModel> cancelOrder(String id) async {
    try {
      // Try API first
      return await _orderApi.cancelOrder(id);
    } catch (e) {
      // API failed, cancel locally
      debugPrint('API cancelOrder failed, canceling locally: $e');
      final index = _localOrders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _updateOrderStatus(id, OrderStatus.cancelled);
        return _localOrders[index];
      }
      throw ApiException('Order not found');
    }
  }

  // JSON conversion helpers
  Map<String, dynamic> _orderToJson(OrderModel order) => {
        'id': order.id,
        'orderNumber': order.orderNumber,
        'items': order.items.map((item) => {
              'productId': item.product.id,
              'productName': item.product.name,
              'productImage': item.product.image,
              'price': item.product.price,
              'quantity': item.quantity,
              'customizations': item.customizations,
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
            }).toList(),
        'deliveryAddress': {
          'id': order.deliveryAddress.id,
          'label': order.deliveryAddress.label,
          'fullAddress': order.deliveryAddress.fullAddress,
          'street': order.deliveryAddress.street,
          'city': order.deliveryAddress.city,
          'zipCode': order.deliveryAddress.zipCode,
          'latitude': order.deliveryAddress.latitude,
          'longitude': order.deliveryAddress.longitude,
          'isDefault': order.deliveryAddress.isDefault,
        },
        'subtotal': order.subtotal,
        'deliveryFee': order.deliveryFee,
        'discount': order.discount,
        'total': order.total,
        'status': order.status.toString().split('.').last,
        'createdAt': order.createdAt.toIso8601String(),
        'estimatedDelivery': order.estimatedDelivery?.toIso8601String(),
        'driverName': order.driverName,
        'driverPhone': order.driverPhone,
      };

  OrderModel _orderFromJson(Map<String, dynamic> json) {
    // Parse items
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson.map((itemJson) {
      final productJson = itemJson['product'] as Map<String, dynamic>? ?? {};
      final product = ProductModel(
        id: productJson['id']?.toString() ?? itemJson['productId']?.toString() ?? '',
        name: productJson['name']?.toString() ?? itemJson['productName']?.toString() ?? '',
        description: productJson['description']?.toString() ?? '',
        image: productJson['image']?.toString() ?? itemJson['productImage']?.toString() ?? '',
        price: (productJson['price'] as num?)?.toDouble() ?? 
               (itemJson['price'] as num?)?.toDouble() ?? 0.0,
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
        quantity: (itemJson['quantity'] as num?)?.toInt() ?? 1,
        customizations: (itemJson['customizations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    }).toList();

    // Parse address
    final addressJson = json['deliveryAddress'] as Map<String, dynamic>? ?? {};
    final address = AddressModel(
      id: addressJson['id']?.toString() ?? '',
      label: addressJson['label']?.toString() ?? '',
      fullAddress: addressJson['fullAddress']?.toString() ?? '',
      street: addressJson['street']?.toString() ?? '',
      city: addressJson['city']?.toString() ?? '',
      zipCode: addressJson['zipCode']?.toString() ?? '',
      latitude: (addressJson['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (addressJson['longitude'] as num?)?.toDouble() ?? 0.0,
      isDefault: addressJson['isDefault'] as bool? ?? false,
    );

    // Parse status
    OrderStatus status = OrderStatus.placed;
    final statusStr = json['status']?.toString().toLowerCase() ?? '';
    switch (statusStr) {
      case 'confirmed':
        status = OrderStatus.confirmed;
        break;
      case 'preparing':
        status = OrderStatus.preparing;
        break;
      case 'ontheway':
      case 'on_the_way':
        status = OrderStatus.onTheWay;
        break;
      case 'delivered':
        status = OrderStatus.delivered;
        break;
      case 'cancelled':
      case 'canceled':
        status = OrderStatus.cancelled;
        break;
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      items: items,
      deliveryAddress: address,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: status,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'].toString())
          : null,
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
    );
  }
}

