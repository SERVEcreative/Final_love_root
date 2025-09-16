import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static Environment _environment = Environment.development;
  
  // API Configuration - Dynamic based on platform
  static Map<Environment, String> get _baseUrls => {
    Environment.development: kIsWeb ? 'http://localhost:5000/api' : 'http://192.168.1.7:5000/api',
    Environment.staging: 'https://staging-api.yourapp.com/api',
    Environment.production: 'https://api.yourapp.com/api',
  };

  // Timeout Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Set the current environment
  static void setEnvironment(Environment environment) {
    _environment = environment;
  }

  /// Get the current environment
  static Environment get environment => _environment;

  /// Get the base URL for the current environment
  static String get baseUrl => _baseUrls[_environment] ?? _baseUrls[Environment.development]!;

  /// Check if running in development mode
  static bool get isDevelopment => _environment == Environment.development;

  /// Check if running in production mode
  static bool get isProduction => _environment == Environment.production;

  /// Get API endpoint with base URL
  static String getApiEndpoint(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Print current configuration
  static void printConfig() {
    print('🔧 App Configuration:');
    print('   Environment: $_environment');
    print('   Base URL: $baseUrl');
    print('   Request Timeout: $requestTimeout');
    print('   Max Retries: $maxRetries');
    print('   Default Page Size: $defaultPageSize');
  }
}
