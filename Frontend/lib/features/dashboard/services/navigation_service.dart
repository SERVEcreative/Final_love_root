import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/token_service.dart';
import '../../auth/screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
// Call service removed

class NavigationService {
  /// Navigate to login screen and clear all routes
  static void navigateToLogin() {
    try {
      final navigator = RomanticLoginApp.navigatorKey.currentState;
      if (navigator != null) {
        // Clear all routes and navigate to login
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Remove all routes
        );
        Logger.success('Navigation to login screen completed');
      } else {
        Logger.error('Navigator is null, cannot navigate to login');
      }
    } catch (e) {
      Logger.error('Failed to navigate to login screen', e);
    }
  }

  /// Navigate to dashboard screen and clear all routes
  static Future<void> navigateToDashboard() async {
    try {
      // Initialize CallService if user is logged in
      await _initializeCallServiceIfLoggedIn();
      
      final navigator = RomanticLoginApp.navigatorKey.currentState;
      if (navigator != null) {
        // Clear all routes and navigate to dashboard
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false, // Remove all routes
        );
        Logger.success('Navigation to dashboard completed');
      } else {
        Logger.error('Navigator is null, cannot navigate to dashboard');
      }
    } catch (e) {
      Logger.error('Failed to navigate to dashboard', e);
    }
  }

  /// Initialize CallService if user is already logged in
  static Future<void> _initializeCallServiceIfLoggedIn() async {
    try {
      final token = await TokenService.getToken();
      final userId = await TokenService.getUserId();
      
      if (token != null && userId != null) {
        // Call service removed
        Logger.success('CallService initialized for existing user');
      }
    } catch (e) {
      Logger.error('Failed to initialize CallService for existing user', e);
    }
  }

  /// Pop current route
  static void pop() {
    try {
      final navigator = RomanticLoginApp.navigatorKey.currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
        Logger.info('Popped current route');
      } else {
        Logger.warning('Cannot pop route - navigator is null or cannot pop');
      }
    } catch (e) {
      Logger.error('Failed to pop route', e);
    }
  }

  /// Check if navigator is available
  static bool isNavigatorAvailable() {
    return RomanticLoginApp.navigatorKey.currentState != null;
  }
}
