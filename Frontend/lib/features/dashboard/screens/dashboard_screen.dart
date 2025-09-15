import 'package:flutter/material.dart';
import '../../coins/services/coin_service.dart';
import '../../coins/services/admob_service.dart';
import '../../profile/screens/profile_screen.dart';
import '../services/dashboard_service.dart';
import '../../calls/screens/complete_call_system.dart';
// Chat functionality removed
import '../widgets/navigation/bottom_navigation_widget.dart';
import '../../../shared/models/user_profile.dart';
import '../../../core/utils/logger.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _availableCoins = CoinService.initialCoins;

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  @override
  void dispose() {
    AdMobService.dispose();
    super.dispose();
  }

  Future<void> _initializeAds() async {
    try {
      await AdMobService.initialize();
      AdMobService.loadRewardedAd();
    } catch (e) {
      Logger.error('Failed to initialize ads', e);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCoinsChanged(int newCoins) {
    setState(() {
      _availableCoins = newCoins;
    });
  }

  void _handleActionPressed(String action, int cost, String profileName) {
    DashboardService.handleActionPressed(
      context,
      action,
      cost,
      profileName,
      _availableCoins,
      _onCoinsChanged,
    );
  }

  void _showCoinOptions() {
    DashboardService.showCoinOptions(context, _onCoinsChanged);
  }

  void _showLogoutDialog() {
    DashboardService.showLogoutDialog(context);
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const CompleteCallSystem();
      case 1:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.call,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Call Feature',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Use the call buttons on profile cards\nto start video or voice calls',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      case 2:
        return const Center(
          child: Text('Chat feature has been removed'),
        );
      case 3:
        return ProfileScreen(
          availableCoins: _availableCoins,
          onCoinOptionsTap: _showCoinOptions,
          onLogoutTap: _showLogoutDialog,
        );
      default:
        return const CompleteCallSystem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
