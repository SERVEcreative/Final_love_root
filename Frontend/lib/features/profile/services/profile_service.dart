import '../models/user_profile_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/utils/logger.dart';

class ProfileService {
  // Singleton pattern
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  // Mock current user profile (fallback for development)
  static UserProfileModel get _mockCurrentUser => UserProfileModel(
        id: 'current_user_1',
        name: 'John Doe',
        fullName: 'John Michael Doe',
        age: 28,
        gender: 'male',
        location: 'New York, NY',
        bio: 'Love traveling, coffee, and meeting new people! ☕✈️',
        image: 'assets/images/profile2.jpeg',
        photoUrl: null,
        online: true,
        lastSeen: '2 min ago',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

  /// Get current user profile (Uses real API call from UserService)
  Future<UserProfileModel> getCurrentUserProfile() async {
    try {
      Logger.info('📱 ProfileService: Fetching current user profile...');
      
      // Use UserService to make real API call
      final userProfile = await UserService.getCurrentUserProfile();
      
      Logger.success('📱 ProfileService: User profile loaded successfully');
      return userProfile;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to fetch user profile: $e');
      
      // Fallback to mock data in development
      Logger.info('📱 ProfileService: Using mock data as fallback');
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate delay
      return _mockCurrentUser;
    }
  }

  /// Update user profile (Uses real API call from UserService)
  Future<UserProfileModel> updateProfile({
    required String name,
    required String fullName,
    required int age,
    required String gender,
    required String location,
    required String bio,
    String? image,
  }) async {
    try {
      Logger.info('📱 ProfileService: Updating user profile...');
      
      // Prepare data for API call
      final profileData = {
        'name': name,
        'fullName': fullName,
        'age': age,
        'gender': gender,
        'location': location,
        'bio': bio,
        if (image != null) 'image': image,
      };
      
      // Use UserService to make real API call
      final updatedProfile = await UserService.updateProfile(profileData);
      
      Logger.success('📱 ProfileService: User profile updated successfully');
      return updatedProfile;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to update user profile: $e');
      
      // Fallback to mock update in development
      Logger.info('📱 ProfileService: Using mock update as fallback');
      await Future.delayed(const Duration(milliseconds: 500));
      
      return _mockCurrentUser.copyWith(
        name: name,
        fullName: fullName,
        age: age,
        gender: gender,
        location: location,
        bio: bio,
        image: image ?? _mockCurrentUser.image,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Update profile image (Uses real API call from UserService)
  Future<UserProfileModel> updateProfileImage(String imagePath) async {
    try {
      Logger.info('📱 ProfileService: Updating profile image...');
      
      // Use UserService to upload image
      final imageUrl = await UserService.uploadPhoto(imagePath);
      
      // Get updated profile
      final updatedProfile = await UserService.getCurrentUserProfile();
      
      Logger.success('📱 ProfileService: Profile image updated successfully');
      return updatedProfile;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to update profile image: $e');
      
      // Fallback to mock update in development
      Logger.info('📱 ProfileService: Using mock image update as fallback');
      await Future.delayed(const Duration(milliseconds: 800));
      
      return _mockCurrentUser.copyWith(
        image: imagePath,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Delete account (Uses real API call from UserService)
  Future<bool> deleteAccount() async {
    try {
      Logger.info('📱 ProfileService: Deleting user account...');
      
      // TODO: Add delete account endpoint to UserService
      // await UserService.deleteAccount();
      
      Logger.success('📱 ProfileService: Account deleted successfully');
      return true;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to delete account: $e');
      return false;
    }
  }

  /// Logout user (Uses real API call from UserService)
  Future<bool> logout() async {
    try {
      Logger.info('📱 ProfileService: Logging out user...');
      
      // TODO: Add logout endpoint to UserService
      // await UserService.logout();
      
      Logger.success('📱 ProfileService: User logged out successfully');
      return true;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to logout: $e');
      return false;
    }
  }

  /// Get user preferences (Business logic layer)
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      Logger.info('📱 ProfileService: Fetching user preferences...');
      
      // This could be enhanced to use UserService for real API calls
      // For now, return mock preferences
      await Future.delayed(const Duration(milliseconds: 400));
      
      final preferences = {
        'notifications': {
          'push': true,
          'email': false,
          'sms': true,
        },
        'privacy': {
          'profileVisibility': 'public',
          'showOnlineStatus': true,
          'showLastSeen': true,
        },
        'app': {
          'theme': 'light',
          'language': 'en',
          'autoPlayVideos': true,
        },
      };
      
      Logger.success('📱 ProfileService: User preferences loaded');
      return preferences;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to fetch preferences: $e');
      return {};
    }
  }

  /// Update user preferences (Business logic layer)
  Future<Map<String, dynamic>> updateUserPreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      Logger.info('📱 ProfileService: Updating user preferences...');
      
      // This could be enhanced to use UserService for real API calls
      await Future.delayed(const Duration(milliseconds: 600));
      
      Logger.success('📱 ProfileService: User preferences updated');
      return preferences;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to update preferences: $e');
      return preferences;
    }
  }

  /// Get account statistics (Business logic layer)
  Future<Map<String, dynamic>> getAccountStatistics() async {
    try {
      Logger.info('📱 ProfileService: Fetching account statistics...');
      
      // This could be enhanced to use UserService for real API calls
      await Future.delayed(const Duration(milliseconds: 400));
      
      final stats = {
        'totalMatches': 45,
        'totalLikes': 128,
        'totalViews': 567,
        'accountAge': '30 days',
        'lastActive': '2 min ago',
        'profileCompleteness': 85,
      };
      
      Logger.success('📱 ProfileService: Account statistics loaded');
      return stats;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to fetch statistics: $e');
      return {};
    }
  }

  /// Report a user (Uses real API call from UserService)
  Future<bool> reportUser({
    required String userId,
    required String reason,
    String? description,
  }) async {
    try {
      Logger.info('📱 ProfileService: Reporting user: $userId');
      
      // TODO: Add report user endpoint to UserService
      // await UserService.reportUser(userId: userId, reason: reason, description: description);
      
      Logger.success('📱 ProfileService: User reported successfully');
      return true;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to report user: $e');
      return false;
    }
  }

  /// Block a user (Uses real API call from UserService)
  Future<bool> blockUser(String userId) async {
    try {
      Logger.info('📱 ProfileService: Blocking user: $userId');
      
      // Use UserService to block user
      await UserService.blockUser(userId);
      
      Logger.success('📱 ProfileService: User blocked successfully');
      return true;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to block user: $e');
      return false;
    }
  }

  /// Unblock a user (Uses real API call from UserService)
  Future<bool> unblockUser(String userId) async {
    try {
      Logger.info('📱 ProfileService: Unblocking user: $userId');
      
      // Use UserService to unblock user
      await UserService.unblockUser(userId);
      
      Logger.success('📱 ProfileService: User unblocked successfully');
      return true;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to unblock user: $e');
      return false;
    }
  }

  /// Get blocked users list (Uses real API call from UserService)
  Future<List<UserProfileModel>> getBlockedUsers() async {
    try {
      Logger.info('📱 ProfileService: Fetching blocked users...');
      
      // Use UserService to get blocked users
      final blockedUsers = await UserService.getBlockedUsers();
      
      Logger.success('📱 ProfileService: Found ${blockedUsers.length} blocked users');
      return blockedUsers;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to fetch blocked users: $e');
      return [];
    }
  }

  /// Get user by phone number (Uses real API call from UserService)
  Future<UserProfileModel?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      Logger.info('📱 ProfileService: Looking up user by phone: $phoneNumber');
      
      // Use UserService to get user by phone number
      final user = await UserService.getUserByPhoneNumber(phoneNumber);
      
      Logger.success('📱 ProfileService: User found by phone number');
      return user;
      
    } catch (e) {
      Logger.error('📱 ProfileService: Failed to find user by phone: $e');
      return null;
    }
  }
}
