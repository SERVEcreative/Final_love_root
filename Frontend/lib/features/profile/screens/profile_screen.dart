import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/profile_service.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_card_widget.dart';
import '../widgets/profile_menu_widget.dart';
import 'edit_profile_screen.dart';
import 'super_lover_screen.dart';
import 'pricing_management_screen.dart';
import '../../../core/utils/logger.dart';

class ProfileScreen extends StatefulWidget {
  final int availableCoins;
  final VoidCallback onCoinOptionsTap;
  final VoidCallback onLogoutTap;

  const ProfileScreen({
    super.key,
    required this.availableCoins,
    required this.onCoinOptionsTap,
    required this.onLogoutTap,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileModel? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Load user profile using ProfileService (which uses UserService for real API calls)
  Future<void> _loadUserProfile() async {
    try {
      Logger.info('📱 ProfileScreen: Loading user profile...');
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // ProfileService will use UserService to make real API calls
      final profile = await _profileService.getCurrentUserProfile();
      
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
      
      Logger.success('📱 ProfileScreen: Profile loaded successfully');
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
      
      Logger.error('📱 ProfileScreen: Failed to load profile: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Refresh profile data
  Future<void> _refreshProfile() async {
    Logger.info('📱 ProfileScreen: Refreshing profile...');
    
    setState(() {
      _isLoading = true;
    });
    
    await _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.pink.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.pink,
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshProfile,
                color: Colors.pink,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const ProfileHeaderWidget(),
                      const SizedBox(height: 20),
                      if (_userProfile != null)
                        ProfileCardWidget(userProfile: _userProfile!),
                      const SizedBox(height: 20),
                      ProfileMenuWidget(
                        availableCoins: widget.availableCoins,
                        onCoinOptionsTap: widget.onCoinOptionsTap,
                        onLogoutTap: widget.onLogoutTap,
                        onEditProfileTap: _navigateToEditProfile,
                        onSettingsTap: _navigateToSettings,
                        onHelpSupportTap: _navigateToHelpSupport,
                        onSuperLoverTap: _navigateToSuperLover,
                        onPricingManagementTap: _navigateToPricingManagement,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Navigate to edit profile screen
  void _navigateToEditProfile() {
    Logger.info('📱 ProfileScreen: Navigating to edit profile');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    ).then((updatedProfile) {
      if (updatedProfile != null) {
        Logger.info('📱 ProfileScreen: Profile updated, refreshing data');
        // Refresh the profile data after successful update
        _loadUserProfile();
      }
    });
  }

  /// Navigate to settings screen
  void _navigateToSettings() {
    Logger.info('📱 ProfileScreen: Navigating to settings');
    
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings - Coming Soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Navigate to help & support screen
  void _navigateToHelpSupport() {
    Logger.info('📱 ProfileScreen: Navigating to help & support');
    
    // TODO: Navigate to help & support screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & Support - Coming Soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Navigate to Super Lover screen
  void _navigateToSuperLover() {
    if (_userProfile != null) {
      Logger.info('📱 ProfileScreen: Navigating to Super Lover screen');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuperLoverScreen(
            userProfile: _userProfile!,
            availableCoins: widget.availableCoins,
          ),
        ),
      ).then((result) {
        if (result == true) {
          Logger.info('📱 ProfileScreen: Super Lover status changed, refreshing data');
          // Refresh the profile data if super lover status changed
          _loadUserProfile();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while profile data is loading...'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Navigate to Pricing Management screen
  void _navigateToPricingManagement() {
    Logger.info('📱 ProfileScreen: Navigating to Pricing Management screen');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PricingManagementScreen(),
      ),
    ).then((result) {
      if (result == true) {
        Logger.info('📱 ProfileScreen: Pricing updated, refreshing data');
        // Refresh the profile data if pricing was updated
        _loadUserProfile();
      }
    });
  }
}
