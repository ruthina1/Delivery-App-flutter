import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart';
import '../../../services/services.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final String? heroTag;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.heroTag,
    this.onAddToCart,
  });

  // Get emoji fallback based on product name/category
  String _getProductEmoji() {
    final name = product.name.toLowerCase();
    
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
    
    // Category-based fallback
    switch (product.categoryId) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Increased height for better proportions
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.radiusL),
                      topRight: Radius.circular(AppSizes.radiusL),
                    ),
                    child: Hero(
                      tag: heroTag ?? 'product_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.primaryLight.withValues(alpha: 0.08),
                          child: Center(
                            child: Text(
                              _getProductEmoji(),
                              style: const TextStyle(fontSize: 55),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.primaryLight.withValues(alpha: 0.08),
                          child: Center(
                            child: Text(
                              _getProductEmoji(),
                              style: const TextStyle(fontSize: 55),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Discount Badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ListenableBuilder(
                      listenable: FavoriteService(),
                      builder: (context, child) {
                        final favoriteService = FavoriteService();
                        final isFavorite = favoriteService.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () => favoriteService.toggleFavorite(product.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFavorite ? AppColors.error : AppColors.textLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Product Details - Optimized spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Rating & Time
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.ratingStar,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.preparationTime} min',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Price & Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (product.hasDiscount)
                              Text(
                                '${product.originalPrice!.toStringAsFixed(0)} ETB',
                                style: AppTextStyles.caption.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textLight,
                                  fontSize: 10,
                                ),
                              ),
                            Text(
                              '${product.price.toStringAsFixed(0)} ETB',
                              style: AppTextStyles.priceSmall.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (onAddToCart != null) {
                            onAddToCart!();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
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
}

