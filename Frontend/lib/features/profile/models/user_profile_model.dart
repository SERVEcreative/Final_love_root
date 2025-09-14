class UserProfileModel {
  final String id;
  final String name;
  final String fullName;
  final int age;
  final String gender;
  final String location;
  final String bio;
  final String image;
  final String? photoUrl;
  final bool online;
  final String lastSeen;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final bool isSuperLover;
  final String? superLoverStatus; // 'online', 'ready', 'offline'
  final String? superLoverBio;
  final double? superLoverRating;
  final int? superLoverCallCount;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.location,
    required this.bio,
    required this.image,
    this.photoUrl,
    required this.online,
    required this.lastSeen,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.isSuperLover = false,
    this.superLoverStatus,
    this.superLoverBio,
    this.superLoverRating,
    this.superLoverCallCount,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      fullName: map['fullName'] ?? map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      location: map['location'] ?? '',
      bio: map['bio'] ?? '',
      image: map['image'] ?? '',
      photoUrl: map['photoUrl'],
      online: map['online'] ?? false,
      lastSeen: map['lastSeen'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      isVerified: map['isVerified'] ?? false,
      isSuperLover: map['isSuperLover'] ?? false,
      superLoverStatus: map['superLoverStatus'],
      superLoverBio: map['superLoverBio'],
      superLoverRating: map['superLoverRating']?.toDouble(),
      superLoverCallCount: map['superLoverCallCount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'location': location,
      'bio': bio,
      'image': image,
      'photoUrl': photoUrl,
      'online': online,
      'lastSeen': lastSeen,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
      'isSuperLover': isSuperLover,
      'superLoverStatus': superLoverStatus,
      'superLoverBio': superLoverBio,
      'superLoverRating': superLoverRating,
      'superLoverCallCount': superLoverCallCount,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? fullName,
    int? age,
    String? gender,
    String? location,
    String? bio,
    String? image,
    String? photoUrl,
    bool? online,
    String? lastSeen,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isSuperLover,
    String? superLoverStatus,
    String? superLoverBio,
    double? superLoverRating,
    int? superLoverCallCount,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      image: image ?? this.image,
      photoUrl: photoUrl ?? this.photoUrl,
      online: online ?? this.online,
      lastSeen: lastSeen ?? this.lastSeen,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isSuperLover: isSuperLover ?? this.isSuperLover,
      superLoverStatus: superLoverStatus ?? this.superLoverStatus,
      superLoverBio: superLoverBio ?? this.superLoverBio,
      superLoverRating: superLoverRating ?? this.superLoverRating,
      superLoverCallCount: superLoverCallCount ?? this.superLoverCallCount,
    );
  }

  @override
  String toString() {
    return 'UserProfileModel(id: $id, name: $name, fullName: $fullName, age: $age, gender: $gender, location: $location, bio: $bio, image: $image, photoUrl: $photoUrl, online: $online, lastSeen: $lastSeen, email: $email, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileModel &&
        other.id == id &&
        other.name == name &&
        other.fullName == fullName &&
        other.age == age &&
        other.gender == gender &&
        other.location == location &&
        other.bio == bio &&
        other.image == image &&
        other.photoUrl == photoUrl &&
        other.online == online &&
        other.lastSeen == lastSeen &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        fullName.hashCode ^
        age.hashCode ^
        gender.hashCode ^
        location.hashCode ^
        bio.hashCode ^
        image.hashCode ^
        photoUrl.hashCode ^
        online.hashCode ^
        lastSeen.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
