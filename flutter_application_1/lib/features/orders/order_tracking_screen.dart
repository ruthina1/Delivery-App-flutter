import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../data/models/models.dart';
import '../../services/order_service.dart';
import '../../core/exceptions/api_exception.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _orderService = OrderService();
  OrderModel? _order;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _orderService.addListener(_onOrderChanged);
    _loadOrder();
    _startPolling();
  }

  @override
  void dispose() {
    _isPolling = false;
    _orderService.removeListener(_onOrderChanged);
    super.dispose();
  }

  void _onOrderChanged() {
    if (mounted) {
      _loadOrder();
    }
  }

  Future<void> _loadOrder() async {
    if (!mounted) return;
    
    try {
      await _orderService.initialize();
      final order = await _orderService.getOrderById(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : 'Failed to load order';
          _isLoading = false;
        });
      }
    }
  }

  void _startPolling() {
    // Poll for order updates every 5 seconds if order is active
    _isPolling = true;
    Future.delayed(const Duration(seconds: 5), () {
      if (_isPolling && mounted) {
        if (_order != null) {
          final status = _order!.status;
          if (status != OrderStatus.delivered && status != OrderStatus.cancelled) {
            _loadOrder();
            _startPolling(); // Continue polling
          }
        } else {
          // If order is null, try loading it again
          _loadOrder();
          _startPolling();
        }
      }
    });
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
          title: Text('Track Order', style: AppTextStyles.heading3),
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
          title: Text('Track Order', style: AppTextStyles.heading3),
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

    final steps = [
      {'status': OrderStatus.placed, 'title': 'Order Placed', 'icon': Icons.shopping_bag},
      {'status': OrderStatus.confirmed, 'title': 'Confirmed', 'icon': Icons.check_circle},
      {'status': OrderStatus.preparing, 'title': 'Preparing', 'icon': Icons.restaurant},
      {'status': OrderStatus.onTheWay, 'title': 'On The Way', 'icon': Icons.delivery_dining},
      {'status': OrderStatus.delivered, 'title': 'Delivered', 'icon': Icons.home},
    ];

    final currentIndex = steps.indexWhere((s) => s['status'] == _order!.status);
    // If status not found (e.g., cancelled), default to first step
    final safeCurrentIndex = currentIndex >= 0 ? currentIndex : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Track Order', style: AppTextStyles.heading3),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Info Card
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
                children: [
                  Text('Order #${_order!.orderNumber}', style: AppTextStyles.heading3),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    '${_order!.totalItems} items • ${_order!.total.toStringAsFixed(0)} ETB',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Tracking Timeline
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
                children: List.generate(steps.length, (index) {
                  final step = steps[index];
                  final isCompleted = index <= safeCurrentIndex;
                  final isCurrent = index == safeCurrentIndex;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? AppColors.primary : AppColors.background,
                          border: Border.all(
                            color: isCompleted ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          step['icon'] as IconData,
                          color: isCompleted ? Colors.white : AppColors.textLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'] as String,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            if (isCurrent && _order!.estimatedDelivery != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Estimated: ${_formatTime(_order!.estimatedDelivery!)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                            if (index < steps.length - 1)
                              Container(
                                margin: const EdgeInsets.only(top: 12, bottom: 12),
                                height: 40,
                                width: 2,
                                color: isCompleted ? AppColors.primary : AppColors.border,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            // Driver Info
            if (_order!.driverName != null)
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
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Driver', style: AppTextStyles.labelMedium),
                          const SizedBox(height: 4),
                          Text(_order!.driverName!, style: AppTextStyles.labelLarge),
                          Text(_order!.driverPhone!, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

