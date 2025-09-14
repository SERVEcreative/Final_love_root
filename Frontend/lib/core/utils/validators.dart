import '../constants/app_constants.dart';

class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters
    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length < AppConstants.minPhoneLength) {
      return 'Phone number must be at least ${AppConstants.minPhoneLength} digits';
    }
    
    if (cleanPhone.length > AppConstants.maxPhoneLength) {
      return 'Phone number must not exceed ${AppConstants.maxPhoneLength} digits';
    }
    
    return null;
  }
  
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != AppConstants.otpLength) {
      return 'OTP must be ${AppConstants.otpLength} digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }
  
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    
    return null;
  }
  
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    int? age = int.tryParse(value);
    if (age == null) {
      return 'Age must be a number';
    }
    
    if (age < 18) {
      return 'Age must be at least 18';
    }
    
    if (age > 100) {
      return 'Age must not exceed 100';
    }
    
    return null;
  }
  
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }
    
    if (value.length < 2) {
      return 'Location must be at least 2 characters';
    }
    
    return null;
  }
  
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    }
    
    if (value.length > 500) {
      return 'Bio must not exceed 500 characters';
    }
    
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    if (value.length > 50) {
      return 'Password must not exceed 50 characters';
    }
    
    return null;
  }
  
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}
