# Deployment Guide

## Overview

This guide provides comprehensive instructions for deploying the Romantic Hearts Flutter app to various platforms including Android, iOS, and Web.

## 📱 Platform Deployment

### Android Deployment

#### Prerequisites
- Flutter SDK installed
- Android Studio with Android SDK
- Keystore for app signing
- Google Play Console account (for Play Store)

#### 1. Build Configuration

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.example.romantic_hearts"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### 2. Create Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### 3. Configure Keystore

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
```

#### 4. Build APK

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Split APKs for different architectures
flutter build apk --split-per-abi --release
```

#### 5. Build App Bundle (Recommended for Play Store)

```bash
flutter build appbundle --release
```

#### 6. Test Release Build

```bash
# Install on connected device
flutter install --release

# Or use adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS Deployment

#### Prerequisites
- macOS with Xcode installed
- Apple Developer account
- iOS device or simulator for testing

#### 1. Configure iOS Settings

Update `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>Romantic Hearts</string>
<key>CFBundleIdentifier</key>
<string>com.example.romanticHearts</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

#### 2. Configure Signing

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Go to Signing & Capabilities
4. Configure your team and bundle identifier

#### 3. Build iOS App

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release

# Build for specific device
flutter build ios --release --flavor production
```

#### 4. Archive and Upload

1. Open Xcode
2. Select Product → Archive
3. Upload to App Store Connect

### Web Deployment

#### Prerequisites
- Flutter web support enabled
- Web server or hosting platform

#### 1. Enable Web Support

```bash
flutter config --enable-web
```

#### 2. Build Web App

```bash
# Debug build
flutter build web --debug

# Release build
flutter build web --release

# Build with specific base href
flutter build web --release --base-href "/romantic-hearts/"
```

#### 3. Deploy to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init hosting

# Deploy
firebase deploy
```

#### 4. Deploy to GitHub Pages

```bash
# Build for GitHub Pages
flutter build web --release --base-href "/romantic-hearts/"

# Deploy using GitHub Actions
# Create .github/workflows/deploy.yml
```

## 🔧 Environment Configuration

### Production Environment

Create `lib/core/config/production_config.dart`:

```dart
class ProductionConfig {
  static const String apiBaseUrl = 'https://api.romantichearts.com';
  static const String adMobAppId = 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX';
  static const String bannerAdUnitId = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
  static const String interstitialAdUnitId = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
  static const String rewardedAdUnitId = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
}
```

### Development Environment

Create `lib/core/config/development_config.dart`:

```dart
class DevelopmentConfig {
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const String adMobAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
}
```

### Environment Switching

Update `lib/main.dart`:

```dart
import 'core/config/development_config.dart' as dev;
import 'core/config/production_config.dart' as prod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set environment based on build configuration
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  if (isProduction) {
    // Use production config
    ApiService.baseUrl = prod.ProductionConfig.apiBaseUrl;
  } else {
    // Use development config
    ApiService.baseUrl = dev.DevelopmentConfig.apiBaseUrl;
  }
  
  runApp(const RomanticLoginApp());
}
```

## 🚀 CI/CD Pipeline

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Romantic Hearts

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - run: flutter pub get
    - run: flutter test
    - run: flutter analyze

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - run: flutter pub get
    - run: flutter build appbundle --release
    - uses: actions/upload-artifact@v3
      with:
        name: app-bundle
        path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - run: flutter pub get
    - run: flutter build ios --release --no-codesign
    - uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app

  deploy-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - run: flutter pub get
    - run: flutter build web --release
    - uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
```

### Firebase App Distribution

```yaml
  distribute-android:
    needs: build-android
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: wzieba/Firebase-Distribution-Github-Action@v1
      with:
        appId: ${{ secrets.FIREBASE_APP_ID }}
        serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
        groups: testers
        file: build/app/outputs/bundle/release/app-release.aab
```

## 📊 Performance Optimization

### Build Optimization

#### Android

```gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### iOS

```swift
// In Xcode, enable:
// - Enable Bitcode: No
// - Strip Debug Symbols During Copy: Yes
// - Strip Linked Product: Yes
// - Strip Swift Symbols: Yes
```

### Code Optimization

```dart
// Use const constructors
const Text('Hello', style: TextStyle(fontSize: 16));

// Optimize images
Image.asset(
  'assets/images/profile.jpg',
  cacheWidth: 300,
  cacheHeight: 300,
);

// Lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
);
```

## 🔒 Security Configuration

### Android Security

#### Network Security

Create `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.romantichearts.com</domain>
    </domain-config>
</network-security-config>
```

#### ProGuard Rules

Create `android/app/proguard-rules.pro`:

```proguard
# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# AdMob rules
-keep class com.google.android.gms.ads.** { *; }
```

### iOS Security

#### App Transport Security

Update `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.romantichearts.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

## 📱 App Store Deployment

### Google Play Store

1. **Create Release**
   - Upload AAB file
   - Add release notes
   - Set release track (internal, alpha, beta, production)

2. **Content Rating**
   - Complete content rating questionnaire
   - Set appropriate age rating

3. **Store Listing**
   - App description
   - Screenshots and videos
   - Privacy policy
   - App icon and feature graphic

### Apple App Store

1. **App Store Connect**
   - Create app record
   - Configure app information
   - Upload build via Xcode

2. **App Review**
   - Submit for review
   - Provide review information
   - Respond to review feedback

3. **Release**
   - Set release date
   - Configure pricing
   - Publish to App Store

## 🔍 Testing Before Deployment

### Automated Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Manual Testing Checklist

- [ ] **Authentication Flow**
  - [ ] Phone number input
  - [ ] OTP verification
  - [ ] User registration
  - [ ] Login/logout

- [ ] **Core Features**
  - [ ] Profile browsing
  - [ ] Call functionality
  - [ ] Chat functionality
  - [ ] Coin system

- [ ] **UI/UX**
  - [ ] Responsive design
  - [ ] Animations
  - [ ] Navigation
  - [ ] Error handling

- [ ] **Performance**
  - [ ] App startup time
  - [ ] Memory usage
  - [ ] Battery consumption
  - [ ] Network efficiency

## 📈 Monitoring and Analytics

### Firebase Analytics

```dart
// Initialize Firebase Analytics
await Firebase.initializeApp();
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

// Track events
await FirebaseAnalytics.instance.logEvent(
  name: 'user_login',
  parameters: {
    'method': 'phone',
  },
);
```

### Crash Reporting

```dart
// Initialize Firebase Crashlytics
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

// Report errors
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'User action failed',
);
```

## 🔄 Update Strategy

### Version Management

```yaml
# pubspec.yaml
version: 1.0.0+1  # version_name+version_code
```

### Update Process

1. **Development**
   - Create feature branch
   - Implement changes
   - Test thoroughly

2. **Staging**
   - Deploy to test environment
   - Internal testing
   - Bug fixes

3. **Production**
   - Deploy to production
   - Monitor performance
   - Gather user feedback

4. **Rollback Plan**
   - Keep previous version ready
   - Monitor error rates
   - Quick rollback if needed

---

This deployment guide ensures a smooth and secure deployment process for the Romantic Hearts app across all platforms.
