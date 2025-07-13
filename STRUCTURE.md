# Flutter Project Structure

This project has been restructured to follow standard Flutter development practices.

## Directory Structure

```
lib/
├── main.dart                          # App entry point
├── constants/                         # App-wide constants and themes
│   ├── app_constants.dart             # String constants, colors, etc.
│   └── app_theme.dart                 # Theme configuration
├── models/                            # Data models
│   └── market_price.dart              # Market price data model
├── screens/                           # App screens/pages
│   ├── welcome_screen.dart            # Main welcome screen
│   └── auth/                          # Authentication screens
│       ├── login_screen.dart          # Login screen
│       ├── signup_screen.dart         # Registration screen
│       └── forgot_password_screen.dart # Password recovery screen
├── services/                          # Business logic and API calls
│   └── market_price_service.dart      # Market price data service
├── utils/                             # Utility classes and helpers
│   └── app_routes.dart                # App navigation routes
└── widgets/                           # Reusable custom widgets
    ├── custom_button.dart             # Custom button component
    └── market_price_list_item.dart    # Market price list item widget
```

## Key Improvements

1. **Separation of Concerns**: Code is organized by functionality (screens, widgets, models, etc.)
2. **Reusable Components**: Common UI elements are extracted into reusable widgets
3. **Constants Management**: All hardcoded strings and values are centralized
4. **Theme Configuration**: Consistent styling through centralized theme management
5. **Model-Driven Development**: Data is represented using proper model classes
6. **Service Layer**: Business logic is separated from UI components
7. **Route Management**: Navigation is handled through a centralized routing system

## File Naming Conventions

- All files use `snake_case` naming convention
- Dart classes use `PascalCase`
- Constants use `camelCase` or `SCREAMING_SNAKE_CASE`

## Next Steps

1. Implement proper state management (Provider, Bloc, or Riverpod)
2. Add error handling and loading states
3. Implement proper API integration
4. Add unit and widget tests
5. Implement localization for multi-language support
6. Add proper form validation
7. Implement secure storage for authentication tokens

## Running the Project

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter test
flutter analyze
```
