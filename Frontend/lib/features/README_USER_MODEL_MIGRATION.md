# User Model Migration Guide

## 🎯 **Overview**

This document outlines the migration from three separate user models to a unified `UserProfile` model in the shared directory. This consolidation eliminates code duplication, improves data consistency, and simplifies maintenance.

## 📊 **Current State Analysis**

### **Before Migration: Three Separate Models**

1. **`UserProfileModel`** (Profile Feature)
   - ✅ Most complete with all fields
   - ✅ Has copyWith() method
   - ❌ Only used in profile feature
   - ❌ Duplicates shared functionality

2. **`UserProfile`** (Shared)
   - ✅ Used across features
   - ❌ Missing important fields (email, phoneNumber, timestamps)
   - ❌ No copyWith() method
   - ❌ Limited functionality

3. **`SuperLoverData`** (Core)
   - ✅ Specialized Super Lover data
   - ❌ Fragmented from main user model
   - ❌ Requires separate handling

### **After Migration: Unified Model**

1. **`UserProfile`** (Shared) - **Single Source of Truth**
   - ✅ All fields from all three models
   - ✅ copyWith() method for partial updates
   - ✅ Convenience methods and getters
   - ✅ Profile completion percentage
   - ✅ Super Lover integration
   - ✅ Used across all features

2. **Specialized Request/Response Models** (Core)
   - ✅ API-specific models
   - ✅ Clean separation of concerns
   - ✅ No duplication

## 🚀 **Migration Benefits**

### **1. Code Consistency**
- **Single model** across all features
- **Consistent field names** and types
- **Unified validation** and serialization

### **2. Reduced Maintenance**
- **One model to update** instead of three
- **Eliminated code duplication**
- **Simplified testing**

### **3. Better Data Flow**
- **Profile updates** immediately reflect everywhere
- **No data synchronization** issues
- **Consistent state management**

### **4. Enhanced Functionality**
- **Profile completion tracking**
- **Super Lover status helpers**
- **Rich convenience methods**

## 📋 **Migration Steps**

### **Step 1: Update Shared UserProfile Model**

The unified `UserProfile` model is now available in `shared/models/user_profile.dart` with:

```dart
// All fields from previous models
final String id, name, fullName, email, phoneNumber;
final int age;
final String gender, location, bio, image, lastSeen;
final String? photoUrl;
final bool online, isVerified, isSuperLover;
final DateTime createdAt, updatedAt;

// Super Lover fields
final String? superLoverStatus, superLoverBio;
final double? superLoverRating;
final int? superLoverCallCount, superLoverTotalEarnings;
final DateTime? superLoverJoinedAt;

// Convenience methods
bool get hasSuperLoverData => isSuperLover && superLoverStatus != null;
bool get isSuperLoverOnline => isSuperLover && superLoverStatus == 'online';
double get profileCompletionPercentage => /* calculation */;
```

### **Step 2: Update Service Layer**

#### **Before:**
```dart
// ProfileService used UserProfileModel
Future<UserProfileModel> getCurrentUserProfile() async {
  final userProfile = await UserService.getCurrentUserProfile();
  return userProfile;
}
```

#### **After:**
```dart
// ProfileService uses unified UserProfile
Future<UserProfile> getCurrentUserProfile() async {
  final userProfile = await UserService.getCurrentUserProfile();
  return userProfile;
}
```

### **Step 3: Update UI Components**

#### **Before:**
```dart
// Profile screens used UserProfileModel
UserProfileModel? _userProfile;
final profile = await _profileService.getCurrentUserProfile();
```

#### **After:**
```dart
// All screens use unified UserProfile
UserProfile? _userProfile;
final profile = await _profileService.getCurrentUserProfile();
```

### **Step 4: Update Cross-Feature Usage**

#### **Before:**
```dart
// Calls/Messaging used basic UserProfile
final UserProfile caller;
final UserProfile recipient;
```

#### **After:**
```dart
// All features use rich UserProfile
final UserProfile caller; // Now has all fields
final UserProfile recipient; // Now has all fields
```

## 🔧 **Implementation Guide**

### **1. Update Imports**

Replace all imports from:
```dart
import '../models/user_profile_model.dart';
```

To:
```dart
import '../../../shared/models/user_profile.dart';
```

### **2. Update Type Declarations**

Replace all type declarations from:
```dart
UserProfileModel? _userProfile;
List<UserProfileModel> _users;
```

To:
```dart
UserProfile? _userProfile;
List<UserProfile> _users;
```

### **3. Update Service Methods**

Update service method signatures:
```dart
// Before
static Future<UserProfileModel> getCurrentUserProfile() async

// After
static Future<UserProfile> getCurrentUserProfile() async
```

### **4. Update Widget Constructors**

Update widget constructors:
```dart
// Before
ProfileCardWidget({required UserProfileModel userProfile})

// After
ProfileCardWidget({required UserProfile userProfile})
```

## 🎨 **New Features Available**

### **1. Profile Completion Tracking**
```dart
final completion = userProfile.profileCompletionPercentage;
// Returns 0.0 to 1.0 based on filled fields
```

### **2. Super Lover Status Helpers**
```dart
if (userProfile.hasSuperLoverData) {
  // User has Super Lover information
}

if (userProfile.isSuperLoverOnline) {
  // Super Lover is currently online
}

if (userProfile.isSuperLoverReady) {
  // Super Lover is ready for calls
}
```

### **3. Rich Partial Updates**
```dart
final updatedProfile = userProfile.copyWith(
  name: 'New Name',
  bio: 'Updated bio',
  superLoverStatus: 'online',
);
```

### **4. Unified Data Flow**
```dart
// Profile update immediately reflects everywhere
await profileService.updateProfile(data);
// All features now see the updated data
```

## 🧪 **Testing Strategy**

### **1. Unit Tests**
```dart
test('UserProfile should calculate completion percentage correctly', () {
  final profile = UserProfile(/* minimal data */);
  expect(profile.profileCompletionPercentage, lessThan(1.0));
  
  final completeProfile = UserProfile(/* complete data */);
  expect(completeProfile.profileCompletionPercentage, equals(1.0));
});
```

### **2. Integration Tests**
```dart
test('Profile update should reflect in all features', () async {
  // Update profile
  final updatedProfile = await profileService.updateProfile(data);
  
  // Verify it's available in calls
  final callUser = await callService.getUser(updatedProfile.id);
  expect(callUser.name, equals(updatedProfile.name));
  
  // Verify it's available in messaging
  final messageUser = await messagingService.getUser(updatedProfile.id);
  expect(messageUser.name, equals(updatedProfile.name));
});
```

## 🚨 **Breaking Changes**

### **1. Constructor Changes**
- `UserProfile` now requires `email`, `phoneNumber`, `createdAt`, `updatedAt`
- Update all direct instantiations

### **2. Method Signature Changes**
- Service methods now return `UserProfile` instead of `UserProfileModel`
- Update all calling code

### **3. Field Access Changes**
- Some field names may have changed
- Update all field references

## 📈 **Performance Impact**

### **Positive Impacts:**
- **Reduced memory usage** (one model instead of three)
- **Faster serialization** (unified format)
- **Better caching** (single data source)

### **Considerations:**
- **Larger model size** (more fields)
- **Initial migration effort** (one-time cost)

## 🔮 **Future Enhancements**

### **1. Validation Layer**
```dart
class UserProfileValidator {
  static bool isValid(UserProfile profile) {
    // Validation logic
  }
}
```

### **2. Caching Strategy**
```dart
class UserProfileCache {
  static UserProfile? getCached(String userId);
  static void setCached(UserProfile profile);
}
```

### **3. Real-time Updates**
```dart
class UserProfileStream {
  static Stream<UserProfile> watchUser(String userId);
}
```

## ✅ **Migration Checklist**

- [ ] Update shared `UserProfile` model
- [ ] Remove `UserProfileModel` from profile feature
- [ ] Update all service method signatures
- [ ] Update all widget constructors
- [ ] Update all type declarations
- [ ] Update all imports
- [ ] Test profile updates across features
- [ ] Test Super Lover functionality
- [ ] Update unit tests
- [ ] Update integration tests
- [ ] Verify data consistency
- [ ] Performance testing
- [ ] Documentation updates

## 🎉 **Conclusion**

The unified `UserProfile` model provides a solid foundation for the application's user data management. This migration eliminates code duplication, improves data consistency, and sets the stage for future enhancements.

**Key Benefits:**
- ✅ **Single source of truth** for user data
- ✅ **Consistent data flow** across features
- ✅ **Reduced maintenance** overhead
- ✅ **Enhanced functionality** with convenience methods
- ✅ **Better testing** and validation capabilities

**Next Steps:**
1. Complete the migration following this guide
2. Implement validation layer
3. Add caching strategy
4. Consider real-time updates
5. Monitor performance and optimize as needed
