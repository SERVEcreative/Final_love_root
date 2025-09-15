import 'package:flutter/material.dart';
import '../../coins/services/admob_service.dart';
import '../../coins/widgets/coin_dialogs.dart';
import '../../auth/services/logout_service.dart';
import '../../calls/screens/complete_call_system.dart';
import '../../../core/widgets/loading_dialog.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import 'navigation_service.dart';

class DashboardService {
  static void handleActionPressed(
    BuildContext context,
    String action,
    int cost,
    String profileName,
    int availableCoins,
    Function(int) onCoinsChanged,
  ) {
    // Check if it's a call action
    if (action.contains('Call')) {
      if (availableCoins >= cost) {
        onCoinsChanged(availableCoins - cost);
        
        // Navigate to call system with the specific user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CompleteCallSystem(),
          ),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$action with $profileName initiated! 💕'),
            backgroundColor: Colors.pink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        CoinDialogs.showInsufficientCoinsDialog(
          context,
          cost,
          availableCoins,
          () => showCoinOptions(context, onCoinsChanged),
        );
      }
    } else {
      // Handle other actions (SMS, etc.)
      if (availableCoins >= cost) {
        onCoinsChanged(availableCoins - cost);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$action with $profileName initiated! 💕'),
            backgroundColor: Colors.pink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        CoinDialogs.showInsufficientCoinsDialog(
          context,
          cost,
          availableCoins,
          () => showCoinOptions(context, onCoinsChanged),
        );
      }
    }
  }


  static void showCoinOptions(BuildContext context, Function(int) onCoinsChanged) {
    CoinDialogs.showEarnCoinsDialog(
      context,
      () => watchAdForCoins(context, onCoinsChanged),
      () => CoinDialogs.showBuyCoinsDialog(context, (coins) {
        onCoinsChanged(coins);
      }),
    );
  }

  static void watchAdForCoins(BuildContext context, Function(int) onCoinsChanged) {
    AdMobService.showRewardedAd(context, (coins) {
      onCoinsChanged(coins);
    });
  }

    static Future<void> showLogoutDialog(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await ConfirmationDialog.show(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
    );

    if (!shouldLogout) return;

    // Show loading dialog
    LoadingDialog.show(context, message: 'Logging out...');

    try {
      // Perform logout using dedicated service
      final result = await LogoutService.performLogout();
      
      // Hide loading dialog
      LoadingDialog.hide(context);

      // Show appropriate feedback
      if (context.mounted) {
        _showLogoutFeedback(context, result);
      }
      
      // Navigate to login screen after a short delay to allow feedback to show
      Future.delayed(const Duration(milliseconds: 500), () {
        NavigationService.navigateToLogin();
      });
      
    } catch (e) {
      // Hide loading dialog
      LoadingDialog.hide(context);
      
      // Show error feedback
      if (context.mounted) {
        _showLogoutFeedback(context, LogoutResult(
          success: false,
          message: 'Logout failed: ${e.toString()}',
          serverLogoutSuccessful: false,
        ));
      }
      
      // Navigate to login screen even on error
      Future.delayed(const Duration(milliseconds: 500), () {
        NavigationService.navigateToLogin();
      });
    }
  }

  /// Show appropriate feedback based on logout result
  static void _showLogoutFeedback(BuildContext context, LogoutResult result) {
    if (!context.mounted) return;

    final backgroundColor = result.success ? Colors.green : Colors.orange;
    final message = result.serverLogoutSuccessful 
        ? 'Logged out successfully'
        : 'Logged out locally (server error: ${result.message})';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
