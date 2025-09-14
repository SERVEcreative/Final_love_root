import '../../../core/utils/logger.dart';
import '../../../core/services/auth_service.dart';

/// Service responsible for handling logout operations
class LogoutService {
  /// Perform complete logout process
  static Future<LogoutResult> performLogout() async {
    try {
      Logger.info('🔄 Starting logout process...');
      
      // Step 1: Server logout
      final logoutResponse = await AuthService.logout();
      Logger.info('✅ Server logout response: ${logoutResponse.success} - ${logoutResponse.message}');
      
      // Step 2: Determine result
      final result = LogoutResult(
        success: logoutResponse.success,
        message: logoutResponse.message,
        serverLogoutSuccessful: logoutResponse.success,
      );
      
      Logger.success('✅ Logout process completed successfully');
      
      return result;
    } catch (e) {
      Logger.error('❌ Logout process failed', e);
      
      return LogoutResult(
        success: false,
        message: 'Logout failed: ${e.toString()}',
        serverLogoutSuccessful: false,
      );
    }
  }
}

/// Result of logout operation
class LogoutResult {
  final bool success;
  final String message;
  final bool serverLogoutSuccessful;

  const LogoutResult({
    required this.success,
    required this.message,
    required this.serverLogoutSuccessful,
  });
}
