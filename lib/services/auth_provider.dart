import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;

  // Initialize auth state
  Future<void> initialize() async {
    _setState(AuthState.loading);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.userTokenKey);
      final userJson = prefs.getString(AppConstants.userDataKey);
      
      if (token != null && userJson != null) {
        _apiService.setAuthToken(token);
        // TODO: Validate token with backend
        // For now, assume token is valid if it exists
        _user = User.fromJson(Map<String, dynamic>.from(
          // Parse userJson here - simplified for now
          {'id': '1', 'email': 'user@example.com', 'firstName': 'User', 'lastName': 'Name', 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()}
        ));
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    
    try {
      final response = await _apiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userTokenKey, token);
      await prefs.setString(AppConstants.userDataKey, userData.toString());
      
      // Set auth token and user
      _apiService.setAuthToken(token);
      _user = User.fromJson(userData);
      
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    _setState(AuthState.loading);
    
    try {
      final response = await _apiService.post('/auth/register', body: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      });
      
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userTokenKey, token);
      await prefs.setString(AppConstants.userDataKey, userData.toString());
      
      // Set auth token and user
      _apiService.setAuthToken(token);
      _user = User.fromJson(userData);
      
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setState(AuthState.loading);
    
    try {
      // Call logout endpoint
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
      debugPrint('Logout API call failed: $e');
    }
    
    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove(AppConstants.userDataKey);
    
    // Clear auth token and user
    _apiService.clearAuthToken();
    _user = null;
    
    _setState(AuthState.unauthenticated);
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    if (_user == null) return false;
    
    _setState(AuthState.loading);
    
    try {
      final response = await _apiService.put('/user/profile', body: {
        'firstName': firstName ?? _user!.firstName,
        'lastName': lastName ?? _user!.lastName,
        'phoneNumber': phoneNumber ?? _user!.phoneNumber,
        'dateOfBirth': dateOfBirth?.toIso8601String() ?? _user!.dateOfBirth?.toIso8601String(),
      });
      
      final userData = response['user'] as Map<String, dynamic>;
      _user = User.fromJson(userData);
      
      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userDataKey, userData.toString());
      
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Profile update failed: $e');
      return false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _setState(AuthState.loading);
    
    try {
      await _apiService.post('/auth/forgot-password', body: {
        'email': email,
      });
      
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError('Forgot password failed: $e');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _setState(AuthState.loading);
    
    try {
      await _apiService.post('/auth/reset-password', body: {
        'token': token,
        'password': newPassword,
      });
      
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError('Password reset failed: $e');
      return false;
    }
  }

  // Private methods
  void _setState(AuthState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _state = AuthState.error;
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
    }
  }
}
