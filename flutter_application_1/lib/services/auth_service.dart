import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/models.dart';
import '../core/exceptions/api_exception.dart';
import 'cart_service.dart';
import 'favorite_service.dart';
import 'order_service.dart';
import 'notification_service.dart';

/// Global authentication service for managing user state - Firebase only
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  static const String _userPrefsKey = 'current_user';
  static const String _tokenPrefsKey = 'auth_token';
  
  // Listen to Firebase Auth state changes
  void _setupAuthListener() {
    _firebaseAuth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserFromFirestore(firebaseUser.uid);
        // Re-initialize services when user logs in
        await _reinitializeServices();
      } else {
        _currentUser = null;
        _isAuthenticated = false;
        // Clear services when user logs out
        await _clearServices();
        notifyListeners();
      }
    });
  }
  
  /// Re-initialize all services when user logs in
  Future<void> _reinitializeServices() async {
    try {
      debugPrint('🟢 [AuthService] Re-initializing services for logged-in user');
      await OrderService().initialize();
      await CartService().initialize();
      await FavoriteService().initialize();
      await NotificationService().initialize();
      debugPrint('✅ [AuthService] Services re-initialized');
    } catch (e) {
      debugPrint('🔴 [AuthService] Error re-initializing services: $e');
    }
  }
  
  /// Clear services when user logs out
  Future<void> _clearServices() async {
    try {
      debugPrint('🟢 [AuthService] Clearing services for logged-out user');
      // Services will handle clearing themselves when they detect no user
    } catch (e) {
      debugPrint('🔴 [AuthService] Error clearing services: $e');
    }
  }

  /// Initialize - load saved user session
  Future<void> initialize() async {
    try {
      // Set up Firebase Auth listener
      _setupAuthListener();
      
      // Check Firebase Auth first
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _loadUserFromFirestore(firebaseUser.uid);
        return;
      }
      
      // Fallback: Load local users for backward compatibility (local storage only)
      await _loadLocalUsers();
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenPrefsKey);
      
      if (token != null && token.startsWith('local_token_')) {
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
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }
  }
  
  /// Load user data from Firestore
  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      debugPrint('🟢 [AuthService] Loading user from Firestore: $userId');
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        debugPrint('🟢 [AuthService] User document found: ${userData['email']}');
        
        _currentUser = UserModel(
          id: userId,
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
        debugPrint('✅ [AuthService] User loaded successfully: ${_currentUser!.email}');
        notifyListeners();
      } else {
        debugPrint('🟡 [AuthService] User document not found, creating...');
        // User document doesn't exist, create it from Firebase Auth user
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          await _createUserDocument(firebaseUser);
        } else {
          debugPrint('🔴 [AuthService] Firebase user is null, cannot create document');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 [AuthService] Error loading user from Firestore: $e');
      debugPrint('🔴 [AuthService] Stack trace: $stackTrace');
    }
  }
  
  /// Create user document in Firestore
  Future<void> _createUserDocument(User firebaseUser, {String? name, String? phone}) async {
    try {
      debugPrint('🟢 [AuthService] Creating Firestore document for: ${firebaseUser.uid}');
      
      final userData = {
        'id': firebaseUser.uid,
        'name': name ?? firebaseUser.displayName ?? '',
        'email': firebaseUser.email ?? '',
        'phone': phone ?? '',
        'avatarUrl': firebaseUser.photoURL,
        'favoriteProductIds': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('users').doc(firebaseUser.uid).set(
        userData,
        SetOptions(merge: true),
      );
      
      debugPrint('✅ [AuthService] Firestore document created successfully');
      
      // Load the user immediately after creating the document
      await _loadUserFromFirestore(firebaseUser.uid);
    } catch (e, stackTrace) {
      debugPrint('🔴 [AuthService] Error creating user document: $e');
      debugPrint('🔴 [AuthService] Stack trace: $stackTrace');
      rethrow; // Re-throw to let caller handle the error
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
      debugPrint('🟢 [AuthService] Starting signup for: $email');
      
      // Try Firebase Auth first
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('🟢 [AuthService] Firebase user created: ${userCredential.user?.uid}');
      
      if (userCredential.user != null) {
        // Update display name
        try {
          await userCredential.user!.updateDisplayName(name);
          debugPrint('🟢 [AuthService] Display name updated');
        } catch (e) {
          debugPrint('🟡 [AuthService] Failed to update display name: $e');
          // Continue even if display name update fails
        }
        
        // Create user document in Firestore and wait for it to complete
        debugPrint('🟢 [AuthService] Creating Firestore document...');
        try {
          await _createUserDocument(userCredential.user!, name: name, phone: phone);
          debugPrint('🟢 [AuthService] Firestore document created');
        } catch (firestoreError) {
          debugPrint('🟡 [AuthService] Firestore document creation failed: $firestoreError');
          debugPrint('🟡 [AuthService] Continuing with Firebase Auth user only...');
          // Continue even if Firestore fails - we can create the document later
          // For now, create a user model from Firebase Auth data
          _currentUser = UserModel(
            id: userCredential.user!.uid,
            name: name,
            email: userCredential.user!.email ?? email,
            phone: phone,
            avatarUrl: userCredential.user!.photoURL,
            favoriteProductIds: [],
          );
          _isAuthenticated = true;
          notifyListeners();
        }
        
        // Ensure user is loaded before returning
        if (_currentUser == null) {
          debugPrint('🟡 [AuthService] User not loaded yet, loading from Firestore...');
          try {
            await _loadUserFromFirestore(userCredential.user!.uid);
          } catch (e) {
            debugPrint('🟡 [AuthService] Failed to load from Firestore, using Firebase Auth data: $e');
            // Fallback: create user from Firebase Auth if Firestore fails
            if (_currentUser == null) {
              _currentUser = UserModel(
                id: userCredential.user!.uid,
                name: name,
                email: userCredential.user!.email ?? email,
                phone: phone,
                avatarUrl: userCredential.user!.photoURL,
                favoriteProductIds: [],
              );
              _isAuthenticated = true;
              notifyListeners();
            }
          }
        }
        
        // Verify user is authenticated
        if (_currentUser != null && _isAuthenticated) {
          debugPrint('✅ [AuthService] Signup successful, user: ${_currentUser!.email}');
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          debugPrint('🔴 [AuthService] User created but not authenticated properly');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      
      debugPrint('🔴 [AuthService] User credential is null');
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase signup failed: ${e.code} - ${e.message}');
      _isLoading = false;
      notifyListeners();
      
      // Fallback to local storage only
      return await _localSignUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
    } catch (e) {
      debugPrint('Unexpected signup error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in user
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try Firebase Auth first
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _loadUserFromFirestore(userCredential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase signin failed: ${e.code} - ${e.message}');
      _isLoading = false;
      notifyListeners();
      
      // Fallback to local storage only
      await _loadLocalUsers();
      return await _localSignIn(email: email, password: password);
    } catch (e) {
      debugPrint('Unexpected signin error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
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
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenPrefsKey);
      await prefs.remove(_userPrefsKey);
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
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser != null) {
        // Update in Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'name': updatedUser.name,
          'phone': updatedUser.phone,
          'avatarUrl': updatedUser.avatarUrl,
          'favoriteProductIds': updatedUser.favoriteProductIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Update display name in Firebase Auth
        if (updatedUser.name != firebaseUser.displayName) {
          await firebaseUser.updateDisplayName(updatedUser.name);
        }
        
        // Reload user data
        await _loadUserFromFirestore(firebaseUser.uid);
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // No Firebase user, cannot update
      throw ApiException('User must be logged in to update profile');
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
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }
}

