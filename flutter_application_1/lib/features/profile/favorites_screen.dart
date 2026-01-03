import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../services/services.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../home/widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoriteService = FavoriteService();
  List<ProductModel> _favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    _favoriteService.addListener(_onFavoritesChanged);
    _loadFavorites();
  }

  @override
  void dispose() {
    _favoriteService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      await _favoriteService.initialize();
      final favoriteIds = _favoriteService.favoriteProductIds;
      setState(() {
        _favoriteProducts = MockData.products
            .where((p) => favoriteIds.contains(p.id))
            .toList();
      });
    } catch (e) {
      // Use current favorite IDs even if service init fails
      final favoriteIds = _favoriteService.favoriteProductIds;
      setState(() {
        _favoriteProducts = MockData.products
            .where((p) => favoriteIds.contains(p.id))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _favoriteService,
      builder: (context, child) {

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(AppStrings.favorites, style: AppTextStyles.heading3),
          ),
          body: _favoriteProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('❤️', style: TextStyle(fontSize: 80)),
                      const SizedBox(height: AppSizes.paddingL),
                      Text(
                        'No favorites yet',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Text(
                        'Start adding your favorite items!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: AppSizes.paddingM,
                        mainAxisSpacing: AppSizes.paddingM,
                      ),
                      itemCount: _favoriteProducts.length,
                      itemBuilder: (context, index) {
                        final product = _favoriteProducts[index];
                        return ProductCard(
                          product: product,
                          heroTag: 'fav_${product.id}',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/product',
                              arguments: {
                                'product': product,
                                'heroTag': 'fav_${product.id}',
                              },
                            );
                          },
                        );
                      },
                    ),
        );
      },
    );
  }
}

