import 'package:flutter/material.dart';
import 'profile_menu_item_widget.dart';

class ProfileMenuWidget extends StatelessWidget {
  final int availableCoins;
  final VoidCallback onCoinOptionsTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onEditProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onHelpSupportTap;
  final VoidCallback onSuperLoverTap;
  final VoidCallback onPricingManagementTap;

  const ProfileMenuWidget({
    super.key,
    required this.availableCoins,
    required this.onCoinOptionsTap,
    required this.onLogoutTap,
    required this.onEditProfileTap,
    required this.onSettingsTap,
    required this.onHelpSupportTap,
    required this.onSuperLoverTap,
    required this.onPricingManagementTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItemWidget(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your information',
          onTap: onEditProfileTap,
        ),
        ProfileMenuItemWidget(
          icon: Icons.monetization_on,
          title: 'My Coins',
          subtitle: '$availableCoins coins available',
          onTap: onCoinOptionsTap,
        ),
        ProfileMenuItemWidget(
          icon: Icons.star,
          title: 'Super Lover',
          subtitle: 'Become a Super Lover & earn coins',
          onTap: onSuperLoverTap,
        ),
        ProfileMenuItemWidget(
          icon: Icons.attach_money,
          title: 'Pricing Management',
          subtitle: 'Set your service prices',
          onTap: onPricingManagementTap,
        ),
        ProfileMenuItemWidget(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences',
          onTap: onSettingsTap,
        ),
        ProfileMenuItemWidget(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get assistance',
          onTap: onHelpSupportTap,
        ),
        ProfileMenuItemWidget(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: onLogoutTap,
          isDestructive: true,
        ),
      ],
    );
  }
}
