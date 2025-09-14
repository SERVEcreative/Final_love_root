import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'RomanticApp';

  /// Log info messages
  static void info(String message, [Object? data]) {
    if (kDebugMode) {
      print('ℹ️  [$_tag] $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  /// Log warning messages
  static void warning(String message, [Object? data]) {
    if (kDebugMode) {
      print('⚠️  [$_tag] $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ [$_tag] $message');
      if (error != null) {
        print('   Error: $error');
      }
      if (stackTrace != null) {
        print('   Stack Trace: $stackTrace');
      }
    }
  }

  /// Log debug messages
  static void debug(String message, [Object? data]) {
    if (kDebugMode) {
      print('🐛 [$_tag] $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  /// Log success messages
  static void success(String message, [Object? data]) {
    if (kDebugMode) {
      print('✅ [$_tag] $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  /// Log API requests
  static void apiRequest(String method, String endpoint, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      print('📡 [$_tag] API Request: $method $endpoint');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  /// Log API responses
  static void apiResponse(String method, String endpoint, int statusCode, [String? response]) {
    if (kDebugMode) {
      final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      print('$emoji [$_tag] API Response: $method $endpoint ($statusCode)');
      if (response != null) {
        print('   Response: $response');
      }
    }
  }
}
