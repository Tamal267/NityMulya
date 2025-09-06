import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const int PORT = 3005;
  
  // Automatically detect if we're on emulator or real device
  static Future<bool> _isEmulator() async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid) return false;
    
    try {
      // Better emulator detection - check device properties
      final interfaces = await NetworkInterface.list();
      
      // Real devices typically have WiFi interface
      bool hasWlan = interfaces.any((i) => i.name.contains('wlan'));
      
      // If device has WiFi interface, it's likely a real device
      if (hasWlan) {
        print('📱 Real device detected: Has WiFi interface');
        return false;
      }
      
      // Fallback: Try to ping emulator gateway
      final result = await InternetAddress.lookup('10.0.2.2');
      return result.isNotEmpty;
    } catch (e) {
      print('📱 Assuming real device due to detection error');
      return false; // Assume real device if detection fails
    }
  }
  
  // Get local network IP automatically
  static Future<String> _getLocalIP() async {
    try {
      if (kIsWeb) return 'localhost';
      
      // Get all network interfaces
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          final ip = addr.address;
          // Look for private network IPs (most common for local networks)
          if (ip.startsWith('192.168.') || 
              ip.startsWith('10.') ||
              ip.startsWith('172.')) {
            print('🌐 Found local IP: $ip');
            return ip;
          }
        }
      }
      
      return 'localhost';
    } catch (e) {
      print('❌ Error getting local IP: $e');
      return 'localhost';
    }
  }
  
  // Smart base URL detection
  static Future<String> getBaseUrl() async {
    if (kIsWeb) {
      return 'http://localhost:$PORT';
    } else if (Platform.isAndroid) {
      final isEmu = await _isEmulator();
      if (isEmu) {
        print('📱 Detected: Android Emulator');
        return 'http://10.0.2.2:$PORT';
      } else {
        print('📱 Detected: Physical Android Device');
        final localIP = await _getLocalIP();
        return 'http://$localIP:$PORT';
      }
    } else {
      return 'http://localhost:$PORT';
    }
  }
  
  // Dynamic URLs to try in order
  static Future<List<String>> getPossibleUrls() async {
    final localIP = await _getLocalIP();
    
    return [
      await getBaseUrl(),             // Smart detected URL
      'http://$localIP:$PORT',        // Current network IP
      'http://localhost:$PORT',       // Local
      'http://127.0.0.1:$PORT',      // Loopback
      'http://10.0.2.2:$PORT',       // Android emulator
    ];
  }
  
  // Smart URL with automatic testing and fallback
  static Future<String> getWorkingUrl() async {
    print('🔍 Starting smart URL detection...');
    
    // Get all possible URLs
    final urls = await getPossibleUrls();
    
    // Try each URL
    for (String url in urls) {
      print('🌐 Testing: $url');
      if (await _testUrl(url)) {
        print('✅ Working URL found: $url');
        return url;
      }
    }
    
    // If all fail, return the smart detected one
    final fallback = await getBaseUrl();
    print('⚠️ No working URL found, using fallback: $fallback');
    return fallback;
  }
  
  // Test if URL is reachable
  static Future<bool> _testUrl(String url) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      
      final request = await client.getUrl(Uri.parse('$url/api/health'));
      final response = await request.close();
      
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Complaint submission endpoint
  static String complaintsSubmitEndpoint(String baseUrl) => '$baseUrl/api/complaints/submit';
}
