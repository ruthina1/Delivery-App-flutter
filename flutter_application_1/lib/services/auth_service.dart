import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/models.dart';
import 'api/auth_api_service.dart';
import 'api/api_client.dart';
import '../core/exceptions/api_exception.dart';

/// Global authentication service for managing user state
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _authApi = AuthApiService();
  final _apiClient = ApiClient();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  static const String _userPrefsKey = 'current_user';
  static const String _tokenPrefsKey = 'auth_token';

  /// Initialize - load saved user session
  Future<void> initialize() async {
    try {
      // Load local users first
      await _loadLocalUsers();
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenPrefsKey);
      
      if (token != null) {
        // Check if it's a local token
        if (token.startsWith('local_token_')) {
          // Load local user session
          final userId = token.replaceFirst('local_token_', '');
          // Find user by ID
          for (var entry in _localUsers.entries) {
            if (entry.value['id'] == userId) {
              final userData = entry.value;
              _currentUser = UserModel(
                id: userData['id']?.toString() ?? '',
                name: userData['name']?.toString() ?? '',
                email: userData['email']?.toString() ?? '',
                phone: userData['phone']?.toString() ?? '',
                avatarUrl: userData['avatarUrl']?.toString(),
                favoriteProductIds: (userData['favoriteProductIds'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [],
              );
              _isAuthenticated = true;
              notifyListeners();
              return;
            }
          }
        } else {
          // Try API authentication
          _apiClient.setAuthToken(token);
          try {
            _currentUser = await _authApi.getCurrentUser();
            _isAuthenticated = true;
            notifyListeners();
            return;
          } catch (e) {
            // Token expired or invalid, clear it
            await prefs.remove(_tokenPrefsKey);
            await prefs.remove(_userPrefsKey);
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }
  }

  // Local storage for fallback authentication (when API is not available)
  final Map<String, Map<String, dynamic>> _localUsers = {};
  static const String _localUsersKey = 'local_users';

  /// Register a new user
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try API first
      final response = await _authApi.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      // Extract token and user from response
      final token = response['token']?.toString() ?? response['accessToken']?.toString();
      final userData = response['user'] ?? response;

      if (token != null) {
        await _saveSession(token, userData);
        _currentUser = _authApi.userFromJson(userData);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // API failed, use local fallback for development
      debugPrint('API signup failed, using local fallback: $e');
      return await _localSignUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
    }
  }

  /// Sign in user
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try API first
      final response = await _authApi.signIn(email: email, password: password);

      // Extract token and user from response
      final token = response['token']?.toString() ?? response['accessToken']?.toString();
      final userData = response['user'] ?? response;

      if (token != null) {
        await _saveSession(token, userData);
        _currentUser = _authApi.userFromJson(userData);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // API failed, use local fallback for development
      debugPrint('API signin failed, using local fallback: $e');
      // Ensure local users are loaded before attempting signin
      await _loadLocalUsers();
      return await _localSignIn(email: email, password: password);
    }
  }

  /// Local fallback signup (for development when API is not available)
  Future<bool> _localSignUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Load local users
      await _loadLocalUsers();

      // Check if user already exists
      if (_localUsers.containsKey(email)) {
        _isLoading = false;
        notifyListeners();
        return false; // User already exists
      }

      // Create new user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final user = UserModel(
        id: userId,
        name: name,
        email: email,
        phone: phone,
      );

      // Store user locally
      _localUsers[email] = {
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password, // In production, hash this!
        'avatarUrl': null,
        'favoriteProductIds': [],
      };

      await _saveLocalUsers();

      // Create a mock token
      final token = 'local_token_$userId';

      // Save session
      await _saveSession(token, {
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': null,
        'favoriteProductIds': [],
      });

      _currentUser = user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Local signup failed: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Local fallback signin (for development when API is not available)
  Future<bool> _localSignIn({
    required String email,
    required String password,
  }) async {
    try {
      // Load local users
      await _loadLocalUsers();

      // Check if user exists and password matches
      if (_localUsers.containsKey(email) &&
          _localUsers[email]!['password'] == password) {
        final userData = _localUsers[email]!;
        final user = UserModel(
          id: userData['id']?.toString() ?? '',
          name: userData['name']?.toString() ?? '',
          email: userData['email']?.toString() ?? '',
          phone: userData['phone']?.toString() ?? '',
          avatarUrl: userData['avatarUrl']?.toString(),
          favoriteProductIds: (userData['favoriteProductIds'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        );

        // Create a mock token
        final token = 'local_token_${user.id}';

        // Save session
        await _saveSession(token, userData);

        _currentUser = user;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false; // Invalid credentials
    } catch (e) {
      debugPrint('Local signin failed: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadLocalUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_localUsersKey);
      if (usersJson != null) {
        final decoded = jsonDecode(usersJson) as Map<String, dynamic>;
        _localUsers.clear();
        decoded.forEach((email, userData) {
          _localUsers[email] = userData as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Error loading local users: $e');
      _localUsers.clear();
    }
  }

  Future<void> _saveLocalUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = jsonEncode(_localUsers);
      await prefs.setString(_localUsersKey, usersJson);
    } catch (e) {
      debugPrint('Error saving local users: $e');
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenPrefsKey);
      await prefs.remove(_userPrefsKey);
      _apiClient.setAuthToken(null);
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
    
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateProfile(UserModel updatedUser) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _authApi.updateProfile(updatedUser);
      _currentUser = updated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw ApiException('Failed to update profile: ${e.toString()}');
    }
  }

  Future<void> _saveSession(String token, dynamic userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenPrefsKey, token);
      // Save user data as JSON string, not toString()
      if (userData is Map<String, dynamic>) {
        await prefs.setString(_userPrefsKey, jsonEncode(userData));
      } else if (userData is UserModel) {
        await prefs.setString(_userPrefsKey, jsonEncode({
          'id': userData.id,
          'name': userData.name,
          'email': userData.email,
          'phone': userData.phone,
          'avatarUrl': userData.avatarUrl,
          'favoriteProductIds': userData.favoriteProductIds,
        }));
      } else {
        // Fallback: try to convert to map
        await prefs.setString(_userPrefsKey, jsonEncode(userData));
      }
      _apiClient.setAuthToken(token);
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }
}

