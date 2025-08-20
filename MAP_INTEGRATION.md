# Map Integration Documentation

## Overview

This document describes the implementation of map functionality in the NityMulya Flutter project using the Geoapify API.

## API Configuration

- **Service**: Geoapify
- **API Key**: `a2621109b87d48c0a55f0c71dce604d8`
- **Base URL**: `https://api.geoapify.com/v1`

## Dependencies Added

```yaml
dependencies:
  flutter_map: ^7.0.2 # Interactive map widget
  latlong2: ^0.9.1 # Latitude/longitude calculations
  geocoding: ^3.0.0 # Address geocoding
  url_launcher: ^6.2.4 # Launch external apps
  geolocator: ^10.1.0 # Already present - location services
```

## Files Created/Modified

### New Files

1. **`lib/services/map_service.dart`**

   - Core map functionality service
   - Location services integration
   - Geoapify API calls
   - Shop location data management

2. **`lib/screens/customers/map_screen.dart`**

   - Full-screen interactive map
   - Shop markers with details
   - Search radius control
   - Current location tracking

3. **`lib/widgets/nearby_shops_widget.dart`**

   - Reusable nearby shops widget
   - Can be embedded in any screen
   - Shows closest shops with distances

4. **`test_map_integration.dart`**
   - Test file for map functionality
   - Demonstrates all features

### Modified Files

1. **`pubspec.yaml`** - Added map dependencies
2. **`lib/main.dart`** - Added map route
3. **`lib/screens/welcome_screen.dart`** - Added nearby shops widget and map navigation
4. **`lib/widgets/custom_drawer.dart`** - Added map navigation option

## Features Implemented

### 1. MapService Class

```dart
// Get current location
MapService.getCurrentLocation()

// Convert address to coordinates
MapService.geocodeAddress(address)

// Convert coordinates to address
MapService.reverseGeocode(lat, lng)

// Calculate distance between points
MapService.calculateDistance(point1, point2)

// Find nearby shops within radius
MapService.findNearbyShops(userLocation, shops, radiusKm)

// Get mock shop data with coordinates
MapService.getShopsWithLocations()
```

### 2. Interactive Map Screen

- **Current Location**: Blue circle marker showing user's position
- **Shop Markers**: Custom markers for nearby shops
- **Search Radius**: Adjustable circle showing search area
- **Shop Details**: Tap markers to see shop information
- **Directions**: Integration with Google Maps for navigation

### 3. Nearby Shops Widget

- **Compact Display**: Shows 3 closest shops by default
- **Distance Info**: Real-time distance calculation
- **Quick Actions**: Call shop or view on map
- **Responsive Design**: Adapts to different screen sizes

### 4. Navigation Integration

- **Bottom Navigation**: Added map tab to welcome screen
- **Drawer Menu**: Added "Shop Map" option
- **Route System**: Integrated with Flutter's navigation

## Map Data Structure

### Shop Location Format

```dart
{
  'id': 'shop_001',
  'name': 'রহমান গ্রোসারি',
  'address': 'ধানমন্ডি-৩২, ঢাকা',
  'phone': '01711123456',
  'category': 'গ্রোসারি',
  'rating': 4.5,
  'latitude': 23.7465,
  'longitude': 90.3765,
  'distance': 0.0, // Calculated dynamically
  'availableProducts': ['চাল সরু', 'তেল', 'আটা'],
}
```

## API Endpoints Used

### 1. Map Tiles

```
https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey={API_KEY}
```

### 2. Geocoding (Address → Coordinates)

```
https://api.geoapify.com/v1/geocode/search?text={address}&apiKey={API_KEY}
```

### 3. Reverse Geocoding (Coordinates → Address)

```
https://api.geoapify.com/v1/geocode/reverse?lat={lat}&lon={lng}&apiKey={API_KEY}
```

### 4. Routing (Directions)

```
https://api.geoapify.com/v1/routing?waypoints={start}|{end}&mode=drive&apiKey={API_KEY}
```

## Permissions Configuration

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (ios/Runner/Info.plist)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show nearby shops.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to show nearby shops.</string>
```

## Usage Examples

### 1. Basic Map Screen

```dart
Navigator.pushNamed(context, '/map');
```

### 2. Nearby Shops Widget

```dart
const NearbyShopsWidget(
  maxShops: 3,
  showHeader: true,
)
```

### 3. Get Current Location

```dart
final position = await MapService.getCurrentLocation();
if (position != null) {
  print('Lat: ${position.latitude}, Lng: ${position.longitude}');
}
```

### 4. Find Nearby Shops

```dart
final userLocation = LatLng(23.8103, 90.4125);
final shops = MapService.getShopsWithLocations();
final nearby = MapService.findNearbyShops(userLocation, shops, 5.0);
```

## Testing

### 1. Run Map Test

```bash
flutter run test_map_integration.dart
```

### 2. Manual Testing Checklist

- [ ] Map loads correctly
- [ ] Current location is detected
- [ ] Shop markers appear
- [ ] Tap markers to see details
- [ ] Search radius adjustment works
- [ ] Navigation to directions works
- [ ] Nearby shops widget displays
- [ ] Distance calculations are accurate

## Mock Data

The implementation includes realistic Dhaka shop locations:

- **Dhanmondi**: 23.7465, 90.3765
- **Gulshan**: 23.7925, 90.4078
- **Mirpur**: 23.8000, 90.3537
- **Uttara**: 23.8759, 90.3795
- **Bashundhara**: 23.8247, 90.4256

## Error Handling

- **Location Permission Denied**: Falls back to Dhaka center
- **Network Errors**: Uses cached/mock data
- **API Failures**: Graceful degradation with sample data
- **Invalid Coordinates**: Boundary checking and validation

## Performance Considerations

- **Lazy Loading**: Maps load only when needed
- **Caching**: Location data cached locally
- **Throttling**: API calls are rate-limited
- **Memory Management**: Proper disposal of map controllers

## Future Enhancements

1. **Real-time Tracking**: Live location updates
2. **Clustering**: Group nearby markers
3. **Offline Mode**: Cached map tiles
4. **Custom Markers**: Shop-specific icons
5. **Heat Maps**: Popularity visualization
6. **AR Integration**: Augmented reality overlay

## Security Notes

- API key is embedded in code (consider environment variables for production)
- Location permissions properly requested
- Network security configured for HTTP requests
- Input validation for user-provided addresses

## Troubleshooting

### Common Issues

1. **Map doesn't load**: Check internet connection and API key
2. **Location not detected**: Ensure permissions are granted
3. **Markers not appearing**: Verify shop data format
4. **Performance issues**: Check for memory leaks in map controller

### Debug Commands

```bash
flutter analyze                    # Check for code issues
flutter doctor                     # Verify Flutter setup
flutter build android --debug      # Test Android build
flutter run --verbose              # Detailed logging
```

## Support

For issues with map integration, check:

1. Geoapify API status and quotas
2. Device location settings
3. Network connectivity
4. Flutter dependencies versions
