import 'api_service.dart';
import '../models/user_models.dart';
import '../../features/profile/models/user_profile_model.dart';
import '../utils/logger.dart';
import 'token_service.dart';
import 'dart:io';

class UserService {
  // API Endpoints - Updated to match backend structure
  static const String _profileEndpoint = '/users/profile';
  static const String _updateProfileEndpoint = '/users/profile';
  static const String _uploadPhotoEndpoint = '/users/upload-photo';
  static const String _superLoverEndpoint = '/users/super-lover';
  static const String _superLoverStatusEndpoint = '/users/super-lover/status';
  static const String _superLoverBioEndpoint = '/users/super-lover/bio';
  static const String _availableSuperLoversEndpoint = '/users/super-lovers';
  static const String _blockUserEndpoint = '/users/block';
  static const String _unblockUserEndpoint = '/users/unblock';
  static const String _blockedUsersEndpoint = '/users/blocked';
  static const String _getUserByPhoneEndpoint = '/users/by-phone';

  /// Get current user profile (Real API call)
  static Future<UserProfileModel> getCurrentUserProfile() async {
    try {
      Logger.info('🔍 Fetching current user profile...');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.get(
        _profileEndpoint,
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true && response['user'] != null) {
        final userData = response['user'];
        Logger.success('✅ Current user profile fetched successfully');
        Logger.info('📱 Raw user data: $userData');
        Logger.info('📱 Raw image field: ${userData['image']}');
        Logger.info('📱 Raw photoUrl field: ${userData['photoUrl']}');
        
        final userProfile = UserProfileModel.fromMap(userData);
        Logger.info('📱 Processed image URL: ${userProfile.image}');
        Logger.info('📱 Processed photoUrl: ${userProfile.photoUrl}');
        
        return userProfile;
      } else {
        throw Exception('Invalid response format or user not found');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to fetch current user profile: $e');
      rethrow;
    }
  }

  /// Get user data by phone number (Real API call)
  static Future<UserProfileModel> getUserByPhoneNumber(String phoneNumber) async {
    try {
      Logger.info('🔍 Fetching user data for phone: $phoneNumber');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.get(
        '$_getUserByPhoneEndpoint/$phoneNumber',
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true && response['user'] != null) {
        final userData = response['user'];
        Logger.success('✅ User data fetched successfully');
        return UserProfileModel.fromMap(userData);
      } else {
        throw Exception('User not found or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to fetch user data: $e');
      rethrow;
    }
  }

  /// Get user profile (Legacy method)
  static Future<UserProfileModel> getProfile() async {
    try {
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.get(
        _profileEndpoint,
        headers: headers,
      );
      
      // Handle the backend response format
      if (response['success'] == true && response['user'] != null) {
        return UserProfileModel.fromMap(response['user']);
      } else {
        throw Exception('Invalid response format or user not found');
      }
      
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile (Real API call)
  static Future<UserProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      Logger.info('🔄 Updating user profile...');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.put(
        _updateProfileEndpoint,
        body: profileData,
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true && response['user'] != null) {
        Logger.success('✅ User profile updated successfully');
        return UserProfileModel.fromMap(response['user']);
      } else {
        throw Exception('Failed to update profile or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to update user profile: $e');
      rethrow;
    }
  }

  /// Upload profile photo (Real API call)
  static Future<String> uploadPhoto(String filePath) async {
    try {
      Logger.info('📤 Uploading profile photo...');
      Logger.info('📤 File path: $filePath');
      
      // Create File object from path
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }
      
      // Get file size for debugging
      final fileSize = await file.length();
      Logger.info('📤 File size: ${fileSize} bytes');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      Logger.info('📤 Sending actual image file to backend...');
      Logger.info('📤 Endpoint: $_uploadPhotoEndpoint');
      Logger.info('📤 Field name: photo');
      
      // Upload the actual file using multipart form data
      final response = await ApiService.uploadFile(
        _uploadPhotoEndpoint,
        file: file,
        fieldName: 'photo', // This should match what your backend expects
        additionalFields: {
          'type': 'profile', // Optional: specify this is a profile photo
        },
        headers: headers,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(1);
          Logger.info('📤 Upload progress: $progress% ($sent/$total bytes)');
        },
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true) {
        final imageUrl = response['photoUrl'] ?? response['imageUrl'] ?? response['url'] ?? filePath;
        Logger.success('✅ Profile photo uploaded successfully');
        Logger.info('✅ Image URL received: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Failed to upload photo or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to upload profile photo: $e');
      rethrow;
    }
  }

  /// Become Super Lover (Real API call)
  static Future<Map<String, dynamic>> becomeSuperLover() async {
    try {
      Logger.info('💖 Becoming Super Lover...');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.post(
        _superLoverEndpoint,
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true) {
        Logger.success('✅ Successfully became Super Lover');
        return response['data'] ?? response;
      } else {
        throw Exception('Failed to become Super Lover or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to become Super Lover: $e');
      rethrow;
    }
  }

  /// Update Super Lover status (Real API call)
  static Future<Map<String, dynamic>> updateSuperLoverStatus(String status) async {
    try {
      Logger.info('🔄 Updating Super Lover status to: $status');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.put(
        _superLoverStatusEndpoint,
        body: {
          'status': status,
        },
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true) {
        Logger.success('✅ Super Lover status updated successfully');
        return response['data'] ?? response;
      } else {
        throw Exception('Failed to update Super Lover status or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to update Super Lover status: $e');
      rethrow;
    }
  }

  /// Update Super Lover bio (Real API call)
  static Future<Map<String, dynamic>> updateSuperLoverBio(String bio) async {
    try {
      Logger.info('📝 Updating Super Lover bio...');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.put(
        _superLoverBioEndpoint,
        body: {
          'bio': bio,
        },
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true) {
        Logger.success('✅ Super Lover bio updated successfully');
        return response['data'] ?? response;
      } else {
        throw Exception('Failed to update Super Lover bio or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to update Super Lover bio: $e');
      rethrow;
    }
  }

  /// Get available Super Lovers (Real API call)
  static Future<List<UserProfileModel>> getAvailableSuperLovers({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      Logger.info('🔍 Fetching available Super Lovers...');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.get(
        _availableSuperLoversEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true) {
        final List<dynamic> usersData = response['users'] ?? response['data'] ?? [];
        final users = usersData.map((user) => UserProfileModel.fromMap(user)).toList();
        
        Logger.success('✅ Found ${users.length} available Super Lovers');
        return users;
      } else {
        throw Exception('Failed to fetch Super Lovers or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to fetch available Super Lovers: $e');
      rethrow;
    }
  }

  /// Block a user (Real API call)
  static Future<void> blockUser(String userId) async {
    try {
      Logger.info('🚫 Blocking user: $userId');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.post(
        _blockUserEndpoint,
        body: {
          'userId': userId,
        },
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true) {
        Logger.success('✅ User blocked successfully');
      } else {
        throw Exception('Failed to block user or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to block user: $e');
      rethrow;
    }
  }

  /// Unblock a user (Real API call)
  static Future<void> unblockUser(String userId) async {
    try {
      Logger.info('✅ Unblocking user: $userId');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.post(
        _unblockUserEndpoint,
        body: {
          'userId': userId,
        },
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true) {
        Logger.success('✅ User unblocked successfully');
      } else {
        throw Exception('Failed to unblock user or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to unblock user: $e');
      rethrow;
    }
  }

  /// Get blocked users list (Real API call)
  static Future<List<UserProfileModel>> getBlockedUsers() async {
    try {
      Logger.info('🔍 Fetching blocked users...');
      
      // Get JWT token for authentication
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Add Authorization header with JWT token
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await ApiService.get(
        _blockedUsersEndpoint,
        headers: headers,
      );
      
      Logger.info('📡 API Response: $response');
      
      // Handle the backend response format
      if (response['success'] == true) {
        final List<dynamic> usersData = response['blockedUsers'] ?? response['data'] ?? [];
        final users = usersData.map((user) => UserProfileModel.fromMap(user)).toList();
        
        Logger.success('✅ Found ${users.length} blocked users');
        return users;
      } else {
        throw Exception('Failed to fetch blocked users or invalid response format');
      }
      
    } catch (e) {
      Logger.error('❌ Failed to fetch blocked users: $e');
      rethrow;
    }
  }
}
