import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../data/models/models.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  // Get emoji based on category
  String _getProductEmoji() {
    switch (product.categoryId) {
      case 'cat_1':
        return '🍔';
      case 'cat_2':
        return '🍟';
      case 'cat_3':
        return '🥤';
      case 'cat_4':
        return '🍦';
      case 'cat_5':
        return '🍱';
      case 'cat_6':
        return '🥗';
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
            // Product Image - Fixed height instead of flex
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusL),
                        topRight: Radius.circular(AppSizes.radiusL),
                      ),
                    ),
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: Center(
                        child: Text(
                          _getProductEmoji(),
                          style: const TextStyle(fontSize: 55),
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
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details - Use Expanded to fill remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Rating & Time
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.ratingStar,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toString(),
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product.preparationTime}m',
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),

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
                                style: AppTextStyles.priceSmall.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
