# 🚀 Scalable API Services Architecture

This directory contains a highly scalable and future-ready API services architecture for the Flutter app.

## 📁 Directory Structure

```
lib/core/services/
├── api_service.dart          # Base HTTP client with error handling
├── auth_service.dart         # Authentication-related API calls
├── user_service.dart         # User profile and Super Lover features
├── coin_service.dart         # Coin system and transactions
├── index.dart               # Service exports
└── README.md               # This documentation

lib/core/models/
├── auth_models.dart         # Authentication data models
├── user_models.dart         # User-related data models
└── coin_models.dart         # Coin system data models

lib/core/config/
└── app_config.dart         # Environment and configuration management

lib/core/utils/
└── logger.dart             # Centralized logging utility
```

## 🏗️ Architecture Overview

### 1. **Base API Service** (`api_service.dart`)
- **Purpose**: Centralized HTTP client with error handling
- **Features**:
  - GET, POST, PUT, DELETE methods
  - Automatic timeout handling (30 seconds)
  - Error parsing and custom exceptions
  - Query parameter support
  - Consistent headers management

### 2. **Feature-Specific Services**
Each service is dedicated to a specific domain:

#### **Auth Service** (`auth_service.dart`)
- OTP sending and verification
- User login/logout
- Token refresh
- Password reset functionality

#### **User Service** (`user_service.dart`)
- Profile management
- Super Lover features
- User blocking/unblocking
- Photo uploads

#### **Coin Service** (`coin_service.dart`)
- Balance checking
- Coin purchases
- Transaction history
- Coin transfers

### 3. **Data Models**
Type-safe models for all API responses:
- `OtpResponse`, `AuthResponse`, `UserData`
- `SuperLoverData`, `ProfileUpdateRequest`
- `CoinBalance`, `CoinPackage`, `CoinTransaction`

### 4. **Configuration Management**
- Environment-specific settings (dev/staging/prod)
- Centralized timeout and retry configurations
- Easy environment switching

## 🔧 Usage Examples

### Sending OTP
```dart
import 'package:your_app/core/services/auth_service.dart';

try {
  final response = await AuthService.sendOtp('+916204691688');
  print('OTP sent: ${response.message}');
} catch (e) {
  print('Error: $e');
}
```

### Verifying OTP
```dart
try {
  final response = await AuthService.verifyOtp('+916204691688', '123456');
  if (response.success) {
    print('Login successful!');
    print('User: ${response.user?.name}');
  }
} catch (e) {
  print('Verification failed: $e');
}
```

### Getting User Profile
```dart
import 'package:your_app/core/services/user_service.dart';

try {
  final profile = await UserService.getProfile();
  print('User: ${profile.name}');
} catch (e) {
  print('Failed to get profile: $e');
}
```

### Purchasing Coins
```dart
import 'package:your_app/core/services/coin_service.dart';

try {
  final response = await CoinService.purchaseCoins('package_1', 'stripe');
  print('Purchase initiated: ${response.paymentUrl}');
} catch (e) {
  print('Purchase failed: $e');
}
```

## 🌍 Environment Configuration

### Development
```dart
AppConfig.setEnvironment(Environment.development);
// Uses: http://localhost:5000/api
```

### Production
```dart
AppConfig.setEnvironment(Environment.production);
// Uses: https://api.yourapp.com/api
```

## 📊 Error Handling

The architecture provides comprehensive error handling:

```dart
try {
  final response = await AuthService.sendOtp(phoneNumber);
  // Handle success
} on ApiException catch (e) {
  print('API Error: ${e.statusCode} - ${e.message}');
  // Handle specific API errors
} catch (e) {
  print('Network Error: $e');
  // Handle network/other errors
}
```

## 🔄 Adding New Services

### 1. Create Service File
```dart
// lib/core/services/messaging_service.dart
import 'api_service.dart';

class MessagingService {
  static const String _sendMessageEndpoint = '/messages/send';
  
  static Future<void> sendMessage(String recipientId, String message) async {
    try {
      await ApiService.post(
        _sendMessageEndpoint,
        body: {
          'recipientId': recipientId,
          'message': message,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
```

### 2. Create Data Models
```dart
// lib/core/models/messaging_models.dart
class Message {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime timestamp;
  
  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.timestamp,
  });
  
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
```

### 3. Export in Index
```dart
// lib/core/services/index.dart
export 'messaging_service.dart';
```

## 🚀 Future-Ready Features

### Planned Services
- **Messaging Service**: Real-time chat functionality
- **Call Service**: Video/audio call management
- **Notification Service**: Push notifications
- **Payment Service**: Payment processing
- **Analytics Service**: User analytics and tracking

### Scalability Features
- **Modular Design**: Each service is independent
- **Type Safety**: Strong typing with data models
- **Error Handling**: Comprehensive error management
- **Configuration**: Environment-specific settings
- **Logging**: Centralized logging system
- **Retry Logic**: Built-in retry mechanisms
- **Caching**: Ready for caching implementation

## 🔐 Security Features

- **Token Management**: Automatic token handling
- **HTTPS Support**: Secure communication
- **Input Validation**: Type-safe data handling
- **Error Sanitization**: Safe error messages

## 📈 Performance Optimizations

- **Connection Pooling**: Efficient HTTP connections
- **Timeout Management**: Prevents hanging requests
- **Response Caching**: Ready for implementation
- **Batch Operations**: Support for bulk operations

## 🧪 Testing Support

- **Mock Data**: Easy mock data integration
- **Error Simulation**: Test error scenarios
- **Network Simulation**: Test network conditions
- **Unit Testing**: Testable service architecture

This architecture provides a solid foundation for building a scalable, maintainable, and future-ready Flutter application with robust API integration capabilities.
