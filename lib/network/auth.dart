import 'package:nitymulya/network/network_helper.dart';

final _apiClient = NetworkHelper();

// Customer signup function
Future<Map<String, dynamic>> signupCustomer({
  required String fullName,
  required String email,
  required String contact,
  required String password,
  required double latitude,
  required double longitude,
  String? address,
}) async {
  try {
    // Prepare signup data
    final signupData = {
      'full_name': fullName,
      'email': email,
      'contact': contact,
      'password': password,
      'latitude': latitude,
      'longitude': longitude,
      'address': address ?? '', // Send empty string instead of null
    };

    // Send POST request to signup endpoint
    final response = await _apiClient.post('/signup_customer', signupData);

    // Handle successful response
    if (response is Map<String, dynamic>) {
      // Check if signup was successful
      if (response['success'] == true || response.containsKey('customer') || response.containsKey('user')) {
        return {
          'success': true,
          'message': response['message'] ?? 'Signup successful',
          'data': response,
        };
      }
      
      // Handle error response
      if (response.containsKey('error')) {
        return {
          'success': false,
          'message': response['error'],
        };
      }
      
      // Handle other response formats
      return {
        'success': true,
        'message': 'Signup completed',
        'data': response,
      };
    }
    
    // Unexpected response format
    return {
      'success': false,
      'message': 'Unexpected response from server',
    };
    
  } catch (e) {
    return {
      'success': false,
      'message': 'Signup failed: $e',
    };
  }
}

// Customer login function
Future<Map<String, dynamic>> loginCustomer({
  required String email,
  required String password,
}) async {
  try {
    final loginData = {
      'email': email,
      'password': password,
      'role': 'customer',
    };

    final response = await _apiClient.post('/login', loginData);

    if (response is Map<String, dynamic>) {
      // Check for successful login with token
      if (response.containsKey('token') || response['success'] == true) {
        // Store token if available
        if (response.containsKey('token')) {
          await _apiClient.setToken(response['token']);
        }
        
        return {
          'success': true,
          'message': response['message'] ?? 'Login successful',
          'token': response['token'],
          'user': response['user'] ?? response['customer'],
        };
      }
      
      // Handle error response
      if (response.containsKey('error')) {
        return {
          'success': false,
          'message': response['error'],
        };
      }
    }
    
    return {
      'success': false,
      'message': 'Invalid email or password',
    };
    
  } catch (e) {
    return {
      'success': false,
      'message': 'Login failed: $e',
    };
  }
}

// Verify OTP function (for email verification during signup)
Future<Map<String, dynamic>> verifyOTP({
  required String email,
  required String otp,
}) async {
  try {
    final otpData = {
      'email': email,
      'otp': otp,
    };

    final response = await _apiClient.post('/verify-otp', otpData);

    if (response is Map<String, dynamic>) {
      if (response['success'] == true || response.containsKey('token')) {
        // Store token if provided after verification
        if (response.containsKey('token')) {
          await _apiClient.setToken(response['token']);
        }
        
        return {
          'success': true,
          'message': response['message'] ?? 'OTP verified successfully',
          'token': response['token'],
        };
      }
      
      if (response.containsKey('error')) {
        return {
          'success': false,
          'message': response['error'],
        };
      }
    }
    
    return {
      'success': false,
      'message': 'Invalid OTP',
    };
    
  } catch (e) {
    return {
      'success': false,
      'message': 'OTP verification failed: $e',
    };
  }
}

// Send OTP function (for email verification)
Future<Map<String, dynamic>> sendOTP({
  required String email,
}) async {
  try {
    final otpData = {
      'email': email,
    };

    final response = await _apiClient.post('/send-otp', otpData);

    if (response is Map<String, dynamic>) {
      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'OTP sent successfully',
        };
      }
      
      if (response.containsKey('error')) {
        return {
          'success': false,
          'message': response['error'],
        };
      }
    }
    
    return {
      'success': true,
      'message': 'OTP sent to your email',
    };
    
  } catch (e) {
    return {
      'success': false,
      'message': 'Failed to send OTP: $e',
    };
  }
}

// Logout function
Future<void> logout() async {
  try {
    // Clear stored token
    await _apiClient.setToken('');
    
    // Optional: Call logout endpoint if your backend tracks sessions
    // await _apiClient.postWithToken('/logout', {});
  } catch (e) {
    // Handle logout error silently or log it
  }
}
