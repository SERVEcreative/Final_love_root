import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/sample_data.dart';
import '../../../shared/models/user_profile.dart';
import '../widgets/romantic_profile_card.dart';
import '../services/discovery_service.dart';
import '../../../core/utils/logger.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../../core/services/token_service.dart';

class DiscoveryScreen extends StatefulWidget {
  final int availableCoins;
  final Function(String, int, String) onActionPressed;
  final VoidCallback onCoinOptionsTap;

  const DiscoveryScreen({
    super.key,
    required this.availableCoins,
    required this.onActionPressed,
    required this.onCoinOptionsTap,
  });

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List<UserProfile> _profiles = [];
  Map<String, dynamic> _pagination = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isCached = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOnlineUsersFromSupabase();
    _scrollController.addListener(_onScroll);
    
    // Automatically navigate to call system when discovery screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DashboardService.autoNavigateToCallSystem(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _pagination['hasNextPage'] == true) {
        _loadMoreUsers();
      }
    }
  }


  Future<void> _loadOnlineUsersFromSupabase() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Get current user ID
      final currentUserId = await TokenService.getUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Get online users from Supabase
      final response = await Supabase.instance.client
          .from('users')
          .select('id, name, status, call_cost')
          .eq('status', 'online')
          .neq('id', currentUserId);

      // Convert to UserProfile objects
      final List<UserProfile> onlineProfiles = response.map((userData) {
        return UserProfile(
          id: userData['id'] ?? '',
          name: userData['name'] ?? 'Unknown User',
          fullName: userData['name'] ?? 'Unknown User',
          age: 25, // Default age since not in users table
          gender: 'Not specified',
          location: 'Online',
          bio: 'Online and ready to chat! 💕',
          image: 'https://via.placeholder.com/300x400/FF6B9D/FFFFFF?text=${(userData['name'] ?? 'U').substring(0, 1)}',
          email: '',
          phoneNumber: '',
          online: true,
          lastSeen: 'now',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          callCost: (userData['call_cost'] ?? 10).toDouble(),
          chatCost: 15.0,
          videoCallCost: 60.0,
        );
      }).toList();

      setState(() {
        _profiles = onlineProfiles;
        _pagination = {
          'currentPage': 1,
          'totalPages': 1,
          'totalUsers': onlineProfiles.length,
          'usersPerPage': onlineProfiles.length,
          'hasNextPage': false,
          'hasPrevPage': false,
        };
        _isCached = false;
        _isLoading = false;
      });

      Logger.success('📱 DiscoveryScreen: Loaded ${_profiles.length} online users from Supabase');
    } catch (e) {
      Logger.error('📱 DiscoveryScreen: Failed to load online users from Supabase', e);
      // Fallback to API method
      await _loadOnlineUsers();
    }
  }

  Future<void> _loadOnlineUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final result = await DiscoveryService.getProfiles(page: 1, limit: 10);
      
      setState(() {
        _profiles = List<UserProfile>.from(result['profiles']);
        _pagination = Map<String, dynamic>.from(result['pagination']);
        _isCached = result['cached'] ?? false;
        _isLoading = false;
      });

      Logger.success('📱 DiscoveryScreen: Loaded ${_profiles.length} profiles from API');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load profiles: $e';
        _isLoading = false;
      });
      Logger.error('📱 DiscoveryScreen: Failed to load profiles', e);
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _pagination['nextPage'] ?? 1;
      final result = await DiscoveryService.getProfiles(page: nextPage, limit: 10);
      
      setState(() {
        _profiles.addAll(List<UserProfile>.from(result['profiles']));
        _pagination = Map<String, dynamic>.from(result['pagination']);
        _isCached = result['cached'] ?? false;
        _isLoadingMore = false;
      });

      Logger.success('📱 DiscoveryScreen: Loaded ${result['profiles'].length} more profiles');
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      Logger.error('📱 DiscoveryScreen: Failed to load more profiles', e);
    }
  }

  Future<void> _refreshUsers() async {
    await _loadOnlineUsersFromSupabase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildProfilesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Online Users',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'People ready to chat and call',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (_pagination.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_pagination['totalUsers'] ?? 0} people online${_isCached ? ' (cached)' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Coin Display
          _buildCoinDisplay(),
        ],
      ),
    );
  }



  Widget _buildCoinDisplay() {
    return GestureDetector(
      onTap: widget.onCoinOptionsTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withValues(alpha: 0.9),
              Colors.orange.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.availableCoins}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProfilesList() {
    if (_isLoading && _profiles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.pink,
        ),
      );
    }

    if (_hasError && _profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load profiles',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOnlineUsersFromSupabase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No profiles available',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new profiles',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshUsers,
      color: Colors.pink,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _profiles.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _profiles.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.pink,
                ),
              ),
            );
          }

          final profile = _profiles[index];
          return RomanticProfileCard(
            profile: profile,
            availableCoins: widget.availableCoins,
            onActionPressed: widget.onActionPressed,
          );
        },
      ),
    );
  }
}
