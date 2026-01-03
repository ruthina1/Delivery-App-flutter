import 'api_client.dart';
import '../../core/exceptions/api_exception.dart';

/// API Service for Favorites
class FavoriteApiService {
  final _apiClient = ApiClient();

  Future<List<String>> getFavorites() async {
    try {
      final response = await _apiClient.get('/favorites');
      final data = response['data'] ?? response;
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      if (data is Map && data['productIds'] != null) {
        return (data['productIds'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch favorites: ${e.toString()}');
    }
  }

  Future<void> addFavorite(String productId) async {
    try {
      await _apiClient.post('/favorites', body: {'productId': productId});
    } catch (e) {
      throw ApiException('Failed to add favorite: ${e.toString()}');
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      await _apiClient.delete('/favorites/$productId');
    } catch (e) {
      throw ApiException('Failed to remove favorite: ${e.toString()}');
    }
  }
}

