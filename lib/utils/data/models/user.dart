import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? id;
  String? email;
  String? userName;
  String? bio;
  String? phoneNumber;
  String? profileImage;
  List<dynamic>? groups;
  List<dynamic>? friends;
  List<dynamic>? mutedGroups;
  List<dynamic>? mutedFriends;
  List<dynamic>? requests;
  List<dynamic>? stories;
  String? city;
  String? fCMToken;
  bool? onLine;
  DateTime? lastSeen;

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
    this.stories,
    this.requests,
    this.lastSeen,
    this.city = '',
    this.onLine = true,
  });

  User.empty()
      : id = '',
        email = '',
        userName = '',
        bio = "",
        phoneNumber = '',
        profileImage = '',
        fCMToken = '',
        groups = [],
        friends = [],
        stories = [],
        requests = [],
        lastSeen = DateTime.now().toLocal(),
        city = '',
        onLine = false;

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
    if (json['stories'] != null && json['stories'] is List<dynamic>) {
      stories = json['stories'] as List<dynamic>;
    }
    if (json['groups'] != null && json['groups'] is List<dynamic>) {
      groups = json['groups'] as List<dynamic>;
    }
    if (json['friends'] != null && json['friends'] is List<dynamic>) {
      friends = json['friends'] as List<dynamic>;
    }
    if (json['mutedGroups'] != null && json['mutedGroups'] is List<dynamic>) {
      mutedGroups = json['mutedGroups'] as List<dynamic>;
    }
    if (json['mutedFriends'] != null && json['mutedFriends'] is List<dynamic>) {
      mutedFriends = json['mutedFriends'] as List<dynamic>;
    }
    if (json['requests'] != null && json['requests'] is List<dynamic>) {
      requests = json['requests'] as List<dynamic>;
    }
    if (json['onLine'] != null) {
      onLine = json['onLine'] as bool?;
    }
    if (json['lastSeen'] != null) {
      lastSeen = (json['lastSeen'] as Timestamp?)?.toDate().toLocal();
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
      if (stories != null) 'stories': stories,
      if (groups != null) 'groups': groups,
      if (friends != null) 'friends': friends,
      if (mutedGroups != null) 'mutedGroups': mutedGroups,
      if (mutedFriends != null) 'mutedFriends': mutedFriends,
      if (requests != null) 'requests': requests,
      if (onLine != null) 'onLine': onLine,
      if (lastSeen != null) 'lastSeen': lastSeen,
    };
  }
}
