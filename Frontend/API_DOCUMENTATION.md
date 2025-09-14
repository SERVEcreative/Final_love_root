# API Documentation

## Overview

Romantic Hearts uses a **mock API system** for development and testing, with the capability to switch to real backend APIs when needed. This document describes the API endpoints, request/response formats, and integration patterns.

## 🔧 API Configuration

### Mock Mode (Default)

The app runs in mock mode by default, which provides:
- **No backend dependency** for development
- **Simulated API responses** with realistic data
- **Controlled testing environment** with predictable outcomes
- **Fast development cycle** without network delays

### Real API Mode

To switch to real API mode, update the configuration in `lib/features/auth/services/api_service.dart`:

```dart
static const bool _useMockData = false; // Change to false for real API
```

## 📡 API Endpoints

### Authentication Endpoints

#### 1. Send OTP

**Endpoint:** `POST /api/auth/send-otp`

**Request:**
```json
{
  "phoneNumber": "+1234567890"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "phoneNumber": "+1234567890",
    "otpCode": "123456",
    "expiresAt": "2024-01-01T12:00:00Z",
    "testMode": true
  },
  "message": "OTP sent successfully"
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Failed to send OTP"
}
```

#### 2. Verify OTP

**Endpoint:** `POST /api/auth/verify-otp`

**Request:**
```json
{
  "phoneNumber": "+1234567890",
  "otpCode": "123456"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "phoneNumber": "+1234567890",
    "isNewUser": true,
    "accessToken": "mock_token_1234567890"
  },
  "message": "OTP verified successfully"
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Invalid OTP code"
}
```

#### 3. Register User

**Endpoint:** `POST /api/auth/register`

**Request:**
```json
{
  "phoneNumber": "+1234567890",
  "fullName": "John Doe",
  "age": 25,
  "gender": "male",
  "bio": "Looking for someone special"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "phoneNumber": "+1234567890",
      "fullName": "John Doe",
      "age": 25,
      "gender": "male",
      "bio": "Looking for someone special",
      "coins": 50
    },
    "accessToken": "mock_token_1234567890"
  },
  "message": "User registered successfully"
}
```

#### 4. Login User

**Endpoint:** `POST /api/auth/login`

**Request:**
```json
{
  "phoneNumber": "+1234567890"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "phoneNumber": "+1234567890",
      "fullName": "John Doe",
      "age": 25,
      "gender": "male",
      "bio": "Looking for someone special",
      "coins": 50
    },
    "accessToken": "mock_token_1234567890"
  },
  "message": "Login successful"
}
```

### User Profile Endpoints

#### 1. Get User Profile

**Endpoint:** `GET /api/user/profile`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "phoneNumber": "+1234567890",
      "fullName": "John Doe",
      "age": 25,
      "gender": "male",
      "bio": "Looking for someone special",
      "location": "New York",
      "coins": 50,
      "preferences": {
        "notifications": true,
        "locationSharing": true
      }
    }
  },
  "message": "Profile retrieved successfully"
}
```

#### 2. Update User Profile

**Endpoint:** `PUT /api/user/profile`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "fullName": "John Doe",
  "age": 25,
  "gender": "male",
  "bio": "Looking for someone special",
  "location": "New York",
  "preferences": {
    "notifications": true,
    "locationSharing": true
  }
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "fullName": "John Doe",
      "age": 25,
      "gender": "male",
      "bio": "Looking for someone special",
      "location": "New York",
      "preferences": {
        "notifications": true,
        "locationSharing": true
      }
    }
  },
  "message": "Profile updated successfully"
}
```

### Discovery Endpoints

#### 1. Get Profiles

**Endpoint:** `GET /api/discovery/profiles`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Number of profiles per page (default: 10)
- `gender`: Filter by gender (optional)
- `ageMin`: Minimum age (optional)
- `ageMax`: Maximum age (optional)

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "profiles": [
      {
        "id": "profile_1",
        "fullName": "Sarah Johnson",
        "age": 24,
        "gender": "female",
        "bio": "Love traveling and coffee ☕",
        "location": "Los Angeles",
        "photos": ["photo1.jpg", "photo2.jpg"],
        "interests": ["travel", "coffee", "photography"],
        "online": true,
        "lastSeen": "2024-01-01T12:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 100,
      "hasNext": true
    }
  },
  "message": "Profiles retrieved successfully"
}
```

### Interaction Endpoints

#### 1. Initiate Call

**Endpoint:** `POST /api/interactions/call`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "targetUserId": "user_456",
  "callType": "voice"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "callId": "call_123",
    "coinsSpent": 10,
    "remainingCoins": 40
  },
  "message": "Call initiated successfully"
}
```

#### 2. Send Message

**Endpoint:** `POST /api/interactions/message`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "targetUserId": "user_456",
  "message": "Hello! How are you? 😊"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "messageId": "msg_123",
    "coinsSpent": 5,
    "remainingCoins": 35
  },
  "message": "Message sent successfully"
}
```

### Coin System Endpoints

#### 1. Get Coin Balance

**Endpoint:** `GET /api/coins/balance`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "coins": 50,
    "earnedToday": 10,
    "spentToday": 15
  },
  "message": "Balance retrieved successfully"
}
```

#### 2. Earn Coins (Ad Reward)

**Endpoint:** `POST /api/coins/earn`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "method": "ad_watch",
  "adId": "ad_123"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "coinsEarned": 5,
    "newBalance": 55
  },
  "message": "Coins earned successfully"
}
```

#### 3. Purchase Coins

**Endpoint:** `POST /api/coins/purchase`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "packageId": "package_50",
  "paymentMethod": "stripe",
  "paymentToken": "tok_123"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "coinsPurchased": 50,
    "newBalance": 105,
    "transactionId": "txn_123"
  },
  "message": "Coins purchased successfully"
}
```

## 🔐 Authentication

### Token Management

The app uses **Bearer token authentication** for protected endpoints:

```dart
static Map<String, String> _authHeaders(String token) => {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
};
```

### Token Storage

Tokens are securely stored using `shared_preferences`:

```dart
static Future<void> _saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

static Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}
```

## 📊 Error Handling

### Standard Error Response

All API endpoints return consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "code": "ERROR_CODE",
  "details": {
    "field": "Additional error details"
  }
}
```

### Common Error Codes

- `INVALID_PHONE`: Invalid phone number format
- `INVALID_OTP`: Invalid or expired OTP
- `INSUFFICIENT_COINS`: Not enough coins for action
- `USER_NOT_FOUND`: User profile not found
- `NETWORK_ERROR`: Network connectivity issues
- `SERVER_ERROR`: Internal server error

### Error Handling in Code

```dart
try {
  final response = await http.post(uri, headers: headers, body: body);
  final data = jsonDecode(response.body);
  
  if (response.statusCode == 200 && data['success']) {
    return data;
  } else {
    return {
      'success': false,
      'message': data['message'] ?? 'Unknown error',
    };
  }
} catch (e) {
  return {
    'success': false,
    'message': 'Network error: $e',
  };
}
```

## 🧪 Testing

### Mock API Testing

The mock API system provides predictable responses for testing:

```dart
// Test OTP generation
final result = await ApiService.sendOTP('+1234567890');
expect(result['success'], true);
expect(result['data']['otpCode'], isA<String>);
```

### API Integration Testing

When testing with real APIs:

```dart
// Test real API integration
static const bool _useMockData = false;
final result = await ApiService.sendOTP('+1234567890');
// Verify real API response
```

## 🔄 Data Models

### User Profile Model

```dart
class UserProfile {
  final String id;
  final String phoneNumber;
  final String fullName;
  final int age;
  final String gender;
  final String bio;
  final String location;
  final int coins;
  final Map<String, dynamic> preferences;
  
  UserProfile({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bio,
    required this.location,
    required this.coins,
    required this.preferences,
  });
}
```

### API Response Model

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  
  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.code,
    this.details,
  });
}
```

## 🚀 Future Enhancements

### Planned API Features

- **Real-time Messaging**: WebSocket integration for live chat
- **Video Calling**: WebRTC integration for video calls
- **Push Notifications**: FCM integration for notifications
- **File Upload**: Image and media upload endpoints
- **Analytics**: User behavior tracking endpoints
- **Payment Integration**: Stripe/PayPal payment processing

### API Versioning

Future API versions will be supported through URL versioning:

```
/api/v1/auth/send-otp
/api/v2/auth/send-otp
```

### Rate Limiting

Production APIs will implement rate limiting:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1640995200
```

---

This API documentation provides a comprehensive guide for integrating with the Romantic Hearts backend services.
