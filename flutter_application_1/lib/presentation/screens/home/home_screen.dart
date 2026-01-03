import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../data/mock/mock_data.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Location & Cart
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                ),
                child: SearchBarWidget(
                  onTap: () {
                    Navigator.pushNamed(context, '/search');
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.paddingL),
            ),

            // Categories Section
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                title: AppStrings.categories,
                onSeeAll: () => Navigator.pushNamed(context, '/categories'),
              ),
            ),

            SliverToBoxAdapter(
              child: _buildCategories(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.paddingL),
            ),

            // Popular Items Section
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                title: AppStrings.popular,
                onSeeAll: () => Navigator.pushNamed(context, '/popular'),
              ),
            ),

            SliverToBoxAdapter(
              child: _buildPopularItems(context),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.paddingL),
            ),

            // Featured Section
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                title: AppStrings.featured,
                onSeeAll: () {},
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              sliver: _buildFeaturedGrid(context),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // Bottom padding for nav bar
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Row(
        children: [
          // Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.deliveryTo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Bahir Dar, Ethiopia',
                        style: AppTextStyles.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notification & Cart
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/cart'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Stack(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
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

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.heading3),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              AppStrings.seeAll,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: MockData.categories.length,
        itemBuilder: (context, index) {
          final category = MockData.categories[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == MockData.categories.length - 1
                  ? 0
                  : AppSizes.paddingM,
            ),
            child: CategoryCard(
              category: category,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/category',
                  arguments: category,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularItems(BuildContext context) {
    final popularProducts = MockData.popularProducts;
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: popularProducts.length,
        itemBuilder: (context, index) {
          final product = popularProducts[index];
          return Padding(
            padding: EdgeInsets.only(
              right:
                  index == popularProducts.length - 1 ? 0 : AppSizes.paddingM,
            ),
            child: SizedBox(
              width: 180,
              child: ProductCard(
                product: product,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: product,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  SliverGrid _buildFeaturedGrid(BuildContext context) {
    final featuredProducts = MockData.featuredProducts;
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: AppSizes.paddingM,
        mainAxisSpacing: AppSizes.paddingM,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = featuredProducts[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product',
                arguments: product,
              );
            },
          );
        },
        childCount: featuredProducts.length,
      ),
    );
  }
}
