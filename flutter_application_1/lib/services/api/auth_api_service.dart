import '../../data/models/models.dart';
import 'api_client.dart';
import '../../core/exceptions/api_exception.dart';

/// API Service for Authentication
class AuthApiService {
  final _apiClient = ApiClient();

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post('/auth/signup', body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      return response['data'] ?? response;
    } catch (e) {
      throw ApiException('Failed to sign up: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post('/auth/signin', body: {
        'email': email,
        'password': password,
      });

      return response['data'] ?? response;
    } catch (e) {
      throw ApiException('Failed to sign in: ${e.toString()}');
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      final data = response['data'] ?? response;
      return _userFromJson(data);
    } catch (e) {
      throw ApiException('Failed to get current user: ${e.toString()}');
    }
  }

  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await _apiClient.put('/users/${user.id}', body: {
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'avatarUrl': user.avatarUrl,
      });

      final data = response['data'] ?? response;
      return _userFromJson(data);
    } catch (e) {
      throw ApiException('Failed to update profile: ${e.toString()}');
    }
  }

  UserModel userFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        avatarUrl: json['avatarUrl']?.toString(),
        favoriteProductIds: (json['favoriteProductIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    }
    throw ApiException('Invalid user data format');
  }

  UserModel _userFromJson(dynamic json) => userFromJson(json);
}

