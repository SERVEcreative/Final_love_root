import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/user_profile.dart';

class RomanticProfileCard extends StatefulWidget {
  final UserProfile profile;
  final int availableCoins;
  final Function(String, int, String) onActionPressed;

  const RomanticProfileCard({
    super.key,
    required this.profile,
    required this.availableCoins,
    required this.onActionPressed,
  });

  @override
  State<RomanticProfileCard> createState() => _RomanticProfileCardState();
}

class _RomanticProfileCardState extends State<RomanticProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPhotoArea(),
          _buildUserInfo(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: _buildSimpleAvatar(),
      ),
    );
  }

  Widget _buildSimpleAvatar() {
    final name = widget.profile.name.isNotEmpty ? widget.profile.name : 'User';
    final colors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF795548), // Brown
    ];
    
    final colorIndex = name.hashCode.abs() % colors.length;
    final backgroundColor = colors[colorIndex];
    
    return Container(
      width: double.infinity,
      height: 120,
      color: Colors.grey[50],
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.profile.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.profile.online ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.profile.online ? 'Online' : 'Offline',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.profile.age} • ${widget.profile.location}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (widget.profile.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.profile.bio,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Audio Call Button
          Expanded(
            child: _buildActionButton(
              'Voice',
              Icons.call,
              Colors.green,
              widget.profile.callCost.toInt(),
              () => _handleCallAction('audio'),
            ),
          ),
          const SizedBox(width: 12),
          // Video Call Button
          Expanded(
            child: _buildActionButton(
              'Video',
              Icons.videocam,
              Colors.blue,
              widget.profile.callCost.toInt(),
              () => _handleCallAction('video'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCallAction(String callType) {
    final callTypeText = callType == 'video' ? 'Video Call' : 'Voice Call';
    widget.onActionPressed(callTypeText, widget.profile.callCost.toInt(), widget.profile.name);
  }



  Widget _buildActionButton(String action, IconData icon, Color color, int cost, VoidCallback onPressed) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                action,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}