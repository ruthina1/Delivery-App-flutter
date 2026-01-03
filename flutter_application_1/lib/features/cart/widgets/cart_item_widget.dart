import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  // Get emoji fallback based on product name for variety
  String _getProductEmoji() {
    final name = item.product.name.toLowerCase();
    
    // Ethiopian foods
    if (name.contains('doro') || name.contains('wet')) return '🍗';
    if (name.contains('tire') || name.contains('siga')) return '🥩';
    if (name.contains('kitfo')) return '🍖';
    if (name.contains('tibs')) return '🍛';
    
    // Pizza
    if (name.contains('pizza')) return '🍕';
    if (name.contains('margherita')) return '🍕';
    if (name.contains('pepperoni')) return '🍕';
    
    // Chips/Fries
    if (name.contains('fries') || name.contains('chips')) return '🍟';
    if (name.contains('sweet potato')) return '🍠';
    
    // Ice Cream
    if (name.contains('ice cream')) return '🍦';
    if (name.contains('vanilla') || name.contains('chocolate') || name.contains('strawberry')) {
      if (name.contains('ice')) return '🍦';
    }
    
    // Burgers
    if (name.contains('bacon') || name.contains('double')) return '🥓';
    if (name.contains('spicy') || name.contains('jalapeño')) return '🌶️';
    if (name.contains('mushroom')) return '🍄';
    if (name.contains('bbq')) return '🔥';
    if (name.contains('veggie') || name.contains('garden')) return '🥬';
    if (name.contains('burger')) return '🍔';
    
    // Drinks
    if (name.contains('milkshake')) return '🥛';
    if (name.contains('lemonade')) return '🍋';
    if (name.contains('coffee')) return '☕';
    
    switch (item.product.categoryId) {
      case 'cat_1': // Burgers
        return '🍔';
      case 'cat_2': // Pizza
        return '🍕';
      case 'cat_3': // Chips
        return '🍟';
      case 'cat_4': // Ice Cream
        return '🍦';
      case 'cat_5': // Ethiopian
        return '🍛';
      case 'cat_6': // Drinks
        return '🥤';
      default:
        return '🍔';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.paddingL),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: Container(
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
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              child: CachedNetworkImage(
                imageUrl: item.product.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Center(
                    child: Text(_getProductEmoji(), style: const TextStyle(fontSize: 40)),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Center(
                    child: Text(_getProductEmoji(), style: const TextStyle(fontSize: 40)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppTextStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.customizations.isNotEmpty)
                    Text(
                      item.customizations.join(', '),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.totalPrice.toStringAsFixed(0)} ETB',
                        style: AppTextStyles.priceSmall,
                      ),

                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuantityButton(
                              Icons.remove,
                              () => onQuantityChanged(item.quantity - 1),
                              isEnabled: item.quantity > 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: AppTextStyles.labelLarge,
                              ),
                            ),
                            _buildQuantityButton(
                              Icons.add,
                              () => onQuantityChanged(item.quantity + 1),
                              isEnabled: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
    IconData icon,
    VoidCallback onPressed, {
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? Colors.white : AppColors.textLight,
        ),
      ),
    );
  }
}

