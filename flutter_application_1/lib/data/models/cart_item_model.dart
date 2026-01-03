import 'product_model.dart';

/// Cart item model
class CartItemModel {
  final ProductModel product;
  int quantity;
  final List<String> customizations;
  final String? specialInstructions;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.customizations = const [],
    this.specialInstructions,
  });

  double get totalPrice => product.price * quantity;
}

