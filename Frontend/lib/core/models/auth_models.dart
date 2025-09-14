class OtpResponse {
  final bool success;
  final String message;
  final String? otpId;
  final int? expiresIn;
  final String? phoneNumber;

  OtpResponse({
    required this.success,
    required this.message,
    this.otpId,
    this.expiresIn,
    this.phoneNumber,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      otpId: json['otpId'],
      expiresIn: json['expiresIn'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'otpId': otpId,
      'expiresIn': expiresIn,
      'phoneNumber': phoneNumber,
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;
  final String? userId;
  final UserData? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.userId,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? json['accessToken'],
      refreshToken: json['refreshToken'], // Will be null if backend doesn't provide it
      userId: json['userId'] ?? json['user']?['id'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
      'user': user?.toJson(),
    };
  }
}

class UserData {
  final String id;
  final String phoneNumber;
  final String? name;
  final bool isVerified;
  final String verificationStatus;
  final int profileCompletion;
  final DateTime createdAt;

  UserData({
    required this.id,
    required this.phoneNumber,
    this.name,
    required this.isVerified,
    required this.verificationStatus,
    required this.profileCompletion,
    required this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'],
      isVerified: json['isVerified'] ?? false,
      verificationStatus: json['verificationStatus'] ?? 'pending',
      profileCompletion: json['profileCompletion'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'profileCompletion': profileCompletion,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ProfileResponse {
  final bool success;
  final String message;
  final ProfileData? profile;
  final String? accessToken;
  final String? refreshToken;

  ProfileResponse({
    required this.success,
    required this.message,
    this.profile,
    this.accessToken,
    this.refreshToken,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      profile: json['profile'] != null ? ProfileData.fromJson(json['profile']) : null,
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'profile': profile?.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class ProfileData {
  final String id;
  final String phoneNumber;
  final String name;
  final String? email;
  final String? profileImage;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? location;
  final bool isVerified;
  final bool isSuperLover;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProfileData({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.email,
    this.profileImage,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.location,
    required this.isVerified,
    required this.isSuperLover,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      profileImage: json['profileImage'],
      bio: json['bio'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      gender: json['gender'],
      location: json['location'],
      isVerified: json['isVerified'] ?? false,
      isSuperLover: json['isSuperLover'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'location': location,
      'isVerified': isVerified,
      'isSuperLover': isSuperLover,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class LogoutResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  LogoutResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
