import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../data/models/models.dart';
import '../../services/order_service.dart';
import '../../core/exceptions/api_exception.dart';
import '../cart/widgets/cart_item_widget.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _orderService = OrderService();
  OrderModel? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _orderService.addListener(_onOrderChanged);
    _loadOrder();
  }

  @override
  void dispose() {
    _orderService.removeListener(_onOrderChanged);
    super.dispose();
  }

  void _onOrderChanged() {
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _orderService.initialize();
      final order = await _orderService.getOrderById(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e is ApiException ? e.message : 'Failed to load order';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Order Details', style: AppTextStyles.heading3),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Order Details', style: AppTextStyles.heading3),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 80)),
              const SizedBox(height: AppSizes.paddingL),
              Text(
                _errorMessage ?? 'Order not found',
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingL),
              ElevatedButton(
                onPressed: _loadOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order Details', style: AppTextStyles.heading3),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              margin: const EdgeInsets.all(AppSizes.paddingM),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order #${order.orderNumber}', style: AppTextStyles.heading3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(order.status),
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    'Placed on ${_formatDate(order.createdAt)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Order Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Text('Items', style: AppTextStyles.heading4),
            ),
            const SizedBox(height: AppSizes.paddingS),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS / 2,
              ),
              child: CartItemWidget(
                item: item,
                onQuantityChanged: (_) {},
                onRemove: () {},
              ),
            )),

            // Delivery Address
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              margin: const EdgeInsets.all(AppSizes.paddingM),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: AppSizes.paddingS),
                      Text('Delivery Address', style: AppTextStyles.heading4),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    order.deliveryAddress.fullAddress,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              margin: const EdgeInsets.all(AppSizes.paddingM),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSizes.paddingM),
                  _buildSummaryRow('Subtotal', order.subtotal),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Delivery Fee', order.deliveryFee, isFree: order.deliveryFee == 0),
                  if (order.discount > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow('Discount', -order.discount),
                  ],
                  const Divider(height: 24),
                  _buildSummaryRow('Total', order.total, isTotal: true),
                ],
              ),
            ),

            // Driver Info (if order is on the way)
            if (order.status == OrderStatus.onTheWay && order.driverName != null)
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                margin: const EdgeInsets.all(AppSizes.paddingM),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.delivery_dining, color: AppColors.primary),
                        const SizedBox(width: AppSizes.paddingS),
                        Text('Driver Info', style: AppTextStyles.heading4),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(order.driverName!, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 4),
                    Text(order.driverPhone!, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: order.status == OrderStatus.onTheWay ||
              order.status == OrderStatus.preparing ||
              order.status == OrderStatus.confirmed
          ? Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/order-track', arguments: widget.orderId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                  child: Text('Track Order', style: AppTextStyles.buttonLarge),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.heading4
              : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          isFree ? 'FREE' : '${amount.toStringAsFixed(0)} ETB',
          style: isTotal
              ? AppTextStyles.priceMain
              : isFree
                  ? AppTextStyles.labelLarge.copyWith(color: AppColors.success)
                  : AppTextStyles.labelLarge,
        ),
      ],
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On The Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

