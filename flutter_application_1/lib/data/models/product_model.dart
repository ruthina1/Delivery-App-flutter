/// Product model for food items
class ProductModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String categoryId;
  final List<String> ingredients;
  final bool isPopular;
  final bool isFeatured;
  final int preparationTime; // in minutes
  final int calories;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.categoryId,
    required this.ingredients,
    this.isPopular = false,
    this.isFeatured = false,
    required this.preparationTime,
    required this.calories,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice! * 100);
  }
}

