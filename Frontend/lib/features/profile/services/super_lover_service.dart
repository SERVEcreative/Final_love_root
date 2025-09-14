import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile_model.dart';

class SuperLoverService {
  static const String baseUrl = 'https://api.romanticlove.com'; // Replace with your actual API URL

  // Become a super lover (only for verified users)
  Future<bool> becomeSuperLover({
    required String userId,
    required String superLoverBio,
    required int coinsRequired,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/super-lover/become'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual auth token
        },
        body: jsonEncode({
          'userId': userId,
          'superLoverBio': superLoverBio,
          'coinsRequired': coinsRequired,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to become super lover: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error becoming super lover: $e');
    }
  }

  // Update super lover status (online, ready, offline)
  Future<bool> updateSuperLoverStatus({
    required String userId,
    required String status, // 'online', 'ready', 'offline'
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/super-lover/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual auth token
        },
        body: jsonEncode({
          'userId': userId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }

  // Update super lover bio
  Future<bool> updateSuperLoverBio({
    required String userId,
    required String bio,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/super-lover/bio'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual auth token
        },
        body: jsonEncode({
          'userId': userId,
          'bio': bio,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update bio: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating bio: $e');
    }
  }

  // Get super lover statistics
  Future<Map<String, dynamic>> getSuperLoverStats({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/super-lover/stats/$userId'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual auth token
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get stats: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting stats: $e');
    }
  }

  // Get available super lovers for calling
  Future<List<UserProfileModel>> getAvailableSuperLovers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/super-lover/available'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual auth token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserProfileModel.fromMap(json)).toList();
      } else {
        throw Exception('Failed to get available super lovers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting available super lovers: $e');
    }
  }

  // Check if user can become super lover (verification check)
  Future<bool> canBecomeSuperLover({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/super-lover/can-become/$userId'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual auth token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['canBecome'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Get super lover requirements
  Future<Map<String, dynamic>> getSuperLoverRequirements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/super-lover/requirements'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual auth token
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'coinsRequired': 1000,
          'verificationRequired': true,
          'minimumAge': 18,
          'description': 'Become a Super Lover to receive calls and earn coins!',
        };
      }
    } catch (e) {
      return {
        'coinsRequired': 1000,
        'verificationRequired': true,
        'minimumAge': 18,
        'description': 'Become a Super Lover to receive calls and earn coins!',
      };
    }
  }
}
