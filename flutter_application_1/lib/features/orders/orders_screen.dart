import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/constants.dart';
import '../../data/models/models.dart';
import '../../services/order_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() {
    debugPrint('🟢 [OrdersScreen] createState called');
    try {
      return _OrdersScreenState();
    } catch (e, stackTrace) {
      debugPrint('🔴 [OrdersScreen] ERROR in createState: $e');
      debugPrint('🔴 [OrdersScreen] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _orderService = OrderService();
  
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  
  bool get _isTabControllerReady => _tabController != null;

  List<OrderModel> get _activeOrders {
    final active = _allOrders.where((order) {
      return order.status != OrderStatus.delivered && 
             order.status != OrderStatus.cancelled;
    }).toList();
    debugPrint('🟢 [OrdersScreen] _activeOrders getter: ${active.length} active orders');
    return active;
  }

  List<OrderModel> get _completedOrders {
    final completed = _allOrders.where((order) {
      return order.status == OrderStatus.delivered || 
             order.status == OrderStatus.cancelled;
    }).toList();
    debugPrint('🟢 [OrdersScreen] _completedOrders getter: ${completed.length} completed orders');
    return completed;
  }

  @override
  void initState() {
    debugPrint('🟢 [OrdersScreen] initState called');
    try {
      super.initState();
      debugPrint('🟢 [OrdersScreen] super.initState completed');
      
      if (!mounted) {
        debugPrint('🔴 [OrdersScreen] Widget not mounted after super.initState');
        return;
      }
      
      _tabController = TabController(length: 2, vsync: this);
      debugPrint('🟢 [OrdersScreen] TabController created');
      
      _orderService.addListener(_onOrdersChanged);
      debugPrint('🟢 [OrdersScreen] Listener added to order service');
      
      _loadOrders();
      debugPrint('🟢 [OrdersScreen] _loadOrders called');
    } catch (e, stackTrace) {
      debugPrint('🔴 [OrdersScreen] ERROR in initState: $e');
      debugPrint('🔴 [OrdersScreen] Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    debugPrint('🟡 [OrdersScreen] dispose called');
    try {
      _orderService.removeListener(_onOrdersChanged);
      _tabController?.dispose();
      super.dispose();
      debugPrint('🟡 [OrdersScreen] dispose completed');
    } catch (e, stackTrace) {
      debugPrint('🔴 [OrdersScreen] ERROR in dispose: $e');
      debugPrint('🔴 [OrdersScreen] Stack trace: $stackTrace');
    }
  }

  bool _isLoadingOrders = false; // Prevent infinite loop
  
  void _onOrdersChanged() {
    if (mounted && !_isLoadingOrders) {
      // Only reload if we're not already loading to prevent infinite loop
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    if (_isLoadingOrders) {
      debugPrint('🟡 [OrdersScreen] Already loading orders, skipping...');
      return;
    }
    
    debugPrint('🟢 [OrdersScreen] _loadOrders started');
    if (!mounted) {
      debugPrint('🔴 [OrdersScreen] Widget not mounted in _loadOrders, returning');
      return;
    }
    
    _isLoadingOrders = true;
    
    try {
      setState(() {
        _isLoading = true;
      });
      debugPrint('🟢 [OrdersScreen] Loading state set to true');

      // Get orders directly without re-initializing (which triggers listeners)
      debugPrint('🟢 [OrdersScreen] Fetching orders...');
      final orders = await _orderService.getOrders();
      debugPrint('🟢 [OrdersScreen] Orders fetched: ${orders.length} orders');
      
      if (mounted) {
        setState(() {
          _allOrders = orders;
          _isLoading = false;
        });
        debugPrint('🟢 [OrdersScreen] State updated with ${orders.length} orders');
      } else {
        debugPrint('🔴 [OrdersScreen] Widget not mounted after fetching orders');
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 [OrdersScreen] ERROR loading orders: $e');
      debugPrint('🔴 [OrdersScreen] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          // Show empty state instead of error - this is normal when no orders exist
          _allOrders = [];
          _isLoading = false;
        });
        debugPrint('🟢 [OrdersScreen] Error handled, showing empty state');
      }
    } finally {
      _isLoadingOrders = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟢 [OrdersScreen] build called - isLoading: $_isLoading, orders: ${_allOrders.length}, tabControllerReady: $_isTabControllerReady');
    
    if (!_isTabControllerReady) {
      debugPrint('🔴 [OrdersScreen] TabController not ready, showing loading');
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    try {
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
          controller: _tabController!,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                debugPrint('🟢 [OrdersScreen] Building TabBarView - active: ${_activeOrders.length}, completed: ${_completedOrders.length}');
                return TabBarView(
                  controller: _tabController!,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    // Active Orders Tab
                    _activeOrders.isEmpty
                        ? _buildEmptyState('No active orders', 'Your ongoing orders will appear here')
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(AppSizes.paddingM),
                              itemCount: _activeOrders.length,
                              itemBuilder: (context, index) {
                                debugPrint('🟢 [OrdersScreen] Building active order card at index: $index');
                                return _buildOrderCard(_activeOrders[index], isActive: true);
                              },
                            ),
                          ),

                    // Completed Orders Tab
                    _completedOrders.isEmpty
                        ? _buildEmptyState('No completed orders', 'Your order history will appear here')
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(AppSizes.paddingM),
                              itemCount: _completedOrders.length,
                              itemBuilder: (context, index) {
                                debugPrint('🟢 [OrdersScreen] Building completed order card at index: $index');
                                return _buildOrderCard(_completedOrders[index], isActive: false);
                              },
                            ),
                          ),
                  ],
                );
              },
            ),
    );
    } catch (e, stackTrace) {
      debugPrint('🔴 [OrdersScreen] ERROR in build: $e');
      debugPrint('🔴 [OrdersScreen] Stack trace: $stackTrace');
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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading orders', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text('$e', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      );
    }
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

  Widget _buildOrderCard(OrderModel order, {required bool isActive}) {
    debugPrint('🟢 [OrdersScreen] _buildOrderCard called for order: ${order.id}');
    try {
      final statusColor = _getStatusColor(order.status);
      final statusText = _getStatusText(order.status);
      final formattedDate = _formatDate(order.createdAt);
      final estimatedTime = order.estimatedDelivery != null
          ? _formatEstimatedTime(order.estimatedDelivery!)
          : null;

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
          // Order Header - Make it tappable to view details
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/order-detail',
                arguments: order.id,
              );
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusL),
              topRight: Radius.circular(AppSizes.radiusL),
            ),
            child: Padding(
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
                        'Order #${order.orderNumber}',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.totalItems} items • $formattedDate',
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
                      '${order.total.toStringAsFixed(0)} ETB',
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
          ),

          // Progress Indicator for Active Orders
          if (isActive && order.status != OrderStatus.cancelled) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                children: [
                  _buildProgressIndicator(order.status),
                  if (estimatedTime != null) ...[
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
                          'Estimated: $estimatedTime',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/order-track',
                          arguments: order.id,
                        );
                      },
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
                      onPressed: () {
                        // Reorder functionality - add items to cart
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Items added to cart'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
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
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/order-detail',
                        arguments: order.id,
                      );
                    },
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
    } catch (e, stackTrace) {
      debugPrint('🔴 [OrdersScreen] ERROR in _buildOrderCard: $e');
      debugPrint('🔴 [OrdersScreen] Stack trace: $stackTrace');
      return Container(
        margin: const EdgeInsets.all(AppSizes.paddingM),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Text('Error displaying order: $e'),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatEstimatedTime(DateTime estimatedDelivery) {
    final now = DateTime.now();
    final difference = estimatedDelivery.difference(now);

    if (difference.inMinutes < 0) {
      return 'Delivered';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return '$hours h ${minutes}min';
    }
  }

  Widget _buildProgressIndicator(OrderStatus status) {
    debugPrint('🟢 [OrdersScreen] _buildProgressIndicator called for status: $status');
    try {
      final steps = [
        OrderStatus.placed,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.onTheWay,
        OrderStatus.delivered,
      ];
      final currentIndex = steps.indexOf(status);
      // If status not found in steps (e.g., cancelled), default to 0
      final safeIndex = currentIndex >= 0 ? currentIndex : 0;
      debugPrint('🟢 [OrdersScreen] Progress indicator - currentIndex: $currentIndex, safeIndex: $safeIndex');

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Line between circles
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < safeIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isCompleted ? AppColors.primary : AppColors.border,
            ),
          );
        } else {
          // Circle
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex <= safeIndex;
          final isCurrent = stepIndex == safeIndex;
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
    } catch (e, stackTrace) {
      debugPrint('🔴 [OrdersScreen] ERROR in _buildProgressIndicator: $e');
      debugPrint('🔴 [OrdersScreen] Stack trace: $stackTrace');
      return const SizedBox.shrink();
    }
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

