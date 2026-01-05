import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../data/models/models.dart';
import '../core/exceptions/api_exception.dart';
import '../data/mock/mock_data.dart';
import 'notification_service.dart';

/// Order Service - Manages orders with Firestore only
class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<OrderModel> _localOrders = [];
  static const String _ordersPrefsKey = 'local_orders';
  bool _isInitialized = false;

  String? _currentUserId; // Track current user to detect changes
  
  /// Initialize - load orders from Firestore
  Future<void> initialize() async {
    final user = _firebaseAuth.currentUser;
    final userId = user?.uid;
    
    // If same user and already initialized, skip
    if (_isInitialized && _currentUserId == userId) {
      debugPrint('🟡 [OrderService] Already initialized for user: $userId');
      return;
    }
    
    // If user changed, reset
    if (_currentUserId != null && _currentUserId != userId) {
      debugPrint('🟡 [OrderService] User changed from $_currentUserId to $userId, resetting...');
      _localOrders = [];
      _isInitialized = false;
    }
    
    debugPrint('🔵 [OrderService] initialize START for user: $userId');
    _currentUserId = userId;
    
    try {
      await _loadOrdersFromFirestore();
      _isInitialized = true;
      debugPrint('✅ [OrderService] initialize END - Loaded ${_localOrders.length} orders');
      // Don't notify listeners here - let getOrders() handle it to prevent infinite loop
    } catch (e) {
      debugPrint('🟡 [OrderService] Firestore load failed, loading local: $e');
      await _loadLocalOrders();
      _isInitialized = true;
      debugPrint('✅ [OrderService] initialize END - Loaded ${_localOrders.length} orders from local');
      // Don't notify listeners here - let getOrders() handle it to prevent infinite loop
    }
  }
  
  /// Load orders from Firestore
  Future<void> _loadOrdersFromFirestore() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('🟡 [OrderService] No user logged in, skipping Firestore load');
      _localOrders = [];
      notifyListeners();
      return;
    }
    
    try {
      debugPrint('🟢 [OrderService] Loading orders from Firestore for user: ${user.uid}');
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      _localOrders = ordersSnapshot.docs.map((doc) {
        return _orderFromFirestore(doc.data(), doc.id);
      }).toList();
      
      debugPrint('✅ [OrderService] Loaded ${_localOrders.length} orders from Firestore');
      // Don't notify listeners here to prevent infinite loop
      // Listeners will be notified when orders are actually updated (created, status changed, etc.)
    } catch (e) {
      debugPrint('🔴 [OrderService] Error loading from Firestore: $e');
      rethrow;
    }
  }
  
  /// Convert Firestore data to OrderModel
  OrderModel _orderFromFirestore(Map<String, dynamic> data, String docId) {
    // Parse items
    final itemsJson = data['items'] as List<dynamic>? ?? [];
    final items = itemsJson.map((itemJson) {
      final productJson = itemJson['product'] as Map<String, dynamic>? ?? {};
      final product = ProductModel(
        id: productJson['id']?.toString() ?? '',
        name: productJson['name']?.toString() ?? '',
        description: productJson['description']?.toString() ?? '',
        image: productJson['image']?.toString() ?? '',
        price: (productJson['price'] as num?)?.toDouble() ?? 0.0,
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
    final addressJson = data['deliveryAddress'] as Map<String, dynamic>? ?? {};
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
    final statusStr = data['status']?.toString().toLowerCase() ?? '';
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
      id: docId,
      orderNumber: data['orderNumber']?.toString() ?? docId,
      items: items,
      deliveryAddress: address,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: status,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      estimatedDelivery: data['estimatedDelivery'] != null
          ? (data['estimatedDelivery'] as Timestamp).toDate()
          : null,
      driverName: data['driverName']?.toString(),
      driverPhone: data['driverPhone']?.toString(),
    );
  }
  
  /// Convert OrderModel to Firestore data
  Map<String, dynamic> _orderToFirestore(OrderModel order) {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw ApiException('User must be logged in to save order');
    }
    
    return {
      'userId': user.uid, // Always ensure userId is set
      'orderNumber': order.orderNumber,
      'items': order.items.map((item) {
        return {
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
          'quantity': item.quantity,
          'customizations': item.customizations,
        };
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
      'createdAt': Timestamp.fromDate(order.createdAt),
      'estimatedDelivery': order.estimatedDelivery != null
          ? Timestamp.fromDate(order.estimatedDelivery!)
          : null,
      'driverName': order.driverName,
      'driverPhone': order.driverPhone,
    };
  }

  Future<void> _loadLocalOrders() async {
    debugPrint('📂 [OrderService] _loadLocalOrders START');
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersPrefsKey);
      if (ordersJson != null) {
        debugPrint('📂 [OrderService] Found orders JSON, length: ${ordersJson.length}');
        final decoded = jsonDecode(ordersJson) as List<dynamic>;
        debugPrint('📂 [OrderService] Decoded ${decoded.length} orders');
        _localOrders = decoded.map((json) => _orderFromJson(json as Map<String, dynamic>)).toList();
        debugPrint('✅ [OrderService] Loaded ${_localOrders.length} orders successfully');
        // Don't notify listeners here to prevent infinite loop
      } else {
        debugPrint('⚠️ [OrderService] No orders JSON found in SharedPreferences');
        _localOrders = [];
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [OrderService] Error loading local orders: $e');
      debugPrint('❌ [OrderService] Stack trace: $stackTrace');
      _localOrders = [];
    }
    debugPrint('📂 [OrderService] _loadLocalOrders END');
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

  /// Create order - uses Firestore only
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    required String addressId,
    required double subtotal,
    required double deliveryFee,
    double discount = 0,
    AddressModel? deliveryAddress,
  }) async {
    debugPrint('🟢 [OrderService] createOrder - Creating in Firestore');
    return await _createOrderInFirestore(
      items: items,
      addressId: addressId,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      deliveryAddress: deliveryAddress,
    );
  }
  
  /// Create order in Firestore
  Future<OrderModel> _createOrderInFirestore({
    required List<Map<String, dynamic>> items,
    required String addressId,
    required double subtotal,
    required double deliveryFee,
    double discount = 0,
    AddressModel? deliveryAddress,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw ApiException('User must be logged in to create order');
    }
    
    // Generate order ID and number
    final orderId = 'BK${DateTime.now().millisecondsSinceEpoch}';
    final orderNumber = 'BK${DateTime.now().millisecondsSinceEpoch}';
    
    // Parse items to CartItemModel
    final cartItems = items.map((itemJson) {
      // Support both formats: full product object or individual fields
      Map<String, dynamic> productJson;
      if (itemJson['product'] != null) {
        productJson = itemJson['product'] as Map<String, dynamic>;
      } else {
        // Fallback for old format
        productJson = {
          'id': itemJson['productId']?.toString() ?? '',
          'name': itemJson['productName']?.toString() ?? '',
          'image': itemJson['productImage']?.toString() ?? '',
          'price': itemJson['price'] ?? 0.0,
        };
      }
      
      final product = ProductModel(
        id: productJson['id']?.toString() ?? '',
        name: productJson['name']?.toString() ?? '',
        description: productJson['description']?.toString() ?? '',
        image: productJson['image']?.toString() ?? '',
        price: (productJson['price'] as num?)?.toDouble() ?? 0.0,
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
      
      debugPrint('🟢 [OrderService] Parsed product: ${product.name}, price: ${product.price}');
      
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
      address = MockData.addresses.first;
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
    );
    
    // Save to Firestore
    try {
      await _firestore.collection('orders').doc(orderId).set(_orderToFirestore(order));
      debugPrint('✅ [OrderService] Order created in Firestore: $orderId');
      
      // Create notification for order placed
      await _createOrderStatusNotification(orderId, orderNumber, OrderStatus.placed);
      
      // Start order progression simulation (will create notifications for each status change)
      _simulateOrderProgression(order);
      
      // Add to local list
      _localOrders.insert(0, order);
      notifyListeners();
      
      return order;
    } catch (e) {
      debugPrint('🔴 [OrderService] Failed to save order to Firestore: $e');
      // Fallback to local storage
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

    // Save to Firestore if user is logged in
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('orders').doc(orderId).set(_orderToFirestore(order));
        debugPrint('✅ [OrderService] Local order saved to Firestore: $orderId');
      } catch (e) {
        debugPrint('🟡 [OrderService] Failed to save local order to Firestore: $e');
      }
    }

    // Save locally
    _localOrders.insert(0, order);
    await _saveLocalOrders();
    notifyListeners();

    return order;
  }

  /// Simulate order status progression with notifications
  void _simulateOrderProgression(OrderModel order) {
    // Auto-confirm after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (_localOrders.any((o) => o.id == order.id)) {
        _updateOrderStatus(order.id, OrderStatus.confirmed);
      }
    });

    // Start preparing after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (_localOrders.any((o) => o.id == order.id && o.status == OrderStatus.confirmed)) {
        _updateOrderStatus(order.id, OrderStatus.preparing);
      }
    });

    // On the way after 1 minute
    Future.delayed(const Duration(minutes: 1), () {
      if (_localOrders.any((o) => o.id == order.id && o.status == OrderStatus.preparing)) {
        _updateOrderStatus(order.id, OrderStatus.onTheWay);
        // Assign driver
        _updateOrderDriver(order.id, 'Abebe Kebede', '+251 91 234 5678');
      }
    });

    // Delivered after 3 minutes (180 seconds) total
    Future.delayed(const Duration(minutes: 3), () {
      if (_localOrders.any((o) => o.id == order.id && o.status == OrderStatus.onTheWay)) {
        _updateOrderStatus(order.id, OrderStatus.delivered);
      }
    });
  }

  void _updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _localOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = _localOrders[index];
      final updatedOrder = OrderModel(
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
      _localOrders[index] = updatedOrder;
      
      // Update Firestore
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        _firestore.collection('orders').doc(orderId).update({
          'status': newStatus.toString().split('.').last,
          'updatedAt': FieldValue.serverTimestamp(),
        }).then((_) {
          // Create notification for order status change
          _createOrderStatusNotification(orderId, oldOrder.orderNumber, newStatus);
        }).catchError((e) {
          debugPrint('🟡 [OrderService] Failed to update order status in Firestore: $e');
        });
      }
      
      _saveLocalOrders();
      notifyListeners();
    }
  }
  
  /// Create notification for order status change
  Future<void> _createOrderStatusNotification(String orderId, String orderNumber, OrderStatus status) async {
    try {
      final notificationService = NotificationService();
      await notificationService.createOrderNotification(
        orderId: orderId,
        orderNumber: orderNumber,
        status: status.toString().split('.').last,
      );
    } catch (e) {
      debugPrint('🟡 [OrderService] Failed to create notification: $e');
    }
  }

  void _updateOrderDriver(String orderId, String driverName, String driverPhone) {
    final index = _localOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = _localOrders[index];
      final updatedOrder = OrderModel(
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
      _localOrders[index] = updatedOrder;
      
      // Update Firestore
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        _firestore.collection('orders').doc(orderId).update({
          'driverName': driverName,
          'driverPhone': driverPhone,
          'updatedAt': FieldValue.serverTimestamp(),
        }).catchError((e) {
          debugPrint('🟡 [OrderService] Failed to update driver in Firestore: $e');
        });
      }
      
      _saveLocalOrders();
      notifyListeners();
    }
  }

  /// Get all orders - uses Firestore only, filtered by current user
  Future<List<OrderModel>> getOrders() async {
    final user = _firebaseAuth.currentUser;
    
    // If no user, return empty list
    if (user == null) {
      debugPrint('🟡 [OrderService] No user logged in, returning empty list');
      _localOrders = [];
      return [];
    }
    
    // If user changed, re-initialize
    if (_currentUserId != user.uid) {
      debugPrint('🟡 [OrderService] User changed, re-initializing...');
      await initialize();
    }
    
    // If already initialized and have orders for this user, return them
    if (_isInitialized && _currentUserId == user.uid && _localOrders.isNotEmpty) {
      debugPrint('🟢 [OrderService] Returning cached orders: ${_localOrders.length}');
      return List.from(_localOrders);
    }
    
    try {
      // Load from Firestore
      debugPrint('🟢 [OrderService] Loading orders from Firestore for user: ${user.uid}');
      await _loadOrdersFromFirestore();
      return List.from(_localOrders);
    } catch (e) {
      debugPrint('🔴 [OrderService] Firestore load failed: $e');
      // Fallback to local storage only if Firestore fails
      if (_localOrders.isEmpty) {
        await _loadLocalOrders();
      }
      // Filter local orders by userId
      final filteredOrders = _localOrders.where((order) {
        // For local orders, we need to check if they belong to current user
        // Since local orders might not have userId, we'll return them all as fallback
        return true;
      }).toList();
      return filteredOrders;
    }
  }

  /// Get order by ID - uses Firestore first, falls back to local cache
  Future<OrderModel> getOrderById(String id) async {
    debugPrint('🔍 [OrderService] getOrderById START - OrderId: $id');
    
    // First, check Firestore
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        debugPrint('🔍 [OrderService] Fetching order from Firestore: $id');
        final orderDoc = await _firestore.collection('orders').doc(id).get();
        
        if (orderDoc.exists) {
          final orderData = orderDoc.data()!;
          // Verify the order belongs to the current user
          if (orderData['userId'] == user.uid) {
            final order = _orderFromFirestore(orderData, orderDoc.id);
            debugPrint('✅ [OrderService] Found order in Firestore - OrderNumber: ${order.orderNumber}, Status: ${order.status}');
            
            // Update local cache
            final index = _localOrders.indexWhere((o) => o.id == id);
            if (index != -1) {
              _localOrders[index] = order;
            } else {
              _localOrders.add(order);
            }
            
            return order;
          } else {
            debugPrint('⚠️ [OrderService] Order exists but belongs to different user');
          }
        } else {
          debugPrint('⚠️ [OrderService] Order not found in Firestore: $id');
        }
      } catch (e) {
        debugPrint('🔴 [OrderService] Error fetching from Firestore: $e');
      }
    }
    
    // Fallback: Check local cache
    debugPrint('🔍 [OrderService] Checking local cache...');
    debugPrint('🔍 [OrderService] Local orders count: ${_localOrders.length}');
    debugPrint('🔍 [OrderService] Local order IDs: ${_localOrders.map((o) => o.id).toList()}');
    
    try {
      final order = _localOrders.firstWhere((order) => order.id == id);
      debugPrint('✅ [OrderService] Found order in local cache - OrderNumber: ${order.orderNumber}, Status: ${order.status}');
      return order;
    } catch (notFoundError) {
      debugPrint('❌ [OrderService] Order not found in local cache');
      debugPrint('❌ [OrderService] Available IDs: ${_localOrders.map((o) => o.id).toList()}');
      
      // Last resort: Try loading from local storage
      await _loadLocalOrders();
      try {
        final order = _localOrders.firstWhere((order) => order.id == id);
        debugPrint('✅ [OrderService] Found order in local storage - OrderNumber: ${order.orderNumber}');
        return order;
      } catch (_) {
        throw ApiException('Order not found: $id');
      }
    }
  }

  /// Cancel order - uses Firestore only
  Future<OrderModel> cancelOrder(String id) async {
    debugPrint('🟢 [OrderService] cancelOrder - Canceling order: $id');
    final index = _localOrders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _updateOrderStatus(id, OrderStatus.cancelled);
      return _localOrders[index];
    }
    throw ApiException('Order not found: $id');
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


