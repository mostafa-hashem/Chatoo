class User {
  String? id;
  String? email;
  String? userName;
  String? bio;
  String? phoneNumber;
  String? profileImage;
  List<dynamic>? groups;
  List<dynamic>? friends;
  List<dynamic>? requests;
  String? city;
  String? fCMToken;
  bool? onLine;

  User({
    required this.id,
    required this.email,
    required this.userName,
    this.bio = '',
    this.phoneNumber = '',
    this.profileImage = '',
    this.fCMToken,
    this.groups,
    this.friends,
    this.requests,
    this.city = '',
    this.onLine = true,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    email = json['email'] as String?;
    userName = json['userName'] as String?;
    bio = json['bio'] as String?;
    phoneNumber = json['phoneNumber'] as String?;
    profileImage = json['profileImage'] as String?;
    if (json['fCMToken'] != null) {
      fCMToken = json['fCMToken'] as String?;
    }
    if (json['city'] != null) {
      city = json['city'] as String?;
    }
    if (json['groups'] != null && json['groups'] is List<dynamic>) {
      groups = json['groups'] as List<dynamic>;
    }
    if (json['friends'] != null && json['friends'] is List<dynamic>) {
      friends = json['friends'] as List<dynamic>;
    }
    if (json['requests'] != null && json['requests'] is List<dynamic>) {
      requests = json['requests'] as List<dynamic>;
    }
    if (json['onLine'] != null) {
      onLine = json['onLine'] as bool?;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'userName': userName,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      if (fCMToken != null) 'fCMToken': fCMToken,
      if (city != null) 'city': city,
      if (groups != null) 'groups': groups,
      if (friends != null) 'friends': friends,
      if (requests != null) 'requests': requests,
      if (onLine != null) 'onLine': onLine,
    };
  }
}
