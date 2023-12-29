import 'package:chat_app/utils/data/models/address.dart';

class User {
  String? id;
  String? email;
  String? userName;
  String? bio;
  String? phoneNumber;
  String? profileImage;
  List<dynamic>? groups;
  List<dynamic>? friends;
  Address? address;

  User({
    required this.id,
    required this.email,
    required this.userName,
    this.bio = '',
    this.phoneNumber = '',
    this.profileImage = '',
    this.groups,
    this.friends,
    this.address,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    email = json['email'] as String?;
    userName = json['userName'] as String?;
    bio = json['bio'] as String?;
    phoneNumber = json['phoneNumber'] as String?;
    profileImage = json['profileImage'] as String?;
    if (json['address'] != null) {
      address = Address.fromJson(json['address'] as Map<String, dynamic>);
    }
    if (json['groups'] != null && json['groups'] is List<dynamic>)  {
      groups = json['groups'] as List<dynamic>;
    }
    if (json['friends'] != null && json['friends'] is List<dynamic>) {
      friends = json['friends'] as List<dynamic>;
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
      if (address != null) 'address': address?.toJson(),
      if (groups != null) 'groups': groups,
      if (friends != null) 'friends': friends,
    };
  }
}
