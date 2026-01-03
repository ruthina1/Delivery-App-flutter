import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock orders data (prices in ETB)
  final List<Map<String, dynamic>> _activeOrders = [
    {
      'id': 'BK2024001',
      'status': OrderStatus.onTheWay,
      'items': 3,
      'total': 1150,
      'time': '25-35 min',
      'date': 'Today, 12:30 PM',
    },
  ];

  final List<Map<String, dynamic>> _completedOrders = [
    {
      'id': 'BK2024000',
      'status': OrderStatus.delivered,
      'items': 2,
      'total': 850,
      'time': 'Delivered',
      'date': 'Dec 13, 2024',
    },
    {
      'id': 'BK2023999',
      'status': OrderStatus.delivered,
      'items': 4,
      'total': 1750,
      'time': 'Delivered',
      'date': 'Dec 10, 2024',
    },
    {
      'id': 'BK2023998',
      'status': OrderStatus.cancelled,
      'items': 1,
      'total': 450,
      'time': 'Cancelled',
      'date': 'Dec 8, 2024',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(AppStrings.myOrders, style: AppTextStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelLarge,
          unselectedLabelStyle: AppTextStyles.labelMedium,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Orders Tab
          _activeOrders.isEmpty
              ? _buildEmptyState('No active orders', 'Your ongoing orders will appear here')
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  itemCount: _activeOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(_activeOrders[index], isActive: true);
                  },
                ),

          // Completed Orders Tab
          _completedOrders.isEmpty
              ? _buildEmptyState('No completed orders', 'Your order history will appear here')
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  itemCount: _completedOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(_completedOrders[index], isActive: false);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 80)),
          const SizedBox(height: AppSizes.paddingL),
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, {required bool isActive}) {
    final status = order['status'] as OrderStatus;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🍔', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id']}',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order['items']} items • ${order['date']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${order['total'].toStringAsFixed(0)} ETB',
                      style: AppTextStyles.priceSmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress Indicator for Active Orders
          if (isActive && status != OrderStatus.cancelled) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                children: [
                  _buildProgressIndicator(status),
                  const SizedBox(height: AppSizes.paddingM),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Estimated: ${order['time']}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            child: Row(
              children: [
                if (isActive)
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        AppStrings.trackOrder,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        AppStrings.reorder,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'View Details',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(OrderStatus status) {
    final steps = [
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];
    final currentIndex = steps.indexOf(status);

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Line between circles
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isCompleted ? AppColors.primary : AppColors.border,
            ),
          );
        } else {
          // Circle
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex <= currentIndex;
          final isCurrent = stepIndex == currentIndex;
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.primary : AppColors.background,
              border: Border.all(
                color: isCompleted ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : isCurrent
                    ? Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
          );
        }
      }),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.warning;
      case OrderStatus.onTheWay:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
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
}

