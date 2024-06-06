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
  DateTime? joinedAt;

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
    this.joinedAt,
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
        joinedAt = DateTime.now().toLocal(),
        city = '',
        onLine = false;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    email = json['email'] as String?;
    userName = json['userName'] as String?;
    bio = json['bio'] as String?;
    phoneNumber = json['phoneNumber'] as String?;
    profileImage = json['profileImage'] as String?;
    fCMToken = json['fCMToken'] as String?;
    city = json['city'] as String?;
    stories = json['stories'] as List<dynamic>?;
    groups = json['groups'] as List<dynamic>?;
    friends = json['friends'] as List<dynamic>?;
    mutedGroups = json['mutedGroups'] as List<dynamic>?;
    mutedFriends = json['mutedFriends'] as List<dynamic>?;
    requests = json['requests'] as List<dynamic>?;
    onLine = json['onLine'] as bool?;

    if (json['lastSeen'] != null) {
      if (json['lastSeen'] is Timestamp) {
        lastSeen = (json['lastSeen'] as Timestamp).toDate().toLocal();
      } else if (json['lastSeen'] is String) {
        lastSeen = DateTime.parse(json['lastSeen'] as String).toLocal();
      }
    }
    if (json['joinedAt'] != null) {
      if (json['joinedAt'] is Timestamp) {
        joinedAt = (json['joinedAt'] as Timestamp).toDate().toLocal();
      } else if (json['joinedAt'] is String) {
        joinedAt = DateTime.parse(json['joinedAt'] as String).toLocal();
      }
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
      if (lastSeen != null) 'lastSeen': lastSeen?.toIso8601String(),
      if (joinedAt != null) 'joinedAt': DateTime.now().toIso8601String(),
    };
  }
}
