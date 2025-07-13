import 'package:flutter/material.dart';

import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/welcome_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => WelcomeScreen(),
      login: (context) => LoginScreen(),
      signup: (context) => SignupScreen(),
      forgotPassword: (context) => ForgotPasswordScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (context) => WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (context) => SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (context) => ForgotPasswordScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
