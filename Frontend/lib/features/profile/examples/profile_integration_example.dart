import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/profile_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/utils/logger.dart';

/// Example demonstrating the integration between UserService and ProfileService
class ProfileIntegrationExample extends StatefulWidget {
  const ProfileIntegrationExample({super.key});

  @override
  State<ProfileIntegrationExample> createState() => _ProfileIntegrationExampleState();
}

class _ProfileIntegrationExampleState extends State<ProfileIntegrationExample> {
  UserProfileModel? _userProfile;
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Integration Example'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $_statusMessage',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_userProfile != null) ...[
                    const SizedBox(height: 8),
                    Text('User: ${_userProfile!.fullName}'),
                    Text('Phone: ${_userProfile!.phoneNumber}'),
                    Text('Online: ${_userProfile!.online ? 'Yes' : 'No'}'),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _loadProfileViaProfileService,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Load Profile via ProfileService'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _loadProfileViaUserService,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Load Profile via UserService (Direct)'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfileExample,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Update Profile Example'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _lookupUserByPhone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Lookup User by Phone Number'),
            ),
            
            const SizedBox(height: 20),
            
            // Data Flow Explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Flow:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. ProfileScreen calls ProfileService'),
                  const Text('2. ProfileService calls UserService'),
                  const Text('3. UserService makes real API calls'),
                  const Text('4. Data flows back through the chain'),
                  const Text('5. ProfileCard displays the data'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example 1: Load profile using ProfileService (recommended approach)
  Future<void> _loadProfileViaProfileService() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading via ProfileService...';
    });

    try {
      Logger.info('📱 Example: Loading profile via ProfileService');
      
      // This will use UserService internally for real API calls
      final profile = await ProfileService().getCurrentUserProfile();
      
      setState(() {
        _userProfile = profile;
        _statusMessage = '✅ Profile loaded via ProfileService';
        _isLoading = false;
      });
      
      Logger.success('📱 Example: Profile loaded successfully via ProfileService');
      
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
        _isLoading = false;
      });
      
      Logger.error('📱 Example: Failed to load profile via ProfileService: $e');
    }
  }

  /// Example 2: Load profile directly using UserService
  Future<void> _loadProfileViaUserService() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading via UserService...';
    });

    try {
      Logger.info('📱 Example: Loading profile via UserService (direct)');
      
      // Direct API call using UserService
      final profile = await UserService.getCurrentUserProfile();
      
      setState(() {
        _userProfile = profile;
        _statusMessage = '✅ Profile loaded via UserService (direct)';
        _isLoading = false;
      });
      
      Logger.success('📱 Example: Profile loaded successfully via UserService');
      
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
        _isLoading = false;
      });
      
      Logger.error('📱 Example: Failed to load profile via UserService: $e');
    }
  }

  /// Example 3: Update profile using ProfileService
  Future<void> _updateProfileExample() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Updating profile...';
    });

    try {
      Logger.info('📱 Example: Updating profile via ProfileService');
      
      // This will use UserService internally for real API calls
      final updatedProfile = await ProfileService().updateProfile(
        name: 'Updated Name',
        fullName: 'Updated Full Name',
        age: 29,
        gender: 'male',
        location: 'Updated Location',
        bio: 'Updated bio from example!',
      );
      
      setState(() {
        _userProfile = updatedProfile;
        _statusMessage = '✅ Profile updated successfully';
        _isLoading = false;
      });
      
      Logger.success('📱 Example: Profile updated successfully');
      
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
        _isLoading = false;
      });
      
      Logger.error('📱 Example: Failed to update profile: $e');
    }
  }

  /// Example 4: Lookup user by phone number
  Future<void> _lookupUserByPhone() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Looking up user by phone...';
    });

    try {
      Logger.info('📱 Example: Looking up user by phone number');
      
      // This will use UserService internally for real API calls
      final user = await ProfileService().getUserByPhoneNumber('+1234567890');
      
      if (user != null) {
        setState(() {
          _userProfile = user;
          _statusMessage = '✅ User found by phone number';
          _isLoading = false;
        });
        
        Logger.success('📱 Example: User found by phone number');
      } else {
        setState(() {
          _statusMessage = '❌ User not found';
          _isLoading = false;
        });
        
        Logger.warning('📱 Example: User not found by phone number');
      }
      
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
        _isLoading = false;
      });
      
      Logger.error('📱 Example: Failed to lookup user by phone: $e');
    }
  }
}

/// Example usage in your app:
/// 
/// ```dart
/// // In your main app or navigation
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const ProfileIntegrationExample(),
///   ),
/// );
/// ```
/// 
/// This example demonstrates:
/// 1. How ProfileService uses UserService for real API calls
/// 2. How data flows from API → UserService → ProfileService → UI
/// 3. Error handling and fallback mechanisms
/// 4. Logging for debugging and monitoring
/// 5. Different ways to access user data
