# API Integration Guide

This document explains how to use the different API approaches in the NityMulya app.

## Overview

We have fixed the "List<dynamic> is not a subtype of Map<String, dynamic>" error by updating the network layer to handle both List and Map responses from the backend.

## Available API Approaches

### 1. Network Helper (Simple Approach)
Located in `lib/network/network_helper.dart`

```dart
import 'package:nitymulya/network/network_helper.dart';

final apiClient = NetworkHelper();

// Returns dynamic (can be List or Map)
final response = await apiClient.get('/get_pricelist');
```

### 2. Price List API (Backward Compatible)
Located in `lib/network/pricelist_api.dart`

```dart
import 'package:nitymulya/network/pricelist_api.dart';

// Global function (backward compatible)
final result = await fetchPriceList();

// Class-based approach
final priceListApi = PriceListApi();
final result = await priceListApi.fetchPriceList();
final listData = await priceListApi.fetchPriceListAsArray();
```

### 3. Structured Service (Recommended)
Located in `lib/services/pricelist_service.dart`

```dart
import 'package:nitymulya/services/pricelist_service.dart';

// Get structured response with ApiResponse wrapper
final response = await PriceListService.fetchPriceList();
if (response.success) {
  print('Data: ${response.data}');
} else {
  print('Error: ${response.error}');
}

// Get data directly as List for UI consumption
try {
  final products = await PriceListService.fetchPriceListAsArray();
  // Use products in your UI
} catch (e) {
  print('Error: $e');
}
```

## Response Handling

The APIs now properly handle both response types:

### When API returns List<dynamic>:
```dart
// Original API response: [{"id": 1, "name": "Product 1"}, ...]
// Gets wrapped as: {"data": [{"id": 1, "name": "Product 1"}, ...]}
```

### When API returns Map<String, dynamic>:
```dart
// Original API response: {"products": [...], "total": 100}
// Used directly: {"products": [...], "total": 100}
```

## Environment Configuration

Make sure your `.env.local` file contains:
```
SERVER_URL=http://your-backend-server.com:5000
API_BASE_URL=http://your-backend-server.com:5000
```

## Error Handling

All API methods now include proper error handling:

1. Network errors (connection issues)
2. HTTP errors (4xx, 5xx status codes)
3. JSON parsing errors
4. Type validation errors

## Usage Examples

### Example 1: Simple data fetching
```dart
Future<void> loadPriceList() async {
  try {
    final products = await PriceListService.fetchPriceListAsArray();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _error = 'Failed to load products: $e';
      _isLoading = false;
    });
  }
}
```

### Example 2: Detailed response handling
```dart
Future<void> loadPriceListDetailed() async {
  final response = await PriceListService.fetchPriceList();
  
  if (response.success) {
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      final products = data['data'] as List;
      // Handle products list
    }
  } else {
    // Handle error
    showSnackBar('Error: ${response.error}');
  }
}
```

## Testing

Use the `DemoApiTestScreen` to test API functionality:

```dart
import 'package:nitymulya/screens/demo_api_test_screen.dart';

// Navigate to test screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DemoApiTestScreen()),
);
```

## Best Practices

1. **Use the structured service** (`PriceListService`) for new code
2. **Handle errors gracefully** with try-catch blocks  
3. **Show loading states** while API calls are in progress
4. **Cache data when appropriate** to reduce API calls
5. **Use environment variables** for all API endpoints
6. **Test API integration** with the demo screen before production use

## Migration Guide

If you have existing code using the old API, update it as follows:

### Old Code:
```dart
final response = await _apiClient.get('/get_pricelist');
// This would fail with List<dynamic> error
```

### New Code:
```dart
// Option 1: Use the service (recommended)
final products = await PriceListService.fetchPriceListAsArray();

// Option 2: Use backward compatible function
final response = await fetchPriceList();
if (!response.containsKey('error')) {
  // Handle success
}
```
