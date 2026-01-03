import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../home/widgets/product_card.dart';
import '../product/product_detail_screen.dart';
import '../home/widgets/search_bar_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = '';
  String? _selectedCategory;
  String? _sortBy;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _filteredProducts = MockData.products;
    
    // Check for initial category filter in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryId = ModalRoute.of(context)?.settings.arguments as String?;
      if (categoryId != null) {
        setState(() {
          _selectedCategory = categoryId;
          _applyFilters();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<ProductModel> results = MockData.products;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      results = results.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
            product.description.toLowerCase().contains(_searchQuery) ||
            product.ingredients.any((ing) => ing.toLowerCase().contains(_searchQuery));
      }).toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      results = results.where((product) => product.categoryId == _selectedCategory).toList();
    }

    // Sort filter
    if (_sortBy != null) {
      switch (_sortBy) {
        case 'price_low':
          results.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          results.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          results.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'popular':
          results.sort((a, b) {
            if (a.isPopular && !b.isPopular) return -1;
            if (!a.isPopular && b.isPopular) return 1;
            return 0;
          });
          break;
      }
    }

    setState(() {
      _filteredProducts = results;
    });
  }

  void _showFilterDialog() {
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
                          _selectedCategory = null;
                          _sortBy = null;
                        });
                        _applyFilters();
                      },
                      child: Text('Reset', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingL),
                Text('Category', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSizes.paddingS),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedCategory = null;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                    ),
                    ...MockData.categories.map((category) {
                      return FilterChip(
                        label: Text(category.name),
                        selected: _selectedCategory == category.id,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedCategory = selected ? category.id : null;
                          });
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingL),
                Text('Sort By', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSizes.paddingS),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Popular'),
                      selected: _sortBy == 'popular',
                      onSelected: (selected) {
                        setModalState(() {
                          _sortBy = selected ? 'popular' : null;
                        });
                        _applyFilters();
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
                        _applyFilters();
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
                        _applyFilters();
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
                        _applyFilters();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: 8,
          ),
          child: SearchBarWidget(
            controller: _searchController,
            onChanged: (value) {},
            onFilterTap: _showFilterDialog,
            autofocus: true,
          ),
        ),
      ),
      body: _filteredProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: AppSizes.paddingL),
                  Text(
                    'No results found',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    'Try searching with different keywords',
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
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ProductCard(
                  product: product,
                  heroTag: 'search_${product.id}',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/product',
                      arguments: {
                        'product': product,
                        'heroTag': 'search_${product.id}',
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

