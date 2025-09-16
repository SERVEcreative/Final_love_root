import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile_model.dart';

class ProfileCardWidget extends StatelessWidget {
  final UserProfileModel userProfile;

  const ProfileCardWidget({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
                  children: [
            _buildProfileAvatar(),
            const SizedBox(height: 16),
            _buildProfileInfo(),
            const SizedBox(height: 16),
            _buildProfileStats(),
          ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.pink.withValues(alpha: 0.8),
            Colors.purple.withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: userProfile.image.isNotEmpty
          ? ClipOval(
              child: _buildProfileImage(),
            )
          : const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
    );
  }

  Widget _buildProfileImage() {
    // Debug logging
    print('ProfileCardWidget: Building profile image');
    print('ProfileCardWidget: Image URL: ${userProfile.image}');
    print('ProfileCardWidget: PhotoUrl: ${userProfile.photoUrl}');
    
    // Test URL accessibility
    if (userProfile.image.isNotEmpty && userProfile.image.startsWith('http')) {
      _testImageUrl(userProfile.image);
    }
    
    // Check if it's a network URL or local asset
    if (userProfile.image.isNotEmpty && userProfile.image.startsWith('http')) {
      return Image.network(
        userProfile.image,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.pink,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          print('Failed URL: ${userProfile.image}');
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  'Image Error',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (userProfile.image.isNotEmpty) {
      // Try as local asset
      return Image.asset(
        userProfile.image,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading asset image: $error');
          return const Icon(
            Icons.person,
            color: Colors.white,
            size: 40,
          );
        },
      );
    } else {
      // No image available, show default icon
      return const Icon(
        Icons.person,
        color: Colors.white,
        size: 40,
      );
    }
  }

  void _testImageUrl(String url) async {
    try {
      print('🔍 Testing image URL accessibility: $url');
      final response = await http.head(Uri.parse(url));
      print('🔍 URL test response: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ Image URL is accessible');
      } else {
        print('❌ Image URL returned status: ${response.statusCode}');
        print('❌ Response headers: ${response.headers}');
      }
    } catch (e) {
      print('❌ URL test failed: $e');
    }
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Text(
          userProfile.fullName,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${userProfile.age} years old • ${userProfile.location}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        if (userProfile.bio.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            userProfile.bio,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Online', userProfile.online ? 'Yes' : 'No', Icons.circle),
          _buildStatItem('Last Seen', userProfile.lastSeen, Icons.access_time),
          _buildStatItem('Member Since', _formatDate(userProfile.createdAt), Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}
