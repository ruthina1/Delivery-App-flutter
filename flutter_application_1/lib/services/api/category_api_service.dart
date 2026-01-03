import '../../data/models/models.dart';
import 'api_client.dart';
import '../../core/exceptions/api_exception.dart';

/// API Service for Categories
class CategoryApiService {
  final _apiClient = ApiClient();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      final data = response['data'] as List<dynamic>? ?? response['categories'] as List<dynamic>? ?? [];
      return data.map((json) => _categoryFromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch categories: ${e.toString()}');
    }
  }

  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await _apiClient.get('/categories/$id');
      final data = response['data'] ?? response;
      return _categoryFromJson(data);
    } catch (e) {
      throw ApiException('Failed to fetch category: ${e.toString()}');
    }
  }

  CategoryModel _categoryFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CategoryModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        icon: json['icon']?.toString() ?? '🍔',
        image: json['image']?.toString() ?? '',
      );
    }
    throw ApiException('Invalid category data format');
  }
}

