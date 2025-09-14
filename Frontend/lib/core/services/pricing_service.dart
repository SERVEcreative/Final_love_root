import 'package:supabase_flutter/supabase_flutter.dart';

class PricingService {
  static const String _tableName = 'users';
  
  /// Get pricing for a specific user from users table
  static Future<Map<String, double>> getUserPricing(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from(_tableName)
          .select('audio_call_cost, video_call_cost, sms_cost, name, is_premium')
          .eq('id', userId)
          .single();
      
      // Get base pricing
      double audioCost = (response['audio_call_cost'] as num?)?.toDouble() ?? 25.00;
      double videoCost = (response['video_call_cost'] as num?)?.toDouble() ?? 50.00;
      double smsCost = (response['sms_cost'] as num?)?.toDouble() ?? 10.00;
      
      // Apply premium discounts if user is premium
      final isPremium = response['is_premium'] as bool? ?? false;
      if (isPremium) {
        audioCost *= 0.8; // 20% discount for premium users
        videoCost *= 0.8;
        smsCost *= 0.8;
      }
      
      return {
        'audio_call_cost': audioCost,
        'video_call_cost': videoCost,
        'sms_cost': smsCost,
      };
    } catch (e) {
      print('❌ [PRICING] Failed to get user pricing: $e');
      // Return default pricing if user pricing not found
      return {
        'audio_call_cost': 25.00,
        'video_call_cost': 50.00,
        'sms_cost': 10.00,
      };
    }
  }
  
  /// Get call cost for a specific user and call type
  static Future<double> getCallCost(String userId, String callType) async {
    try {
      final pricing = await getUserPricing(userId);
      
      switch (callType.toLowerCase()) {
        case 'audio':
          return pricing['audio_call_cost'] ?? 25.00;
        case 'video':
          return pricing['video_call_cost'] ?? 50.00;
        default:
          return 25.00;
      }
    } catch (e) {
      print('❌ [PRICING] Failed to get call cost: $e');
      return callType.toLowerCase() == 'video' ? 50.00 : 25.00;
    }
  }
  
  /// Check if user has enough coins for a call
  static Future<bool> hasEnoughCoins(String userId, String callType, int availableCoins) async {
    try {
      final cost = await getCallCost(userId, callType);
      return availableCoins >= cost.toInt();
    } catch (e) {
      print('❌ [PRICING] Failed to check coins: $e');
      return false;
    }
  }
  
  /// Get pricing snapshot for call record
  static Future<Map<String, dynamic>> getPricingSnapshot(String userId) async {
    try {
      final pricing = await getUserPricing(userId);
      return {
        'user_id': userId,
        'audio_call_cost': pricing['audio_call_cost'],
        'video_call_cost': pricing['video_call_cost'],
        'sms_cost': pricing['sms_cost'],
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ [PRICING] Failed to get pricing snapshot: $e');
      return {
        'user_id': userId,
        'audio_call_cost': 25.00,
        'video_call_cost': 50.00,
        'sms_cost': 10.00,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Update user pricing (admin function) - directly in users table
  static Future<void> updateUserPricing({
    required String userId,
    double? audioCallCost,
    double? videoCallCost,
    double? smsCost,
    String? changeReason,
    String? changedBy,
  }) async {
    try {
      // Get current pricing for history
      final currentPricing = await getUserPricing(userId);
      
      // Update pricing directly in users table
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (audioCallCost != null) updateData['audio_call_cost'] = audioCallCost;
      if (videoCallCost != null) updateData['video_call_cost'] = videoCallCost;
      if (smsCost != null) updateData['sms_cost'] = smsCost;
      
      await Supabase.instance.client
          .from(_tableName)
          .update(updateData)
          .eq('id', userId);
      
      // Record in pricing history (optional - only if you want to keep history)
      if (changeReason != null && changedBy != null) {
        await Supabase.instance.client.from('pricing_history').insert({
          'user_id': userId,
          'old_audio_call_cost': currentPricing['audio_call_cost'],
          'new_audio_call_cost': audioCallCost,
          'old_video_call_cost': currentPricing['video_call_cost'],
          'new_video_call_cost': videoCallCost,
          'old_sms_cost': currentPricing['sms_cost'],
          'new_sms_cost': smsCost,
          'changed_by': changedBy,
          'change_reason': changeReason,
        });
      }
      
      print('✅ [PRICING] User pricing updated successfully');
    } catch (e) {
      print('❌ [PRICING] Failed to update user pricing: $e');
      rethrow;
    }
  }
  
  /// Get pricing history for a user
  static Future<List<Map<String, dynamic>>> getPricingHistory(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('pricing_history')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [PRICING] Failed to get pricing history: $e');
      return [];
    }
  }
  
  /// Get all users with their current pricing from users table
  static Future<List<Map<String, dynamic>>> getAllUsersPricing() async {
    try {
      final response = await Supabase.instance.client
          .from(_tableName)
          .select('''
            id,
            name,
            audio_call_cost,
            video_call_cost,
            sms_cost,
            is_premium,
            status,
            created_at,
            updated_at
          ''')
          .order('updated_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [PRICING] Failed to get all users pricing: $e');
      return [];
    }
  }
  
  /// Get user profile information for calls
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from(_tableName)
          .select('''
            id,
            name,
            avatar_url,
            status,
            is_online,
            audio_call_cost,
            video_call_cost,
            sms_cost,
            is_premium,
            location,
            age,
            gender
          ''')
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      print('❌ [PRICING] Failed to get user profile: $e');
      return null;
    }
  }
  
  /// Check if user is online and available for calls
  static Future<bool> isUserOnline(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from(_tableName)
          .select('status, last_seen')
          .eq('id', userId)
          .single();
      
      final status = response['status'] as String?;
      final lastSeen = response['last_seen'] as String?;
      
      if (status == 'online') {
        return true;
      }
      
      // Check if user was online within last 5 minutes
      if (lastSeen != null) {
        final lastSeenTime = DateTime.parse(lastSeen);
        final now = DateTime.now();
        final difference = now.difference(lastSeenTime);
        return difference.inMinutes <= 5;
      }
      
      return false;
    } catch (e) {
      print('❌ [PRICING] Failed to check user online status: $e');
      return false;
    }
  }
}