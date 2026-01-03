import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../services/services.dart';
import '../../services/api/address_api_service.dart';
import '../../services/repository/data_repository.dart';
import '../../data/models/models.dart';
import '../../core/exceptions/api_exception.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cartService = CartService();
  final _orderService = OrderService();
  final _addressApi = AddressApiService();
  final _dataRepository = DataRepository();
  
  int _selectedPaymentIndex = 0;
  bool _isPlacingOrder = false;
  
  // Address text controllers
  final _streetController = TextEditingController();
  final _cityController = TextEditingController(text: 'Bahir Dar');
  final _landmarkController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Cash on Delivery',
      'icon': Icons.money,
      'subtitle': 'Pay when you receive your order',
    },
    {
      'name': 'Chapa',
      'icon': Icons.account_balance_wallet,
      'subtitle': 'Pay with Chapa mobile payment',
    },
  ];

  double get _subtotal => _cartService.subtotal;
  double get _deliveryFee => _cartService.deliveryFee;
  double get _total => _cartService.total;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _landmarkController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    // Validate cart
    if (_cartService.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your cart is empty'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate address fields
    if (_streetController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in your delivery address and phone number'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Create or get address
      String addressId;
      AddressModel? deliveryAddress;
      
      try {
        // Try to get existing addresses first
        final addresses = await _dataRepository.getAddresses();
        final matchingAddress = addresses.firstWhere(
          (addr) => addr.street == _streetController.text.trim() &&
                    addr.city == _cityController.text.trim(),
          orElse: () => AddressModel(
            id: '',
            label: 'Delivery',
            fullAddress: '${_streetController.text.trim()}, ${_cityController.text.trim()}',
            street: _streetController.text.trim(),
            city: _cityController.text.trim(),
            zipCode: '',
            latitude: 0.0,
            longitude: 0.0,
          ),
        );

        if (matchingAddress.id.isEmpty) {
          // Create new address
          final newAddress = await _addressApi.createAddress(matchingAddress);
          addressId = newAddress.id;
          deliveryAddress = newAddress;
        } else {
          addressId = matchingAddress.id;
          deliveryAddress = matchingAddress;
        }
      } catch (e) {
        // If address creation fails, use a temporary ID
        addressId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        deliveryAddress = AddressModel(
          id: addressId,
          label: 'Delivery',
          fullAddress: '${_streetController.text.trim()}, ${_cityController.text.trim()}',
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          zipCode: '',
          latitude: 0.0,
          longitude: 0.0,
        );
      }

      // Prepare order items
      final orderItems = _cartService.cartItems.map((item) {
        return {
          'productId': item.product.id,
          'productName': item.product.name,
          'productImage': item.product.image,
          'price': item.product.price,
          'quantity': item.quantity,
          'customizations': item.customizations,
        };
      }).toList();

      // Create order via OrderService (handles API + local fallback)
      final order = await _orderService.createOrder(
        items: orderItems,
        addressId: addressId,
        subtotal: _subtotal,
        deliveryFee: _deliveryFee,
        discount: 0,
        deliveryAddress: deliveryAddress,
      );

      // Clear cart after successful order
      _cartService.clearCart();

      // Reset loading state and show success dialog
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
        _showOrderSuccessDialog(order);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException ? e.message : 'Failed to place order. Please try again.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // Final safety check to ensure loading state is reset
      if (mounted && _isPlacingOrder) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  void _showOrderSuccessDialog(OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false, // Prevent back button from closing
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                Text(
                  'Order Placed!',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSizes.paddingS),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: Text(
                    'Your order #${order.orderNumber} has been placed successfully. Track your order to see the delivery status.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close dialog and navigate
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                      Navigator.of(context, rootNavigator: true).pushNamed(
                        '/order-track',
                        arguments: order.id,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    child: Text(
                      'Track Order',
                      style: AppTextStyles.buttonMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // For pushNamedAndRemoveUntil, we don't necessarily need to pop the dialog first 
                      // if we are using the rootNavigator to blow away the whole stack, 
                      // but it's cleaner to pop it to ensure ModalBarrier is removed correctly.
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                      
                      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                        '/main',
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Back to Home',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(AppStrings.checkout, style: AppTextStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Section - Text Input
            Text(
              AppStrings.deliveryAddress,
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppSizes.paddingM),
            _buildAddressForm(),
            const SizedBox(height: AppSizes.paddingL),

            // Payment Method Section
            Text(
              AppStrings.paymentMethod,
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppSizes.paddingM),
            ...List.generate(_paymentMethods.length, (index) {
              final payment = _paymentMethods[index];
              return _buildPaymentCard(
                payment['name'],
                payment['subtitle'],
                payment['icon'],
                isSelected: index == _selectedPaymentIndex,
                onTap: _isPlacingOrder ? null : () {
                  setState(() {
                    _selectedPaymentIndex = index;
                  });
                },
              );
            }),
            const SizedBox(height: AppSizes.paddingL),

            // Order Summary Section
            Text(
              AppStrings.orderSummary,
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow(AppStrings.subtotal, _subtotal),
                  const SizedBox(height: 12),
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
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Estimated Delivery
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Delivery',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '25-35 minutes',
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),

      // Place Order Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isPlacingOrder ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              elevation: 0,
            ),
            child: _isPlacingOrder
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    '${AppStrings.placeOrder} - ${_total.toStringAsFixed(0)} ETB',
                    style: AppTextStyles.buttonLarge,
                  ),
            ),
        ),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _streetController,
            label: 'Street Address *',
            hint: 'Enter your street address',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildTextField(
            controller: _cityController,
            label: 'City',
            hint: 'Enter your city',
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildTextField(
            controller: _landmarkController,
            label: 'Landmark (Optional)',
            hint: 'Near mosque, school, etc.',
            icon: Icons.place_outlined,
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number *',
            hint: '+251 9XX XXX XXXX',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: !_isPlacingOrder,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(
    String name,
    String subtitle,
    IconData icon, {
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.labelLarge),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        ),
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

