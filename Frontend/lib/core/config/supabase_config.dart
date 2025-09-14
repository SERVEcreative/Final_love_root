import 'package:flutter/foundation.dart';

class SupabaseConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://kgijlarzjdpardjbefoq.supabase.co'; // Replace with your Supabase URL
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnaWpsYXJ6amRwYXJkamJlZm9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYxNDQ3OTIsImV4cCI6MjA3MTcyMDc5Mn0.QI7LnGP4IgCPgfPwPpIRoyEtq9eN4cSVirKR8Quwios'; // Replace with your Supabase Anon Key
  
  // Realtime Configuration
  static const String callsChannel = 'calls';
  static const String signalingChannel = 'signaling';
  
  // WebRTC Configuration
  static const Map<String, dynamic> iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      // Add your TURN servers here if needed
      // {'urls': 'turn:your-turn-server.com:3478', 'username': 'user', 'credential': 'pass'}
    ],
  };
  
  // Call Configuration
  static const Duration callTimeout = Duration(minutes: 30);
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Media Configuration
  static const Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'mandatory': {
        'minWidth': '640',
        'minHeight': '480',
        'minFrameRate': '30',
      },
      'facingMode': 'user',
      'optional': [],
    }
  };
  
  // Audio-only constraints for voice calls
  static const Map<String, dynamic> audioOnlyConstraints = {
    'audio': true,
    'video': false,
  };
  
  // Video constraints for video calls
  static const Map<String, dynamic> videoConstraints = {
    'audio': true,
    'video': {
      'width': {'min': 640, 'ideal': 1280},
      'height': {'min': 480, 'ideal': 720},
      'frameRate': {'min': 15, 'ideal': 30},
      'facingMode': 'user',
    }
  };
  
  /// Get configuration based on environment
  static Map<String, dynamic> getConfig() {
    return {
      'url': supabaseUrl,
      'anonKey': supabaseAnonKey,
      'iceServers': iceServers,
      'callTimeout': callTimeout,
      'connectionTimeout': connectionTimeout,
      'maxRetries': maxRetries,
      'isDebug': kDebugMode,
    };
  }
  
  /// Print current configuration (without sensitive data)
  static void printConfig() {
    print('🔧 Supabase Configuration:');
    print('   URL: ${supabaseUrl.substring(0, 20)}...');
    print('   Anon Key: ${supabaseAnonKey.substring(0, 20)}...');
    print('   Calls Channel: $callsChannel');
    print('   Signaling Channel: $signalingChannel');
    print('   Call Timeout: $callTimeout');
    print('   Connection Timeout: $connectionTimeout');
    print('   Max Retries: $maxRetries');
    print('   Debug Mode: $kDebugMode');
  }
}