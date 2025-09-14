class AppConstants {
  // App Information
  static const String appName = 'Romantic Hearts';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Find your perfect match';
  
  // API Constants
  static const String baseUrl = 'http://localhost:3000/api';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 20.0;
  
  // Coin Constants
  static const int initialCoins = 50;
  static const int minCoinsForAction = 10;
  static const int coinsPerAd = 10;
  
  // Validation Constants
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int otpLength = 6;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String coinsKey = 'user_coins';
  static const String themeKey = 'app_theme';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String invalidPhone = 'Please enter a valid phone number.';
  static const String invalidOtp = 'Please enter a valid OTP.';
  static const String insufficientCoins = 'Insufficient coins. Please earn more coins.';
  
  // Success Messages
  static const String otpSent = 'OTP sent successfully!';
  static const String loginSuccess = 'Login successful!';
  static const String coinsEarned = 'Coins earned successfully!';
  
  // Ad Constants
  static const String adMobAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
}
