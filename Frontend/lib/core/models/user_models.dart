// Specialized request models for API calls
class ProfileUpdateRequest {
  final String? name;
  final String? email;
  final int? age;
  final String? gender;
  final String? location;
  final String? bio;
  final String? profileImage;

  ProfileUpdateRequest({
    this.name,
    this.email,
    this.age,
    this.gender,
    this.location,
    this.bio,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (age != null) data['age'] = age;
    if (gender != null) data['gender'] = gender;
    if (location != null) data['location'] = location;
    if (bio != null) data['bio'] = bio;
    if (profileImage != null) data['profileImage'] = profileImage;
    return data;
  }
}

class SuperLoverUpdateRequest {
  final String? status; // 'online', 'ready', 'offline'
  final String? bio;
  final double? rating;

  SuperLoverUpdateRequest({
    this.status,
    this.bio,
    this.rating,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (bio != null) data['bio'] = bio;
    if (rating != null) data['rating'] = rating;
    return data;
  }
}

class BlockUserRequest {
  final String userId;
  final String? reason;

  BlockUserRequest({
    required this.userId,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (reason != null) 'reason': reason,
    };
  }
}

class UserSearchRequest {
  final String? query;
  final String? gender;
  final int? minAge;
  final int? maxAge;
  final String? location;
  final bool? isSuperLover;
  final int? limit;
  final int? offset;

  UserSearchRequest({
    this.query,
    this.gender,
    this.minAge,
    this.maxAge,
    this.location,
    this.isSuperLover,
    this.limit,
    this.offset,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (query != null) data['query'] = query;
    if (gender != null) data['gender'] = gender;
    if (minAge != null) data['minAge'] = minAge;
    if (maxAge != null) data['maxAge'] = maxAge;
    if (location != null) data['location'] = location;
    if (isSuperLover != null) data['isSuperLover'] = isSuperLover;
    if (limit != null) data['limit'] = limit;
    if (offset != null) data['offset'] = offset;
    return data;
  }
}

// Response models for API responses
class UserListResponse {
  final List<Map<String, dynamic>> users;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  UserListResponse({
    required this.users,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      users: List<Map<String, dynamic>>.from(json['users'] ?? []),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      hasMore: json['hasMore'] ?? false,
    );
  }
}

class ProfileUpdateResponse {
  final Map<String, dynamic> user;
  final String message;
  final bool success;

  ProfileUpdateResponse({
    required this.user,
    required this.message,
    required this.success,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      user: json['user'] ?? {},
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }
}
