# Architecture Documentation

## Overview

Romantic Hearts is built using a **feature-based architecture** that promotes scalability, maintainability, and separation of concerns. The app follows Flutter best practices and modern software development principles.

## 🏗️ Architecture Pattern

### Feature-Based Architecture

The app is organized around **features** rather than technical layers, making it easier to:
- **Develop features independently**
- **Maintain code organization**
- **Scale the application**
- **Test individual features**

```
lib/
├── main.dart                    # App entry point
├── core/                        # Core app functionality
├── features/                    # Feature-based modules
└── shared/                      # Shared components
```

## 📁 Directory Structure

### Core Layer (`core/`)

Contains application-wide functionality that doesn't belong to specific features:

```
core/
├── constants/
│   ├── app_colors.dart          # Color definitions
│   └── app_constants.dart       # App-wide constants
├── utils/
│   └── validators.dart          # Validation utilities
└── config/                      # Configuration files (future)
```

**Responsibilities:**
- **Constants**: Centralized configuration values
- **Utilities**: Reusable helper functions
- **Configuration**: App-wide settings and environment variables

### Features Layer (`features/`)

Each feature is a self-contained module with its own:
- **Screens**: UI components
- **Widgets**: Feature-specific UI components
- **Services**: Business logic
- **Models**: Feature-specific data models

```
features/
├── auth/                        # Authentication feature
│   ├── screens/
│   │   ├── login_screen.dart
│   │   └── otp_verification_screen.dart
│   ├── widgets/
│   │   └── registration_dialog.dart
│   ├── services/
│   │   └── api_service.dart
│   └── models/                  # Auth-specific models (future)
├── dashboard/                   # Dashboard feature
│   ├── screens/
│   │   └── dashboard_screen.dart
│   ├── widgets/
│   │   └── dashboard/
│   │       ├── home_screen.dart
│   │       ├── calls_screen.dart
│   │       ├── messages_screen.dart
│   │       ├── profile_screen.dart
│   │       └── bottom_navigation.dart
│   ├── services/
│   │   └── dashboard_service.dart
│   └── models/                  # Dashboard-specific models (future)
├── profile/                     # Profile feature
│   ├── screens/
│   │   └── settings_screen.dart
│   ├── widgets/                 # Profile widgets (future)
│   ├── services/                # Profile services (future)
│   └── models/                  # Profile models (future)
└── coins/                       # Coins/ads feature
    ├── screens/                 # Coin screens (future)
    ├── widgets/
    │   └── coin_dialogs.dart
    ├── services/
    │   ├── coin_service.dart
    │   ├── ad_service.dart
    │   └── admob_service.dart
    └── models/                  # Coin models (future)
```

### Shared Layer (`shared/`)

Contains components used across multiple features:

```
shared/
├── models/
│   ├── user_profile.dart        # User profile data model
│   ├── coin_package.dart        # Coin package data model
│   └── sample_data.dart         # Mock data for development
├── widgets/
│   └── romantic_profile_card.dart # Reusable profile card
└── services/                    # Shared services (future)
```

## 🔄 Data Flow

### Authentication Flow

```
Login Screen → API Service → OTP Verification → Registration → Dashboard
```

1. **User Input**: Phone number entered in login screen
2. **API Call**: Service sends OTP request (mock/real)
3. **Verification**: User enters OTP code
4. **Registration**: New users complete profile setup
5. **Navigation**: User redirected to dashboard

### Dashboard Flow

```
Dashboard → Feature Screens → Services → State Updates → UI Refresh
```

1. **Navigation**: User selects feature from bottom navigation
2. **Screen Loading**: Appropriate screen widget loads
3. **Service Calls**: Business logic executed through services
4. **State Management**: Local state updated
5. **UI Update**: Widget rebuilds with new data

### Coin System Flow

```
User Action → Coin Service → AdMob Service → Reward → UI Update
```

1. **User Action**: User requests premium feature
2. **Coin Check**: Service validates coin balance
3. **Ad Display**: AdMob service shows rewarded ad
4. **Reward**: User earns coins for watching ad
5. **Update**: UI reflects new coin balance

## 🎯 Design Patterns

### Service Layer Pattern

Each feature has dedicated services that handle business logic:

```dart
class ApiService {
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    // Business logic for OTP sending
  }
}
```

**Benefits:**
- **Separation of Concerns**: UI separated from business logic
- **Reusability**: Services can be used across multiple screens
- **Testability**: Business logic can be unit tested independently

### Widget Composition Pattern

Complex UI components are broken down into smaller, reusable widgets:

```dart
class DashboardScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: DashboardBottomNavigation(),
    );
  }
}
```

**Benefits:**
- **Modularity**: Each widget has a single responsibility
- **Reusability**: Widgets can be used in different contexts
- **Maintainability**: Easier to modify individual components

### Dependency Injection Pattern

Services are injected into widgets through constructor parameters:

```dart
class HomeScreen extends StatelessWidget {
  final Function(String, int, String) onActionPressed;
  final VoidCallback onCoinOptionsTap;
  
  const HomeScreen({
    required this.onActionPressed,
    required this.onCoinOptionsTap,
  });
}
```

**Benefits:**
- **Loose Coupling**: Components don't directly depend on implementations
- **Testability**: Dependencies can be mocked for testing
- **Flexibility**: Easy to swap implementations

## 🔧 State Management

### Local State Management

Each screen manages its own local state using `StatefulWidget`:

```dart
class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String _completePhoneNumber = '';
  
  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    // API call logic
    setState(() {
      _isLoading = false;
    });
  }
}
```

### Service-Based State

Business logic state is managed through service classes:

```dart
class CoinService {
  static const int initialCoins = 50;
  static const int _callCost = 10;
  static const int _chatCost = 5;
}
```

## 🧪 Testing Strategy

### Unit Testing

Services and utilities are unit tested:

```dart
void main() {
  group('Validators', () {
    test('validatePhone returns null for valid phone', () {
      expect(Validators.validatePhone('1234567890'), isNull);
    });
  });
}
```

### Widget Testing

UI components are tested using Flutter's widget testing framework:

```dart
testWidgets('Login screen shows phone input', (WidgetTester tester) async {
  await tester.pumpWidget(const LoginScreen());
  expect(find.byType(IntlPhoneField), findsOneWidget);
});
```

### Integration Testing

End-to-end user flows are tested:

```dart
testWidgets('Complete login flow', (WidgetTester tester) async {
  // Test complete authentication flow
});
```

## 🔒 Security Considerations

### Data Protection

- **Local Storage**: Sensitive data stored securely using `shared_preferences`
- **Input Validation**: All user inputs validated before processing
- **API Security**: HTTPS communication for all API calls

### Authentication Security

- **OTP Expiration**: Time-limited verification codes
- **Session Management**: Secure token storage and handling
- **Input Sanitization**: Prevention of injection attacks

## 📈 Performance Optimization

### Code Optimization

- **Lazy Loading**: Components loaded only when needed
- **Widget Reuse**: Efficient widget composition
- **Memory Management**: Proper disposal of resources

### UI Optimization

- **Animation Optimization**: Smooth 60fps animations
- **Image Caching**: Efficient image loading and caching
- **Responsive Design**: Optimized for different screen sizes

## 🚀 Scalability Considerations

### Feature Addition

New features can be easily added by:
1. Creating a new feature directory
2. Implementing screens, widgets, and services
3. Adding navigation to the main app

### Code Organization

- **Feature Isolation**: Features are independent and don't interfere
- **Shared Components**: Common functionality extracted to shared layer
- **Service Abstraction**: Business logic abstracted through services

## 🔄 Future Enhancements

### Planned Architecture Improvements

- **State Management**: Implement Provider/Riverpod for global state
- **Dependency Injection**: Add proper DI container
- **Backend Integration**: Connect to real API services
- **Database Layer**: Add local data persistence
- **Caching Strategy**: Implement data and image caching
- **Error Handling**: Comprehensive error management system

### Technical Debt

- **Code Duplication**: Reduce duplicate code through shared components
- **Testing Coverage**: Increase unit and integration test coverage
- **Documentation**: Add inline code documentation
- **Performance Monitoring**: Add performance tracking

---

This architecture provides a solid foundation for building a scalable, maintainable, and feature-rich dating application.
