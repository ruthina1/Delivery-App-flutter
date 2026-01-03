import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/constants.dart';
import '../../data/models/models.dart';
import '../../services/services.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final String? heroTag;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.heroTag,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  final Set<String> _selectedAddons = {};
  bool _isFavorite = false;
  final _cartService = CartService();

  // Mock add-ons data (prices in ETB)
  final List<Map<String, dynamic>> _addons = [
    {'name': 'Extra Cheese', 'price': 50.0},
    {'name': 'Bacon', 'price': 80.0},
    {'name': 'Avocado', 'price': 60.0},
    {'name': 'Jalapeños', 'price': 30.0},
    {'name': 'Caramelized Onions', 'price': 40.0},
    {'name': 'Extra Patty', 'price': 120.0},
  ];

  double get _addonsTotal {
    double total = 0;
    for (var addon in _addons) {
      if (_selectedAddons.contains(addon['name'])) {
        total += addon['price'] as double;
      }
    }
    return total;
  }

  double get _totalPrice => (widget.product.price + _addonsTotal) * _quantity;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _toggleAddon(String addonName) {
    setState(() {
      if (_selectedAddons.contains(addonName)) {
        _selectedAddons.remove(addonName);
      } else {
        _selectedAddons.add(addonName);
      }
    });
  }

  void _addToCart() {
    // Add selected addons as customizations
    final customizations = _selectedAddons.toList();
    
    // Add to cart service
    _cartService.addToCart(
      widget.product,
      quantity: _quantity,
      customizations: customizations,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${widget.product.name} added to cart!',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  // Get appropriate emoji based on product name/category
  String _getProductEmoji() {
    final name = widget.product.name.toLowerCase();
    
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
    
    switch (widget.product.categoryId) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.paddingL),
                  _buildProductHeader(),
                  const SizedBox(height: AppSizes.paddingM),
                  _buildPriceAndInfo(),
                  const SizedBox(height: AppSizes.paddingL),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSizes.paddingL),
                  _buildDescription(),
                  const SizedBox(height: AppSizes.paddingL),
                  _buildIngredients(),
                  const SizedBox(height: AppSizes.paddingL),
                  _buildAddons(),
                  const SizedBox(height: AppSizes.paddingL),
                  _buildQuantitySelector(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Hero(
              tag: widget.heroTag ?? 'product_${widget.product.id}',
              child: CachedNetworkImage(
                imageUrl: widget.product.image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryLight.withValues(alpha: 0.15),
                        AppColors.primaryLight.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getProductEmoji(),
                      style: const TextStyle(fontSize: 140),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryLight.withValues(alpha: 0.15),
                        AppColors.primaryLight.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getProductEmoji(),
                      style: const TextStyle(fontSize: 140),
                    ),
                  ),
                ),
              ),
            ),
            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            if (widget.product.hasDiscount)
              Positioned(
                top: 100,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '-${widget.product.discountPercentage.toStringAsFixed(0)}% OFF',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ratingStar.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.ratingStar,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.product.rating.toString(),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${widget.product.reviewCount} reviews)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isFavorite
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? AppColors.error : AppColors.textLight,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.product.hasDiscount)
                Text(
                  '${widget.product.originalPrice!.toStringAsFixed(0)} ETB',
                  style: AppTextStyles.bodyMedium.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textLight,
                  ),
                ),
              Text(
                '${widget.product.price.toStringAsFixed(0)} ETB',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildInfoChip(
                Icons.access_time,
                '${widget.product.preparationTime} min',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.local_fire_department_outlined,
                '${widget.product.calories} kcal',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.description, style: AppTextStyles.heading4),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            widget.product.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.ingredients, style: AppTextStyles.heading4),
          const SizedBox(height: AppSizes.paddingM),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.ingredients.map((ingredient) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  ingredient,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add-ons', style: AppTextStyles.heading4),
              Text(
                'Optional',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...List.generate(_addons.length, (index) {
            final addon = _addons[index];
            final isSelected = _selectedAddons.contains(addon['name']);
            return _buildAddonItem(
              addon['name'] as String,
              addon['price'] as double,
              isSelected,
              () => _toggleAddon(addon['name'] as String),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddonItem(
    String name,
    double price,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '+${price.toStringAsFixed(0)} ETB',
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.quantity, style: AppTextStyles.heading4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildQuantityButton(
                    Icons.remove,
                    _decrementQuantity,
                    isEnabled: _quantity > 1,
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading3,
                    ),
                  ),
                  _buildQuantityButton(
                    Icons.add,
                    _incrementQuantity,
                    isEnabled: true,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled ? Colors.white : AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_totalPrice.toStringAsFixed(0)} ETB',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _addToCart,
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
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(AppStrings.addToCart, style: AppTextStyles.buttonLarge),
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

