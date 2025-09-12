import 'package:flutter/material.dart';
import 'package:nitymulya/network/auth.dart' as auth;
import 'package:nitymulya/network/network_helper.dart';
import 'package:nitymulya/utils/user_session.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userType;
  Map<String, dynamic>? _userData;
  String? _token;
  bool _isLoading = true;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userType => _userType;
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;
  bool get isLoading => _isLoading;

  // Initialize auth state from storage
  Future<void> initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      final isLoggedIn = await UserSession.isLoggedIn();
      
      if (isLoggedIn) {
        _userType = await UserSession.getCurrentUserType();
        _userData = await UserSession.getCurrentUserData();
        _token = await UserSession.getAuthToken();
        
        // Sync token to NetworkHelper if we have one
        if (_token != null) {
          final networkHelper = NetworkHelper();
          await networkHelper.setToken(_token!);
        }
        
        _isAuthenticated = true;
        
        print('🔐 Auth restored: userType=$_userType, isAuthenticated=$_isAuthenticated, token synced');
      } else {
        print('🔐 No saved auth session found');
        _isAuthenticated = false;
        
        // Clear any stale tokens
        final networkHelper = NetworkHelper();
        await networkHelper.clearToken();
      }
    } catch (e) {
      print('🔐 Error initializing auth: $e');
      _isAuthenticated = false;
      
      // Clear any stale tokens on error
      try {
        final networkHelper = NetworkHelper();
        await networkHelper.clearToken();
      } catch (clearError) {
        print('🔐 Error clearing stale token: $clearError');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      Map<String, dynamic> result;

      // Handle DNCRP-Admin login separately
      if (role == 'DNCRP-Admin') {
        if (email == 'DNCRP_Demo@govt.com' && password == 'DNCRP_Demo') {
          result = {
            'success': true,
            'message': 'DNCRP Admin login successful',
            'user': {
              'id': 'dncrp_admin_demo',
              'name': 'DNCRP Admin Demo',
              'email': email,
              'role': 'dncrp_admin'
            },
            'role': 'dncrp_admin',
            'token': 'dncrp_demo_token',
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid DNCRP credentials',
          };
        }
      } else {
        // Call backend login function for other roles
        result = await auth.loginUser(
          email: email,
          password: password,
          role: role,
        );
      }

      if (result['success'] == true) {
        final userData = result['user'];
        final userRole = result['role'] ?? role.toLowerCase();
        final userId = userData?['id']?.toString() ?? '';
        final token = result['token'];

        // Save user session
        await UserSession.saveUserSession(
          userId: userId,
          userType: userRole,
          userData: userData ?? {},
          token: token,
        );

        // Sync token to NetworkHelper
        if (token != null) {
          final networkHelper = NetworkHelper();
          await networkHelper.setToken(token);
        }

        // Update auth state
        _isAuthenticated = true;
        _userType = userRole;
        _userData = userData;
        _token = token;
        
        notifyListeners();
        
        print('🔐 Login successful: userType=$userRole, userId=$userId, token synced');
      }

      return result;
    } catch (e) {
      print('🔐 Login error: $e');
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Clear backend session (call auth.dart logout)
      await auth.logout();
      
      // Clear token from NetworkHelper
      final networkHelper = NetworkHelper();
      await networkHelper.clearToken();
      
      // Clear local session
      await UserSession.clearSession();
      
      // Update auth state
      _isAuthenticated = false;
      _userType = null;
      _userData = null;
      _token = null;
      
      notifyListeners();
      
      print('🔐 Logout successful - all tokens and session data cleared');
    } catch (e) {
      print('🔐 Logout error: $e');
    }
  }

  // Get home route based on user type
  String getHomeRoute() {
    if (!_isAuthenticated || _userType == null) {
      return '/';
    }

    switch (_userType!.toLowerCase()) {
      case 'customer':
        return '/home';
      case 'shop_owner':
      case 'shop owner':
        return '/shop-dashboard';
      case 'wholesaler':
        return '/wholesaler-dashboard';
      case 'dncrp_admin':
        return '/dncrp-dashboard';
      default:
        return '/';
    }
  }

  // Check if user should be redirected from root
  bool shouldRedirectFromRoot() {
    return _isAuthenticated && _userType != null;
  }
}