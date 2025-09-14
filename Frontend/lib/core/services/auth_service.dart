import 'api_service.dart';
import '../models/auth_models.dart';
import 'token_service.dart';
import '../utils/logger.dart';

class AuthService {
  // API Endpoints
  static const String _sendOtpEndpoint = '/auth/send-otp';
  static const String _verifyOtpEndpoint = '/auth/verify-otp';
  static const String _createProfileEndpoint = '/auth/create-profile';
  
  // static const String _loginEndpoint = '/auth/login'; // Unused for now
  static const String _logoutEndpoint = '/auth/logout';
  // static const String _refreshTokenEndpoint = '/auth/refresh-token'; // Not used if backend doesn't provide refresh tokens
  static const String _forgotPasswordEndpoint = '/auth/forgot-password';
  static const String _resetPasswordEndpoint = '/auth/reset-password';

  /// Get stored token for authenticated requests
  static Future<String?> getStoredToken() async {
    return await TokenService.getToken();
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await TokenService.isLoggedIn();
  }

  /// Logout user and clear stored tokens
  static Future<LogoutResponse> logout() async {
    try {
      // Get stored token for API call
      final token = await getStoredToken();
      
      if (token != null) {
        // Make API call to logout from server
        final response = await ApiService.post(
          _logoutEndpoint,
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        
        Logger.success('Server logout successful');
        return LogoutResponse.fromJson(response);
      } else {
        Logger.warning('No token found for logout');
        return LogoutResponse(
          success: true, 
          message: 'No token to logout'
        );
      }
    } catch (e) {
      Logger.error('Server logout failed', e);
      // Return error response but don't throw
      return LogoutResponse(
        success: false, 
        message: 'Server logout failed: ${e.toString()}'
      );
    } finally {
      // Always clear stored tokens regardless of server response
      await TokenService.clearAllTokens();
      Logger.success('Local tokens cleared');
    }
  }

  /// Send OTP to phone number
  static Future<OtpResponse> sendOtp(String phoneNumber) async {
    try {
      final response = await ApiService.post(
        _sendOtpEndpoint,
        body: {
          'phoneNumber': phoneNumber,
        },
      );

      return OtpResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP code
  static Future<AuthResponse> verifyOtp(String phoneNumber, String otpCode) async {
    try {
      final response = await ApiService.post(
        _verifyOtpEndpoint,
        body: {
          'phoneNumber': phoneNumber,
          'otp': otpCode, // Changed from 'otpCode' to 'otp' to match backend expectation
        },
      );

      final authResponse = AuthResponse.fromJson(response);
      
      // Store token for persistent login
      if (authResponse.success && authResponse.token != null) {
        await TokenService.saveAuthData(
          token: authResponse.token!,
          refreshToken: authResponse.refreshToken, // Will be null if not provided by backend
          userId: authResponse.userId,
        );
        Logger.success('Authentication token stored for persistent login');
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Create user profile after successful OTP verification
  static Future<ProfileResponse> createProfile({
    required String token,
    required String name,
    required int age,
    required String gender,
  }) async {
    try {

      final response = await ApiService.post(
        _createProfileEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          'name': name, // Backend expects 'name'
          'age': age, // Backend expects 'age'
          'gender': gender, // Backend expects 'gender'
          // Removed bio and location as they're not in your backend spec
        },
      );

      return ProfileResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh access token (only if backend supports refresh tokens)
  // static Future<AuthResponse> refreshToken(String refreshToken) async {
  //   try {
  //     final response = await ApiService.post(
  //       _refreshTokenEndpoint,
  //       body: {
  //         'refreshToken': refreshToken,
  //       },
  //     );

  //     return AuthResponse.fromJson(response);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  /// Request password reset
  static Future<void> forgotPassword(String phoneNumber) async {
    try {
      await ApiService.post(
        _forgotPasswordEndpoint,
        body: {
          'phoneNumber': phoneNumber,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with OTP
  static Future<void> resetPassword(
    String phoneNumber,
    String otpCode,
    String newPassword,
  ) async {
    try {
      await ApiService.post(
        _resetPasswordEndpoint,
        body: {
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
