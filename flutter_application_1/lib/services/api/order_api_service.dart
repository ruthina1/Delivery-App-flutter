import '../../data/models/models.dart';
import 'api_client.dart';
import '../../core/exceptions/api_exception.dart';

/// API Service for Orders
class OrderApiService {
  final _apiClient = ApiClient();

  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    required String addressId,
    required double subtotal,
    required double deliveryFee,
    double discount = 0,
  }) async {
    try {
      final response = await _apiClient.post('/orders', body: {
        'items': items,
        'addressId': addressId,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discount': discount,
      });

      final data = response['data'] ?? response;
      return _orderFromJson(data);
    } catch (e) {
      throw ApiException('Failed to create order: ${e.toString()}');
    }
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _apiClient.get('/orders');
      final data = response['data'] as List<dynamic>? ?? response['orders'] as List<dynamic>? ?? [];
      return data.map((json) => _orderFromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch orders: ${e.toString()}');
    }
  }

  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _apiClient.get('/orders/$id');
      final data = response['data'] ?? response;
      return _orderFromJson(data);
    } catch (e) {
      throw ApiException('Failed to fetch order: ${e.toString()}');
    }
  }

  Future<OrderModel> cancelOrder(String id) async {
    try {
      final response = await _apiClient.put('/orders/$id/cancel');
      final data = response['data'] ?? response;
      return _orderFromJson(data);
    } catch (e) {
      throw ApiException('Failed to cancel order: ${e.toString()}');
    }
  }

  OrderModel _orderFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      // Parse cart items
      final itemsJson = json['items'] as List<dynamic>? ?? [];
      final items = itemsJson.map((itemJson) {
        // This is simplified - you may need to fetch full product details
        return CartItemModel(
          product: ProductModel(
            id: itemJson['productId']?.toString() ?? '',
            name: itemJson['productName']?.toString() ?? '',
            description: '',
            image: itemJson['productImage']?.toString() ?? '',
            price: (itemJson['price'] as num?)?.toDouble() ?? 0.0,
            rating: 0.0,
            reviewCount: 0,
            categoryId: '',
            ingredients: [],
            preparationTime: 0,
            calories: 0,
          ),
          quantity: (itemJson['quantity'] as num?)?.toInt() ?? 1,
          customizations: (itemJson['customizations'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        );
      }).toList();

      // Parse address
      final addressJson = json['deliveryAddress'] ?? json['address'];
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
        case 'on the way':
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
    throw ApiException('Invalid order data format');
  }
}

