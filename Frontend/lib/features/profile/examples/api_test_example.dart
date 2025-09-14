import 'package:flutter/material.dart';
import '../../../core/services/user_service.dart';
import '../../../core/utils/logger.dart';

/// Simple test to verify API integration
class ApiTestExample extends StatefulWidget {
  const ApiTestExample({super.key});

  @override
  State<ApiTestExample> createState() => _ApiTestExampleState();
}

class _ApiTestExampleState extends State<ApiTestExample> {
  String _statusMessage = 'Ready to test';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Example'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _statusMessage,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Test Button
            ElevatedButton(
              onPressed: _isLoading ? null : _testProfileApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Test Profile API Call'),
            ),
            
            const SizedBox(height: 20),
            
            // API Response Format Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expected Backend Response Format:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text('✅ Success Response:'),
                  const Text('{\n  "success": true,\n  "user": {\n    "id": "...",\n    "name": "...",\n    ...\n  }\n}'),
                  const SizedBox(height: 8),
                  const Text('❌ Error Response:'),
                  const Text('{\n  "error": "Error message",\n  "message": "Details"\n}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Test the profile API call
  Future<void> _testProfileApi() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing API call...';
    });

    try {
      Logger.info('🧪 Starting API test...');
      
      // Test the profile API call
      final profile = await UserService.getCurrentUserProfile();
      
      setState(() {
        _statusMessage = '✅ API Test Successful!\n\nUser: ${profile.fullName}\nPhone: ${profile.phoneNumber}\nAge: ${profile.age}\nLocation: ${profile.location}';
        _isLoading = false;
      });
      
      Logger.success('🧪 API test completed successfully');
      
    } catch (e) {
      setState(() {
        _statusMessage = '❌ API Test Failed:\n$e';
        _isLoading = false;
      });
      
      Logger.error('🧪 API test failed: $e');
    }
  }
}

/// Usage:
/// 
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const ApiTestExample(),
///   ),
/// );
/// ```
