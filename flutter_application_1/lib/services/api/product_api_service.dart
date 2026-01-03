import '../../data/models/models.dart';
import 'api_client.dart';
import '../../core/exceptions/api_exception.dart';

/// API Service for Products
class ProductApiService {
  final _apiClient = ApiClient();

  Future<List<ProductModel>> getProducts({
    String? categoryId,
    bool? isPopular,
    bool? isFeatured,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isPopular != null) queryParams['isPopular'] = isPopular.toString();
      if (isFeatured != null) queryParams['isFeatured'] = isFeatured.toString();

      final response = await _apiClient.get(
        '/products',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final data = response['data'] as List<dynamic>? ?? response['products'] as List<dynamic>? ?? [];
      return data.map((json) => _productFromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch products: ${e.toString()}');
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiClient.get('/products/$id');
      final data = response['data'] ?? response;
      return _productFromJson(data);
    } catch (e) {
      throw ApiException('Failed to fetch product: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _apiClient.get(
        '/products/search',
        queryParameters: {'q': query},
      );
      final data = response['data'] as List<dynamic>? ?? response['products'] as List<dynamic>? ?? [];
      return data.map((json) => _productFromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to search products: ${e.toString()}');
    }
  }

  ProductModel _productFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ProductModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        originalPrice: (json['originalPrice'] as num?)?.toDouble(),
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        categoryId: json['categoryId']?.toString() ?? '',
        ingredients: (json['ingredients'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        isPopular: json['isPopular'] as bool? ?? false,
        isFeatured: json['isFeatured'] as bool? ?? false,
        preparationTime: (json['preparationTime'] as num?)?.toInt() ?? 0,
        calories: (json['calories'] as num?)?.toInt() ?? 0,
      );
    }
    throw ApiException('Invalid product data format');
  }
}

