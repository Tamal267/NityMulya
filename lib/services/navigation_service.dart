import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> push<T>(Widget page) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<T?> pushReplacement<T>(Widget page) {
    return navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed<T>(routeName, arguments: arguments);
  }

  static void showSnackBar(String message,
      {Color? backgroundColor, Duration? duration}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration ?? const Duration(seconds: 3),
        ),
      );
    }
  }

  static void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  static void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
}
