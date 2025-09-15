import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/token_service.dart';

class CompleteCallSystem extends StatefulWidget {
  final Function(bool)? onCallStateChanged;
  
  const CompleteCallSystem({Key? key, this.onCallStateChanged}) : super(key: key);

  @override
  State<CompleteCallSystem> createState() => _CompleteCallSystemState();
}

class _CompleteCallSystemState extends State<CompleteCallSystem> {
  // User Management
  String? _currentUserId;
  String? _currentUserName;
  List<Map<String, dynamic>> _onlineUsers = [];
  bool _isLoadingUsers = false;

  // WebRTC Components
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // Supabase Realtime
  RealtimeChannel? _signalingChannel;
  RealtimeChannel? _incomingCallChannel;

  // Call State
  String _callState = 'idle'; // 'idle', 'calling', 'incoming', 'connected', 'ended'
  String? _callId;
  String? _callerId;
  String? _calleeId;
  String? _callerName;
  String? _calleeName;
  String _callType = 'audio'; // 'audio' or 'video'
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  Map<String, dynamic>? _receivedOffer;
  
  // Call timer
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  DateTime? _callStartTime;
  
  // Local video position for dragging
  Offset _localVideoPosition = const Offset(0, 0);
  bool _isLocalVideoPositioned = false;
  
  // Connection monitoring
  Timer? _connectionCheckTimer;
  DateTime? _lastConnectionCheck;
  Timer? _connectionTimeoutTimer;
  List<RTCIceCandidate> _pendingIceCandidates = [];

  // ICE Servers
  final List<Map<String, String>> _iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Set up global error handling for async operations
    runZonedGuarded(() {
      try {
        // Start channel setup immediately for faster real-time
        _setupIncomingCallListener();
        _initializeSystem();
      } catch (e) {
        print('❌ [CALL_SYSTEM] Error in initState: $e');
        _showError('Failed to initialize call system');
      }
    }, (error, stack) {
      print('❌ [CALL_SYSTEM] Unhandled async error: $error');
      print('❌ [CALL_SYSTEM] Stack trace: $stack');
      _showError('An unexpected error occurred');
    });
  }

  @override
  void dispose() {
    _stopCallTimer();
    _stopConnectionMonitoring();
    _cleanup();
    super.dispose();
  }

  Future<void> _initializeSystem() async {
    try {
      // Get current user
      _currentUserId = await TokenService.getUserId();
      if (_currentUserId == null) {
        _showError('Please login to use call system');
        return;
      }

      // Initialize video renderers
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      // Load online users
      await _loadOnlineUsers();

      print('✅ [CALL_SYSTEM] System initialized successfully');
    } catch (e) {
      print('❌ [CALL_SYSTEM] Initialization failed: $e');
      _showError('Failed to initialize call system: $e');
    }
  }

  Future<void> _setupIncomingCallListener() async {
    try {
      // Setup WebRTC signaling channel with minimal overhead
      _incomingCallChannel = Supabase.instance.client
          .channel('webrtc_signaling')
          .onBroadcast(
            event: 'webrtc',
            callback: _handleIncomingCall,
          )
          .subscribe((status, error) {
            if (status == 'SUBSCRIBED') {
              print('✅ [CALL_SYSTEM] Realtime ready');
            } else if (error != null) {
              print('❌ [CALL_SYSTEM] Channel error: $error');
            }
          });
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to setup incoming call listener: $e');
    }
  }
  
  

  Future<void> _loadOnlineUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      // Get online users from Supabase
      final response = await Supabase.instance.client
          .from('users')
          .select('id, name, status')
          .eq('status', 'online')
          .neq('id', _currentUserId!);

      setState(() {
        _onlineUsers = List<Map<String, dynamic>>.from(response);
        _isLoadingUsers = false;
      });

      print('✅ [CALL_SYSTEM] Loaded ${_onlineUsers.length} online users');
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to load online users: $e');
      setState(() {
        _isLoadingUsers = false;
      });
      _showError('Failed to load online users: $e');
    }
  }

  void _handleIncomingCall(Map<String, dynamic> payload) {
    try {
      final data = payload['data'];
      
      // Add null safety check for data
      if (data == null) {
        print('⚠️ [CALL_SYSTEM] Received null data, ignoring message');
        return;
      }
      
      final type = data['type'];
      final from = payload['from'];
      final to = payload['to'];

      // Only handle messages intended for current user
      if (to != _currentUserId) return;

      // Handle null type - this happens with ICE candidates
      if (type == null) {
        _handleIceCandidateFromSignaling(data);
        return;
      }

      // Process call messages with minimal logging for speed
      if (type == 'offer' && _callState == 'idle') {
        _handleIncomingOffer(data, from);
      } else if (type == 'answer' && _callState == 'calling') {
        _handleAnswer(data);
      } else if (type == 'ice-candidate') {
        _handleIceCandidateFromSignaling(data);
      } else if (type == 'reject' && _callState == 'calling') {
        _handleCallRejected();
      } else if (type == 'end') {
        _handleCallEnded();
      }
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to handle incoming call: $e');
    }
  }

  void _handleIncomingOffer(Map<String, dynamic> data, String callerId) {
    try {
      // Set all state at once to minimize rebuilds
      setState(() {
        _callState = 'incoming';
        _callId = data['callId'];
        _callerId = callerId;
        _callType = data['callType'] ?? 'audio';
        _callerName = _getUserName(callerId);
        _receivedOffer = data;
      });

      _notifyCallStateChange(true);
      // Fetch user name asynchronously if needed
      if (_callerName == 'Unknown User') {
        _fetchUserName(callerId);
      }
    } catch (e) {
      print('❌ [CALL_SYSTEM] Error handling incoming offer: $e');
      _resetCallState();
    }
  }
  
  Future<void> _fetchUserName(String userId) async {
    try {
      // Try to find the user in the online users list first
      Map<String, dynamic>? foundUser;
      try {
        foundUser = _onlineUsers.firstWhere(
          (user) => user['id'] == userId,
        );
      } catch (e) {
        foundUser = null;
      }
      
      if (foundUser != null) {
        setState(() {
          _callerName = foundUser!['name'];
        });
        print('🔍 [CALL_SYSTEM] Updated caller name to: ${foundUser!['name']}');
      } else {
        // If not found, use a generic name
        setState(() {
          _callerName = 'User $userId';
        });
        print('🔍 [CALL_SYSTEM] Using generic name for caller: User $userId');
      }
    } catch (e) {
      print('🔍 [CALL_SYSTEM] Error fetching user name: $e');
    }
  }

  Future<void> _startCall(String targetUserId, String targetUserName, String callType) async {
    try {
      // Set state first for immediate UI feedback
      setState(() {
        _callState = 'calling';
        _callId = 'call_${DateTime.now().millisecondsSinceEpoch}';
        _calleeId = targetUserId;
        _calleeName = targetUserName;
        _callType = callType;
      });

      _notifyCallStateChange(true);

      // Create peer connection and get media with individual error handling
      try {
        await _createPeerConnection();
      } catch (e) {
        print('❌ [CALL_SYSTEM] Failed to create peer connection: $e');
        throw e;
      }
      
      try {
        await _getLocalMedia();
      } catch (e) {
        print('❌ [CALL_SYSTEM] Failed to get local media: $e');
        throw e;
      }

      // Create and send offer immediately
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Send offer with minimal payload for speed
      await _sendSignalingMessage('offer', {
        'sdp': offer.sdp,
        'type': offer.type,
        'callId': _callId,
        'callType': _callType,
      }, targetUserId);
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to start call: $e');
      _showError('Failed to start call: $e');
      _resetCallState();
    }
  }

  Future<void> _acceptCall() async {
    try {
      setState(() {
        _callState = 'connected';
      });

      _notifyCallStateChange(true);
      // Start the call timer immediately
      _startCallTimer();
      
      // Start connection monitoring after a delay to avoid interfering with connection setup
      Future.delayed(const Duration(seconds: 10), () {
        if (_callState == 'connected') {
          _startConnectionMonitoring();
        }
      });

      // Create peer connection and get media with individual error handling
      try {
        await _createPeerConnection();
      } catch (e) {
        print('❌ [CALL_SYSTEM] Failed to create peer connection in accept: $e');
        throw e;
      }
      
      try {
        await _getLocalMedia();
      } catch (e) {
        print('❌ [CALL_SYSTEM] Failed to get local media in accept: $e');
        throw e;
      }

      // Set remote description and create answer in sequence
      final offer = RTCSessionDescription(
        _receivedOffer!['sdp'],
        _receivedOffer!['type'],
      );
      await _peerConnection!.setRemoteDescription(offer);

      // Create and send answer immediately
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      await _sendSignalingMessage('answer', {
        'sdp': answer.sdp,
        'type': answer.type,
        'callId': _callId,
      }, _callerId!);
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to accept call: $e');
      _showError('Failed to accept call: $e');
      _resetCallState();
    }
  }

  Future<void> _rejectCall() async {
    try {
      await _sendSignalingMessage('reject', {
        'callId': _callId,
        'reason': 'User rejected',
      }, _callerId!);
    } catch (e) {
      print('❌ [CALL_SYSTEM] Error rejecting call: $e');
    } finally {
      _resetCallState();
    }
  }

  Future<void> _endCall() async {
    try {
      final targetUserId = _callState == 'calling' ? _calleeId : _callerId;
      if (targetUserId != null) {
        await _sendSignalingMessage('end', {
          'callId': _callId,
        }, targetUserId);
      }
    } catch (e) {
      print('❌ [CALL_SYSTEM] Error ending call: $e');
    } finally {
      _resetCallState();
    }
  }


  Future<void> _getLocalMedia() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': _callType == 'video',
      });

      // Use addTrack instead of addStream for Unified Plan
      if (_localStream != null && _peerConnection != null) {
        for (var track in _localStream!.getTracks()) {
          try {
            await _peerConnection!.addTrack(track, _localStream!);
          } catch (e) {
            print('❌ [CALL_SYSTEM] Failed to add track: $e');
          }
        }
        _localRenderer.srcObject = _localStream;
      }

      print('✅ [CALL_SYSTEM] Local media obtained');
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to get local media: $e');
      _localStream = null;
      rethrow;
    }
  }

  void _handleIceCandidate(RTCIceCandidate candidate) {
    final targetUserId = _callState == 'calling' ? _calleeId : _callerId;
    if (targetUserId != null) {
      _sendSignalingMessage('ice-candidate', {
        'candidate': candidate.candidate,
        'sdpMLineIndex': candidate.sdpMLineIndex,
        'sdpMid': candidate.sdpMid,
      }, targetUserId);
    } else {
      print('❌ [CALL_SYSTEM] Cannot send ICE candidate - target user ID is null');
    }
  }

  void _handleRemoteStream(MediaStream stream) {
    _remoteStream = stream;
    _remoteRenderer.srcObject = stream;
    setState(() {});
    print('✅ [CALL_SYSTEM] Remote stream received');
  }

  void _handleRemoteTrack(RTCTrackEvent event) {
    if (event.streams.isNotEmpty) {
      _remoteStream = event.streams[0];
      _remoteRenderer.srcObject = _remoteStream;
      setState(() {});
      print('✅ [CALL_SYSTEM] Remote track received');
      
      // Only monitor track end events for critical disconnection detection
      for (var track in event.streams[0].getTracks()) {
        track.onEnded = () {
          print('📡 [CALL_SYSTEM] Remote track ended - peer disconnected');
          _handleCallDisconnected();
        };
      }
    }
  }

  void _handleConnectionState(RTCPeerConnectionState state) {
    print('📡 [CALL_SYSTEM] Connection state: $state');
    if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
        state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
        state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
      print('📡 [CALL_SYSTEM] Connection lost - cleaning up call');
      _handleCallDisconnected();
    }
  }

  void _handleAnswer(Map<String, dynamic> data) {
    if (_peerConnection == null) {
      print('❌ [CALL_SYSTEM] Cannot handle answer - peer connection is null');
      return;
    }
    
    try {
      final answer = RTCSessionDescription(data['sdp'], data['type']);
      _peerConnection!.setRemoteDescription(answer);
      setState(() {
        _callState = 'connected';
      });

      _notifyCallStateChange(true);
      // Start the call timer immediately
      _startCallTimer();
      
      // Start connection monitoring after a delay to avoid interfering with connection setup
      Future.delayed(const Duration(seconds: 10), () {
        if (_callState == 'connected') {
          _startConnectionMonitoring();
        }
      });
      
      print('✅ [CALL_SYSTEM] Call connected');
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to handle answer: $e');
    }
  }

  void _handleIceCandidateFromSignaling(Map<String, dynamic> data) {
    try {
      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      
      if (_peerConnection == null) {
        // Queue the candidate for when peer connection is ready
        _pendingIceCandidates.add(candidate);
        print('📋 [CALL_SYSTEM] ICE candidate queued (${_pendingIceCandidates.length} pending)');
        return;
      }

      _peerConnection!.addCandidate(candidate);
      print('✅ [CALL_SYSTEM] ICE candidate added successfully');
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to add ICE candidate: $e');
    }
  }

  void _processPendingIceCandidates() {
    if (_peerConnection == null || _pendingIceCandidates.isEmpty) {
      return;
    }

    print('🔄 [CALL_SYSTEM] Processing ${_pendingIceCandidates.length} pending ICE candidates');
    
    for (final candidate in _pendingIceCandidates) {
      try {
        _peerConnection!.addCandidate(candidate);
        print('✅ [CALL_SYSTEM] Pending ICE candidate added');
      } catch (e) {
        print('❌ [CALL_SYSTEM] Failed to add pending ICE candidate: $e');
      }
    }
    
    _pendingIceCandidates.clear();
    print('✅ [CALL_SYSTEM] All pending ICE candidates processed');
  }

  Future<void> _createPeerConnection() async {
    try {
      _peerConnection = await createPeerConnection({
        'iceServers': _iceServers,
      });

      // Set up event handlers with null safety
      _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        try {
          final targetUserId = _callState == 'calling' ? _calleeId : _callerId;
          if (targetUserId != null) {
            _sendSignalingMessage('ice-candidate', {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            }, targetUserId);
          }
        } catch (e) {
          print('❌ [CALL_SYSTEM] Error in onIceCandidate: $e');
        }
      };

      _peerConnection?.onConnectionState = _handleConnectionState;
      _peerConnection?.onTrack = _handleRemoteTrack;

      // Process any pending ICE candidates
      _processPendingIceCandidates();

      print('✅ [CALL_SYSTEM] Peer connection created successfully');
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to create peer connection: $e');
      _peerConnection = null;
      rethrow;
    }
  }

  void _handleCallRejected() {
    _showError('Call was rejected');
    _resetCallState();
  }

  void _handleCallEnded() {
    _showError('Call ended');
    _resetCallState();
  }

  void _handleCallDisconnected() {
    // Show a more user-friendly message for disconnection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Call disconnected'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    _resetCallState();
  }

  Future<void> _sendSignalingMessage(String type, Map<String, dynamic> data, String targetUserId) async {
    try {
      if (_incomingCallChannel == null) {
        print('❌ [CALL_SYSTEM] Cannot send $type - channel is null');
        return;
      }

      // Minimal payload for speed
      final payload = {
        'type': type,
        'data': data,
        'from': _currentUserId,
        'to': targetUserId,
      };
      
      // Send message immediately without waiting for confirmation
      _incomingCallChannel!.sendBroadcastMessage(
        event: 'webrtc',
        payload: payload,
      );
      
      print('📤 [CALL_SYSTEM] Sent $type to $targetUserId');
    } catch (e) {
      print('❌ [CALL_SYSTEM] Failed to send $type: $e');
    }
  }

  void _resetCallState() {
    // Stop the call timer and connection monitoring
    _stopCallTimer();
    _stopConnectionMonitoring();
    
    setState(() {
      _callState = 'idle';
      _callId = null;
      _callerId = null;
      _calleeId = null;
      _callerName = null;
      _calleeName = null;
      _callType = 'audio';
      _receivedOffer = null;
    });

    // Clear pending ICE candidates
    _pendingIceCandidates.clear();

    _cleanupWebRTC();
    _notifyCallStateChange(false);
  }

  void _notifyCallStateChange(bool isInCall) {
    widget.onCallStateChanged?.call(isInCall);
  }

  void _cleanupWebRTC() {
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.dispose();
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
  }

  void _cleanup() {
    _cleanupWebRTC();
    _signalingChannel?.unsubscribe();
    _incomingCallChannel?.unsubscribe();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getUserName(String userId) {
    print('🔍 [CALL_SYSTEM] Looking for user: $userId');
    print('🔍 [CALL_SYSTEM] Available users: ${_onlineUsers.map((u) => u['id']).toList()}');
    
    try {
      final user = _onlineUsers.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => {'name': 'Unknown User'},
      );
      
      print('🔍 [CALL_SYSTEM] Found user: ${user['name']}');
      return user['name'];
    } catch (e) {
      print('🔍 [CALL_SYSTEM] Error finding user: $e');
      return 'Unknown User';
    }
  }

  /// Get the name of the other person in the call (the person you're talking to)
  String _getOtherPersonName() {
    // If we have a callee ID, we're the caller, so show callee name
    if (_calleeId != null) {
      return _calleeName ?? 'Unknown';
    }
    // If we don't have a callee ID, we're the callee, so show caller name
    return _callerName ?? 'Unknown';
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = _isVideoEnabled;
    });
  }

  void _startCallTimer() {
    _callStartTime = DateTime.now();
    _callDuration = Duration.zero;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_callStartTime != null) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime!);
        });
      }
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
    _callStartTime = null;
    _callDuration = Duration.zero;
  }

  void _startConnectionMonitoring() {
    _lastConnectionCheck = DateTime.now();
    // Reduce frequency to every 15 seconds to improve signaling performance
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkConnectionHealth();
    });
    
    // Increase timeout to 60 seconds to be less aggressive
    _connectionTimeoutTimer = Timer(const Duration(seconds: 60), () {
      if (_callState == 'connected') {
        print('📡 [CALL_SYSTEM] Connection timeout - no response from remote peer');
        _handleCallDisconnected();
      }
    });
  }

  void _stopConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
    _lastConnectionCheck = null;
  }

  void _checkConnectionHealth() {
    if (_peerConnection == null || _callState != 'connected') {
      _stopConnectionMonitoring();
      return;
    }

    // Simple check - just verify we still have a remote stream
    if (_remoteStream == null) {
      print('📡 [CALL_SYSTEM] No remote stream detected - peer may have disconnected');
      _handleCallDisconnected();
      return;
    }

    // Update last connection check time
    _lastConnectionCheck = DateTime.now();
    
    // Reset the timeout timer since we're still monitoring
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = Timer(const Duration(seconds: 60), () {
      if (_callState == 'connected') {
        print('📡 [CALL_SYSTEM] Connection timeout - no response from remote peer');
        _handleCallDisconnected();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_callState) {
      case 'incoming':
        return _buildIncomingCallScreen();
      case 'calling':
        return _buildCallingScreen();
      case 'connected':
        return _buildConnectedScreen();
      default:
        return _buildOnlineUsersScreen();
    }
  }

  Widget _buildOnlineUsersScreen() {
    return Column(
      children: [
        // Custom Header matching the image design
        Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20), // Top padding for status bar
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.pink.shade50,
              ],
            ),
          ),
          child: Row(
            children: [
              // Left side - Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Online Users',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'People ready to chat and call',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right side - Coin section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade300,
                      Colors.orange.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🪙',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '50000',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Users List
        Expanded(
          child: _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : _onlineUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No online users found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _onlineUsers.length,
                      itemBuilder: (context, index) {
                        final user = _onlineUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      decoration: _buildGlassDecoration(
        gradientColors: [
          Colors.white.withOpacity(0.25),
          Colors.pink.shade50.withOpacity(0.3),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
          children: [
            // Enhanced Avatar with Status Ring
            _buildAvatar(name: user['name']),
            
            const SizedBox(width: 16),
            
            // User Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Online Now',
                        style: GoogleFonts.poppins(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Enhanced Call Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Voice Call Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _startCall(user['id'], user['name'], 'audio'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.call,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Video Call Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _startCall(user['id'], user['name'], 'video'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingCallScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade400, Colors.blue.shade800],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // Caller Info
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Icon(
                _callType == 'video' ? Icons.videocam : Icons.call,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              _callerName ?? 'Unknown',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              _callType == 'video' ? 'Incoming Video Call' : 'Incoming Voice Call',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            
            const Spacer(),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject Button
                GestureDetector(
                  onTap: _rejectCall,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
                
                // Accept Button
                GestureDetector(
                  onTap: _acceptCall,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _callType == 'video' ? Icons.videocam : Icons.call,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCallingScreen() {
    return Container(
      color: Colors.grey.shade900,
      child: SafeArea(
        child: Column(
          children: [
            // Simple Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Outgoing Call',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Simple Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade700,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Callee Name
            Text(
              _calleeName ?? 'Unknown User',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Simple Calling Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Calling...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Simple End Call Button
            Container(
              margin: const EdgeInsets.all(40),
              child: GestureDetector(
                onTap: _endCall,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildModernStatusBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Connection Status Indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Outgoing Call',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Time Display
          Text(
            DateTime.now().toString().substring(11, 16),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAvatar() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle Pulsing Ring
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, pulseValue, child) {
                  return Container(
                    width: 180 + (pulseValue * 20),
                    height: 180 + (pulseValue * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2 - (pulseValue * 0.2)),
                        width: 1,
                      ),
                    ),
                  );
                },
              ),
              
              // Main Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  _callType == 'video' ? Icons.videocam : Icons.call,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernName() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Text(
              _calleeName ?? 'Unknown',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernCallingStatus() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simple Animated Dots
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 1),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, dotValue, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final opacity = (dotValue - delay).clamp(0.0, 1.0);
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(opacity),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Calling...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: _endCall,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedScreen() {
    if (_callType == 'video') {
      return _buildFullScreenVideoLayout();
    } else {
      return _buildAudioCallWithHeader();
    }
  }

  Widget _buildFullScreenVideoLayout() {
    return Stack(
      children: [
        // Full Screen Remote Video - Edge to Edge
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _remoteStream != null
                ? RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAvatar(
                          name: _getOtherPersonName(),
                          size: 120,
                          fontSize: 48,
                          showStatusRing: false,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _getOtherPersonName(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Waiting for video...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),

        // Top Header Overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _getOtherPersonName(),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Call Duration Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    _formatDuration(_callDuration),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Draggable Local Video (Picture-in-Picture)
        if (_localStream != null)
          _buildDraggableLocalVideo(),

        // Bottom Controls Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
            child: _buildSimpleCallControls(),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioCallWithHeader() {
    return Container(
      color: Colors.grey.shade900,
      child: SafeArea(
        child: Column(
          children: [
            // Simple Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getOtherPersonName(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Call Duration Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _formatDuration(_callDuration),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content Area
            Expanded(
              child: _buildSimpleAudioLayout(),
            ),
            
            // Simple Call Controls
            _buildSimpleCallControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableLocalVideo() {
    // Initialize position if not set
    if (!_isLocalVideoPositioned) {
      _localVideoPosition = Offset(
        MediaQuery.of(context).size.width - 140, // Right side
        MediaQuery.of(context).padding.top + 80, // Below header
      );
      _isLocalVideoPositioned = true;
    }

    return Positioned(
      left: _localVideoPosition.dx,
      top: _localVideoPosition.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _localVideoPosition = Offset(
              (_localVideoPosition.dx + details.delta.dx).clamp(
                0.0,
                MediaQuery.of(context).size.width - 120,
              ),
              (_localVideoPosition.dy + details.delta.dy).clamp(
                MediaQuery.of(context).padding.top + 20,
                MediaQuery.of(context).size.height - 200,
              ),
            );
          });
        },
        onPanEnd: (details) {
          // Optional: Add snap-to-edge functionality
          _snapToEdge();
        },
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                RTCVideoView(
                  _localRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: true,
                ),
                // Drag handle indicator
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.drag_indicator,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _snapToEdge() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top;
    
    setState(() {
      // Snap to left or right edge
      if (_localVideoPosition.dx < screenWidth / 2) {
        _localVideoPosition = Offset(20, _localVideoPosition.dy);
      } else {
        _localVideoPosition = Offset(screenWidth - 140, _localVideoPosition.dy);
      }
      
      // Ensure it stays within screen bounds
      _localVideoPosition = Offset(
        _localVideoPosition.dx.clamp(0.0, screenWidth - 120),
        _localVideoPosition.dy.clamp(
          paddingTop + 20,
          screenHeight - 200,
        ),
      );
    });
  }

  Widget _buildSimpleVideoLayout() {
    return Stack(
      children: [
        // Remote Video (Full Screen)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: _remoteStream != null
              ? RTCVideoView(_remoteRenderer)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off,
                        size: 60,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Waiting for video...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        
        // Local Video (Picture-in-Picture)
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: _localStream != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: RTCVideoView(_localRenderer),
                  )
                : Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white54,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleAudioLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large Avatar
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade700,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(
              Icons.person,
              size: 80,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // User Name
          Text(
            _getOtherPersonName(),
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Audio Visualizer (Simple)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                width: 4,
                height: 30 + (index * 5.0),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCallControls() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            isActive: _isMuted,
            activeColor: Colors.green,
            isSimple: true,
            onTap: _toggleMute,
          ),
          
          // Video Toggle (only for video calls)
          if (_callType == 'video')
            _buildControlButton(
              icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              isActive: _isVideoEnabled,
              activeColor: Colors.blue,
              isSimple: true,
              onTap: _toggleVideo,
            ),
          
          // End Call Button
          _buildControlButton(
            icon: Icons.call_end,
            isActive: true,
            activeColor: Colors.red,
            isEndCall: true,
            isSimple: true,
            onTap: _endCall,
          ),
        ],
      ),
    );
  }


  Widget _buildVideoCallLayout() {
    return Stack(
      children: [
        // Remote Video (Full Screen)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _remoteStream != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RTCVideoView(_remoteRenderer),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.videocam_off,
                          size: 40,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Waiting for video...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        
        // Local Video (Picture-in-Picture)
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: () {
              // Could implement video swapping functionality here
            },
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: _localStream != null
                    ? RTCVideoView(_localRenderer)
                    : Container(
                        color: Colors.grey.shade800,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
        
        // Connection Quality Indicator
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.signal_cellular_4_bar,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'HD',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioCallLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large User Avatar
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: 100,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // User Name
          Text(
            _callState == 'calling' ? (_calleeName ?? 'Unknown') : (_callerName ?? 'Unknown'),
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Call Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              'Voice Call Active',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Audio Visualizer (Placeholder)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                width: 4,
                height: 30 + (index * 5.0),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCallControls() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            isActive: _isMuted,
            activeColor: Colors.red,
            onTap: _toggleMute,
          ),
          
          // Video Toggle (only for video calls)
          if (_callType == 'video')
            _buildControlButton(
              icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              isActive: _isVideoEnabled,
              activeColor: Colors.blue,
              onTap: _toggleVideo,
            ),
          
          // Speaker Button (placeholder)
          _buildControlButton(
            icon: Icons.volume_up,
            isActive: false,
            activeColor: Colors.orange,
            onTap: () {
              // Implement speaker toggle
            },
          ),
          
          // End Call Button
          _buildControlButton(
            icon: Icons.call_end,
            isActive: true,
            activeColor: Colors.red,
            onTap: _endCall,
            isEndCall: true,
          ),
        ],
      ),
    );
  }

  // Common styling methods to reduce redundancy
  Widget _buildAvatar({
    required String name,
    double size = 56,
    double fontSize = 22,
    bool showStatusRing = true,
  }) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.pink.shade300,
                Colors.pink.shade500,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
        if (showStatusRing)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  BoxDecoration _buildGlassDecoration({
    double borderRadius = 20,
    List<Color>? gradientColors,
    double borderOpacity = 0.2,
  }) {
    return BoxDecoration(
      gradient: gradientColors != null 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            )
          : null,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withOpacity(0.15),
          blurRadius: 15,
          offset: const Offset(0, 5),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.9),
          blurRadius: 1,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    bool isEndCall = false,
    bool isSimple = false,
  }) {
    final double size = isEndCall ? (isSimple ? 60.0 : 70.0) : (isSimple ? 50.0 : 60.0);
    final double iconSize = isEndCall ? (isSimple ? 28.0 : 30.0) : (isSimple ? 24.0 : 25.0);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isEndCall 
              ? Colors.red 
              : (isActive ? activeColor : Colors.white.withOpacity(0.2)),
          shape: BoxShape.circle,
          boxShadow: isSimple ? null : [
            BoxShadow(
              color: (isEndCall ? Colors.red : activeColor).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isEndCall ? Colors.white : (isActive ? Colors.white : Colors.white.withOpacity(0.8)),                    
          size: iconSize,
        ),
      ),
    );
  }
}


