import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Suggestion {
  String? suggestionId;
  String? userId;
  User? user;
  String? suggestion;
  DateTime? sentAt;

  Suggestion({
    this.suggestionId,
    required this.userId,
    required this.user,
    required this.suggestion,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (suggestionId != null) 'suggestionId': suggestionId,
      if (userId != null) 'userId': userId,
      if (user != null) 'user': user!.toJson(),
      if (suggestion != null) 'suggestion': suggestion,
      if (sentAt != null) 'sentAt': Timestamp.fromDate(sentAt!),
    };
  }
}
