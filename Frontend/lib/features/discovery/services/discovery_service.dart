
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/sample_data.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/api_service.dart';

class DiscoveryService {
  // API endpoints
  static const String _getOnlineUsersEndpoint = '/users/online';

  /// Fetch online users from backend API
  static Future<Map<String, dynamic>> getProfiles({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    try {
      Logger.info('🔄 Fetching online users from API (page: $page, limit: $limit)...');
      
      // Prepare query parameters
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      // Add filters if provided
      if (filters != null) {
        queryParams.addAll(filters);
      }
      
      // Make API call
      final response = await ApiService.get(
        _getOnlineUsersEndpoint,
        queryParameters: queryParams,
      );
      
      Logger.success('✅ Online users fetched successfully');
      
      // Log the complete backend response for debugging
      Logger.info('📊 Backend Response Structure:');
      Logger.info('Response keys: ${response.keys.toList()}');
      Logger.info('Success: ${response['success']}');
      Logger.info('Users count: ${response['users']?.length ?? 'null'}');
      Logger.info('Pagination: ${response['pagination']}');
      Logger.info('Cached: ${response['cached']}');
      Logger.info('Timestamp: ${response['timestamp']}');
      
      // Parse response and return real data
      if (response['success'] == true && response['users'] != null) {
        final List<dynamic> usersData = response['users'];
        final List<UserProfile> profiles = usersData
            .map((userData) => UserProfile.fromOnlineUserMap(userData))
            .toList();
        
        Logger.success('✅ Processed ${profiles.length} real users from backend');
        
        // Return both profiles and pagination data
        return {
          'profiles': profiles,
          'pagination': response['pagination'] ?? {},
          'cached': response['cached'] ?? false,
          'timestamp': response['timestamp'],
        };
      } else {
        Logger.warning('⚠️ No online users found or API returned error');
        // Fallback to sample data
        return {
          'profiles': SampleData.romanticProfiles,
          'pagination': {
            'currentPage': 1,
            'totalPages': 1,
            'totalUsers': SampleData.romanticProfiles.length,
            'usersPerPage': SampleData.romanticProfiles.length,
            'hasNextPage': false,
            'hasPrevPage': false,
          },
          'cached': false,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch online users from API', e);
      // Fallback to sample data
      return {
        'profiles': SampleData.romanticProfiles,
        'pagination': {
          'currentPage': 1,
          'totalPages': 1,
          'totalUsers': SampleData.romanticProfiles.length,
          'usersPerPage': SampleData.romanticProfiles.length,
          'hasNextPage': false,
          'hasPrevPage': false,
        },
        'cached': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  static Future<void> likeProfile(String profileId) async {
    try {
      // TODO: Implement like functionality with API
      Logger.info('Liked profile: $profileId');
    } catch (e) {
      Logger.error('Failed to like profile', e);
    }
  }

  static Future<void> passProfile(String profileId) async {
    try {
      // TODO: Implement pass functionality with API
      Logger.info('Passed profile: $profileId');
    } catch (e) {
      Logger.error('Failed to pass profile', e);
    }
  }
}
