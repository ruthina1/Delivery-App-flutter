import 'cart_item_model.dart';
import 'address_model.dart';

/// Order status enum
enum OrderStatus {
  placed,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled,
}

/// Order model
class OrderModel {
  final String id;
  final String orderNumber;
  final List<CartItemModel> items;
  final AddressModel deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? driverName;
  final String? driverPhone;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.total,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    this.driverName,
    this.driverPhone,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

