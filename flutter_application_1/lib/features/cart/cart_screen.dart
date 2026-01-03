import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../services/services.dart';
import 'widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();

  @override
  void initState() {
    super.initState();
    // Listen to cart changes
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  double get _subtotal => _cartService.subtotal;
  double get _deliveryFee => _cartService.deliveryFee;
  double get _total => _cartService.total;

  void _updateQuantity(int index, int newQuantity) {
    _cartService.updateQuantity(index, newQuantity);
  }

  void _removeItem(int index) {
    _cartService.removeFromCart(index);
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.cartItems;
    
    if (cartItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(AppStrings.myCart, style: AppTextStyles.heading3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildEmptyCart(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(AppStrings.myCart, style: AppTextStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _cartService.clearCart();
            },
            child: Text(
              'Clear All',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Cart Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
                  child: CartItemWidget(
                    item: item,
                    onQuantityChanged: (newQuantity) {
                      _updateQuantity(index, newQuantity);
                    },
                    onRemove: () => _removeItem(index),
                  ),
                );
              },
            ),
          ),

          // Bottom Section - Order Summary & Checkout
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Order Summary
                  _buildSummaryRow(AppStrings.subtotal, _subtotal),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    AppStrings.deliveryFee,
                    _deliveryFee,
                    isFree: _deliveryFee == 0,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                    child: Divider(color: AppColors.border),
                  ),
                  _buildSummaryRow(AppStrings.total, _total, isTotal: true),
                  const SizedBox(height: AppSizes.paddingL),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/checkout');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppStrings.checkout, style: AppTextStyles.buttonLarge),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🛒', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            AppStrings.emptyCart,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            AppStrings.emptyCartDesc,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingXL),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXL,
                vertical: AppSizes.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
            child: Text(
              'Browse Menu',
              style: AppTextStyles.buttonMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isFree = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.heading4
              : AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
        Text(
          isFree
              ? AppStrings.free
              : '${amount.toStringAsFixed(0)} ETB',
          style: isTotal
              ? AppTextStyles.priceMain
              : isFree
                  ? AppTextStyles.labelLarge.copyWith(color: AppColors.success)
                  : AppTextStyles.labelLarge,
        ),
      ],
    );
  }
}

