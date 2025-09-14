import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/super_lover_service.dart';
import '../services/profile_service.dart';

class SuperLoverScreen extends StatefulWidget {
  final UserProfileModel userProfile;
  final int availableCoins;

  const SuperLoverScreen({
    super.key,
    required this.userProfile,
    required this.availableCoins,
  });

  @override
  State<SuperLoverScreen> createState() => _SuperLoverScreenState();
}

class _SuperLoverScreenState extends State<SuperLoverScreen> {
  final SuperLoverService _superLoverService = SuperLoverService();
  // final ProfileService _profileService = ProfileService(); // Unused for now
  final TextEditingController _bioController = TextEditingController();
  
  bool _isLoading = false;
  bool _canBecomeSuperLover = false;
  Map<String, dynamic> _requirements = {};
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.userProfile.isSuperLover) {
      _bioController.text = widget.userProfile.superLoverBio ?? '';
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final canBecome = await _superLoverService.canBecomeSuperLover(
        userId: widget.userProfile.id,
      );
      final requirements = await _superLoverService.getSuperLoverRequirements();

      // TODO: Add super lover status check when backend supports it
      // if (widget.userProfile.isSuperLover) {
      //   final stats = await _superLoverService.getSuperLoverStats(
      //     userId: widget.userProfile.id,
      //   );
      //   setState(() {
      //     _stats = stats;
      //   });
      // }

      setState(() {
        _canBecomeSuperLover = canBecome;
        _requirements = requirements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _becomeSuperLover() async {
    if (_bioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a bio for your Super Lover profile'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.availableCoins < (_requirements['coinsRequired'] ?? 1000)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You need ${_requirements['coinsRequired'] ?? 1000} coins to become a Super Lover'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _superLoverService.becomeSuperLover(
        userId: widget.userProfile.id,
        superLoverBio: _bioController.text.trim(),
        coinsRequired: _requirements['coinsRequired'] ?? 1000,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Congratulations! You are now a Super Lover!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error becoming Super Lover: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _superLoverService.updateSuperLoverStatus(
        userId: widget.userProfile.id,
        status: status,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated to: ${status.toUpperCase()}'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData(); // Refresh data
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBio() async {
    if (_bioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a bio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _superLoverService.updateSuperLoverBio(
        userId: widget.userProfile.id,
        bio: _bioController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bio updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating bio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Super Lover',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.pink,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Super Lover Status Card
                    if (widget.userProfile.isSuperLover) ...[
                      _buildSuperLoverStatusCard(),
                      const SizedBox(height: 20),
                      _buildStatsCard(),
                      const SizedBox(height: 20),
                      _buildBioSection(),
                    ] else ...[
                      _buildBecomeSuperLoverCard(),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSuperLoverStatusCard() {
    final currentStatus = widget.userProfile.superLoverStatus ?? 'offline';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Super Lover Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusButton('online', 'Online', Icons.circle, Colors.green, currentStatus),
                const SizedBox(width: 8),
                _buildStatusButton('ready', 'Ready', Icons.phone, Colors.blue, currentStatus),
                const SizedBox(width: 8),
                _buildStatusButton('offline', 'Offline', Icons.circle_outlined, Colors.grey, currentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status, String label, IconData icon, Color color, String currentStatus) {
    final isSelected = currentStatus == status;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _updateStatus(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Rating',
                    '${_stats['rating']?.toStringAsFixed(1) ?? '0.0'} ⭐',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Calls',
                    '${_stats['totalCalls'] ?? 0}',
                    Icons.phone,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Earnings',
                    '${_stats['totalEarnings'] ?? 0} coins',
                    Icons.monetization_on,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Super Lover Bio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell people about yourself as a Super Lover...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateBio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Update Bio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBecomeSuperLoverCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Become a Super Lover',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _requirements['description'] ?? 'Become a Super Lover to receive calls and earn coins!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            
            // Requirements
            const Text(
              'Requirements:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildRequirementItem(
              'Verified Account',
              widget.userProfile.isVerified,
              Icons.verified,
            ),
            _buildRequirementItem(
              'Minimum Age: ${_requirements['minimumAge'] ?? 18}',
              widget.userProfile.age >= (_requirements['minimumAge'] ?? 18),
              Icons.person,
            ),
            _buildRequirementItem(
              'Coins Required: ${_requirements['coinsRequired'] ?? 1000}',
              widget.availableCoins >= (_requirements['coinsRequired'] ?? 1000),
              Icons.monetization_on,
            ),
            
            const SizedBox(height: 20),
            
            // Bio Input
            const Text(
              'Super Lover Bio:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell people about yourself as a Super Lover...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Become Super Lover Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBecomeSuperLover ? _becomeSuperLover : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Become Super Lover',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            if (!_canBecomeSuperLover) ...[
              const SizedBox(height: 12),
              Text(
                'Complete all requirements to become a Super Lover',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isMet ? Colors.green : Colors.red,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}
