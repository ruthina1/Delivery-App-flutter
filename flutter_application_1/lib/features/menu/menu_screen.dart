import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../home/widgets/product_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategoryId = 'cat_1';
  String? _sortBy;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: MockData.categories.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCategoryId = MockData.categories[_tabController.index].id;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filter', style: AppTextStyles.heading3),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _sortBy = null;
                        });
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text('Reset', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingL),
                Text('Sort By', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSizes.paddingS),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Popular'),
                      selected: _sortBy == 'popular',
                      onSelected: (selected) {
                        setModalState(() {
                          _sortBy = selected ? 'popular' : null;
                        });
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                    FilterChip(
                      label: const Text('Price: Low to High'),
                      selected: _sortBy == 'price_low',
                      onSelected: (selected) {
                        setModalState(() {
                          _sortBy = selected ? 'price_low' : null;
                        });
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                    FilterChip(
                      label: const Text('Price: High to Low'),
                      selected: _sortBy == 'price_high',
                      onSelected: (selected) {
                        setModalState(() {
                          _sortBy = selected ? 'price_high' : null;
                        });
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                    FilterChip(
                      label: const Text('Rating'),
                      selected: _sortBy == 'rating',
                      onSelected: (selected) {
                        setModalState(() {
                          _sortBy = selected ? 'rating' : null;
                        });
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingL),
              ],
            ),
          );
        },
      ),
    );
  }

  List<ProductModel> _getFilteredProducts() {
    List<ProductModel> products = List.from(MockData.getProductsByCategory(_selectedCategoryId));
    
    if (_sortBy != null) {
      switch (_sortBy) {
        case 'price_low':
          products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          products.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          products.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'popular':
          products.sort((a, b) {
            if (a.isPopular && !b.isPopular) return -1;
            if (!a.isPopular && b.isPopular) return 1;
            return 0;
          });
          break;
      }
    }
    
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Menu',
          style: AppTextStyles.heading3,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () {
              _showFilterDialog(context);
            },
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppTextStyles.labelLarge,
            unselectedLabelStyle: AppTextStyles.labelMedium,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            tabs: MockData.categories.map((category) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.icon),
                    const SizedBox(width: 6),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          final filteredProducts = _getFilteredProducts();
          
          if (filteredProducts.isEmpty) {
            return _buildEmptyState();
          }
          
          // Apply sorting
          List<ProductModel> sortedProducts = List.from(filteredProducts);
          if (_sortBy != null) {
            switch (_sortBy) {
              case 'price_low':
                sortedProducts.sort((a, b) => a.price.compareTo(b.price));
                break;
              case 'price_high':
                sortedProducts.sort((a, b) => b.price.compareTo(a.price));
                break;
              case 'rating':
                sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
                break;
              case 'popular':
                sortedProducts.sort((a, b) {
                  if (a.isPopular && !b.isPopular) return -1;
                  if (!a.isPopular && b.isPopular) return 1;
                  return 0;
                });
                break;
            }
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: AppSizes.paddingM,
              mainAxisSpacing: AppSizes.paddingM,
            ),
            itemCount: sortedProducts.length,
            itemBuilder: (context, index) {
              final product = sortedProducts[index];
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
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🍽️',
            style: TextStyle(fontSize: 80),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            'No items found',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            'Check back later for new items!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

