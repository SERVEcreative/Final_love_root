# Romantic Hearts - Flutter Dating App

A modern, feature-rich dating application built with Flutter that helps users find their perfect match through an intuitive and engaging interface.

## 🌟 Features

### 🔐 Authentication
- **Phone Number Login**: Secure OTP-based authentication
- **Mock Mode**: Development-friendly with simulated OTP codes
- **User Registration**: Complete profile setup with validation
- **Session Management**: Persistent login state

### 💕 Dating Features
- **Profile Discovery**: Browse through romantic profiles
- **Interactive Cards**: Swipe and interact with potential matches
- **Call & Chat**: Connect with matches through calls and messages
- **Profile Management**: Edit and customize your profile

### 🪙 Coin System
- **Virtual Currency**: Earn and spend coins for premium features
- **Ad Rewards**: Watch ads to earn coins
- **Premium Actions**: Use coins for calls and chats
- **Purchase Options**: Buy coin packages

### 📱 User Interface
- **Modern Design**: Beautiful, responsive UI with animations
- **Glassmorphism**: Elegant blurred backgrounds and effects
- **Dark/Light Theme**: Adaptive theming system
- **Smooth Animations**: Fluid transitions and micro-interactions

## 🏗️ Architecture

### Feature-Based Structure
```
lib/
├── main.dart                    # App entry point
├── core/                        # Core app functionality
│   ├── constants/
│   │   ├── app_colors.dart      # Color constants
│   │   └── app_constants.dart   # App constants
│   ├── utils/
│   │   └── validators.dart      # Validation utilities
│   └── config/                  # App configuration
├── features/                    # Feature-based modules
│   ├── auth/                    # Authentication feature
│   ├── dashboard/               # Dashboard feature
│   ├── profile/                 # Profile feature
│   └── coins/                   # Coins/ads feature
└── shared/                      # Shared components
    ├── models/
    ├── widgets/
    └── services/
```

### Key Components

#### Authentication (`features/auth/`)
- **Login Screen**: Phone number input with country code
- **OTP Verification**: Secure 6-digit code verification
- **Registration Dialog**: User profile creation
- **API Service**: Mock and real authentication handling

#### Dashboard (`features/dashboard/`)
- **Home Screen**: Profile discovery and interaction
- **Calls Screen**: Call history and management
- **Messages Screen**: Chat interface
- **Profile Screen**: User settings and preferences
- **Bottom Navigation**: Seamless navigation between features

#### Coins System (`features/coins/`)
- **Coin Service**: Virtual currency management
- **AdMob Integration**: Rewarded video ads
- **Purchase Dialogs**: Coin package selection
- **Earning Options**: Multiple ways to earn coins

#### Shared Components (`shared/`)
- **User Profile Model**: Data structure for user information
- **Romantic Profile Card**: Reusable profile display component
- **Sample Data**: Mock data for development

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/romantic-hearts.git
   cd romantic-hearts/frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Development Mode

The app runs in **Mock Mode** by default, which means:
- No backend server required
- OTP codes are displayed on screen for testing
- All API calls return simulated data
- Perfect for development and testing

To switch to real API mode, update `lib/features/auth/services/api_service.dart`:
```dart
static const bool _useMockData = false; // Change to false
```

## 📱 App Flow

### 1. Authentication Flow
```
Login Screen → OTP Verification → Registration (if new user) → Dashboard
```

### 2. User Journey
```
Dashboard → Browse Profiles → Interact (Call/Chat) → Manage Profile → Settings
```

### 3. Coin System
```
Earn Coins → Watch Ads → Purchase Packages → Spend on Premium Features
```

## 🎨 UI/UX Design

### Design Principles
- **Romantic Theme**: Pink and purple color scheme
- **Modern Aesthetics**: Clean, minimalist design
- **User-Friendly**: Intuitive navigation and interactions
- **Responsive**: Adapts to different screen sizes

### Key UI Components
- **Glassmorphism Cards**: Elegant blurred backgrounds
- **Gradient Buttons**: Beautiful color transitions
- **Animated Transitions**: Smooth page transitions
- **Interactive Elements**: Haptic feedback and animations

## 🔧 Configuration

### Environment Setup
The app uses environment variables for configuration:

```dart
// API Configuration
static const String baseUrl = 'http://localhost:3000/api';

// AdMob Configuration
static const String adMobAppId = 'ca-app-pub-3940256099942544~3347511713';
static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
```

### Mock Data
Sample profiles and data are available in `lib/shared/models/sample_data.dart`:
- Romantic profiles with photos and details
- Call and message history
- User preferences and settings

## 📊 Features in Detail

### Authentication System
- **Phone Validation**: International phone number support
- **OTP Generation**: Secure 6-digit codes
- **Session Persistence**: Automatic login state management
- **Error Handling**: User-friendly error messages

### Profile Management
- **Complete Profile**: Name, age, gender, location, bio
- **Photo Upload**: Profile picture management
- **Preferences**: Notification and privacy settings
- **Real-time Updates**: Instant profile changes

### Coin Economy
- **Earning Methods**: 
  - Watch rewarded video ads
  - Daily login bonuses
  - Referral rewards
- **Spending Options**:
  - Premium calls (10 coins)
  - Chat messages (5 coins)
  - Profile boosts
- **Purchase Packages**:
  - 50 coins: $4.99
  - 100 coins: $8.99
  - 200 coins: $15.99

### Ad Integration
- **AdMob Setup**: Google's mobile advertising platform
- **Rewarded Videos**: Earn coins by watching ads
- **Banner Ads**: Non-intrusive display ads
- **Interstitial Ads**: Full-screen ad experiences

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Manual Testing
1. **Authentication**: Test login with mock OTP
2. **Navigation**: Verify all screens and transitions
3. **Coin System**: Test earning and spending coins
4. **Ad Integration**: Verify ad loading and rewards

## 📦 Dependencies

### Core Dependencies
```yaml
flutter:
  sdk: flutter
google_fonts: ^5.1.0
google_mobile_ads: ^3.1.0
shared_preferences: ^2.2.0
http: ^0.13.5
```

### UI Dependencies
```yaml
intl_phone_field: ^3.1.0
pin_code_fields: ^8.0.1
```

### Development Dependencies
```yaml
flutter_test:
  sdk: flutter
flutter_lints: ^2.0.0
```

## 🔒 Security

### Data Protection
- **Local Storage**: Secure token storage
- **Input Validation**: Comprehensive form validation
- **API Security**: HTTPS communication
- **Privacy**: User data protection

### Authentication Security
- **OTP Expiration**: Time-limited verification codes
- **Session Management**: Secure token handling
- **Input Sanitization**: Prevent injection attacks

## 🚀 Deployment

### Android Build
```bash
flutter build apk --release
```

### iOS Build
```bash
flutter build ios --release
```

### Web Build
```bash
flutter build web --release
```

## 📈 Performance

### Optimization Techniques
- **Lazy Loading**: Load content on demand
- **Image Caching**: Efficient image management
- **Memory Management**: Proper disposal of resources
- **Animation Optimization**: Smooth 60fps animations

### Best Practices
- **Code Splitting**: Feature-based organization
- **State Management**: Efficient state handling
- **Error Boundaries**: Graceful error handling
- **Performance Monitoring**: Track app performance

## 🤝 Contributing

### Development Guidelines
1. **Feature Branches**: Create branches for new features
2. **Code Style**: Follow Flutter/Dart conventions
3. **Testing**: Write tests for new functionality
4. **Documentation**: Update docs for new features

### Pull Request Process
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests and documentation
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Common Issues
1. **Build Errors**: Run `flutter clean` and `flutter pub get`
2. **Ad Loading Issues**: Check internet connection and AdMob configuration
3. **Performance Issues**: Check device specifications and Flutter version

### Getting Help
- **Issues**: Create an issue on GitHub
- **Documentation**: Check this README and inline code comments
- **Community**: Join Flutter community forums

## 🎯 Roadmap

### Upcoming Features
- [ ] Real-time messaging
- [ ] Video calling
- [ ] Advanced matching algorithm
- [ ] Social media integration
- [ ] Push notifications
- [ ] Location-based matching
- [ ] Premium subscription model
- [ ] Multi-language support

### Technical Improvements
- [ ] Backend API integration
- [ ] Database implementation
- [ ] Cloud storage for images
- [ ] Analytics integration
- [ ] A/B testing framework
- [ ] Performance monitoring

## 📞 Contact

- **Developer**: [Your Name]
- **Email**: [your.email@example.com]
- **GitHub**: [https://github.com/yourusername]
- **LinkedIn**: [https://linkedin.com/in/yourusername]

---

**Made with ❤️ using Flutter**

*This app is designed to bring people together and create meaningful connections in the digital age.*
