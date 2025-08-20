import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_models.dart';

class UserSession {
  static const String _userKey = 'current_user';
  static const String _userTypeKey = 'user_type';
  static const String _userLocationKey = 'user_location';
  static const String _tokenKey = 'auth_token';

  // Save user session
  static Future<void> saveUserSession({
    required String userId,
    required String userType,
    required Map<String, dynamic> userData,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _userKey,
        json.encode({
          'id': userId,
          'data': userData,
        }));
    await prefs.setString(_userTypeKey, userType);
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    }
  }

  // Get current user ID
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userData = json.decode(userJson);
      return userData['id'];
    }
    return null;
  }

  // Get current user type
  static Future<String?> getCurrentUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userData = json.decode(userJson);
      return userData['data'];
    }
    return null;
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save user location
  static Future<void> saveUserLocation(UserLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userLocationKey, json.encode(location.toMap()));
  }

  // Get user location
  static Future<UserLocation?> getUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString(_userLocationKey);
    if (locationJson != null) {
      final locationData = json.decode(locationJson);
      return UserLocation.fromMap(locationData);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final userId = await getCurrentUserId();
    return userId != null;
  }

  // Clear user session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_userLocationKey);
    await prefs.remove(_tokenKey);
  }

  // Create user model based on type
  static Future<dynamic> getCurrentUser() async {
    final userType = await getCurrentUserType();
    final userData = await getCurrentUserData();

    if (userType == null || userData == null) return null;

    switch (userType.toLowerCase()) {
      case 'customer':
        return Customer.fromMap(userData);
      case 'shop_owner':
        return ShopOwner.fromMap(userData);
      case 'wholesaler':
        return Wholesaler.fromMap(userData);
      default:
        return null;
    }
  }

  // Update user data
  static Future<void> updateUserData(Map<String, dynamic> newData) async {
    final userId = await getCurrentUserId();
    final userType = await getCurrentUserType();

    if (userId != null && userType != null) {
      await saveUserSession(
        userId: userId,
        userType: userType,
        userData: newData,
      );
    }
  }
}
