import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  print('🔍 Checking Authentication Status...\n');

  const storage = FlutterSecureStorage();

  try {
    final token = await storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      print('❌ NO AUTH TOKEN FOUND');
      print('   This is why orders aren\'t reaching the database!');
      print('   The user needs to login first.');
      print('\n💡 Solution: User must login through the customer login screen');
    } else {
      print('✅ Auth token found');
      print('   Token preview: ${token.substring(0, 20)}...');
      print('   Token length: ${token.length} characters');

      // Check if token looks valid (JWT tokens are typically 3 parts separated by dots)
      final parts = token.split('.');
      if (parts.length == 3) {
        print('   ✅ Token format looks valid (JWT format)');
      } else {
        print('   ⚠️  Token format might be invalid');
      }
    }
  } catch (e) {
    print('❌ Error reading auth token: $e');
  }
}
