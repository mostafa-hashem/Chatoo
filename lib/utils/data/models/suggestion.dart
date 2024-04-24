import 'package:cloud_firestore/cloud_firestore.dart';

class Suggestion {
  String? suggestionId;
  String? userId;
  String? suggestion;
  DateTime? sentAt;

  Suggestion({
     this.suggestionId,
    required this.userId,
    required this.suggestion,
    required this.sentAt,
  });

  Suggestion.fromJson(Map<String, dynamic> json) {
    if (json['suggestionId'] != null) {
      suggestionId = json['suggestionId'] as String;
    }
    if (json['userId'] != null) {
      userId = json['userId'] as String;
    }
    if (json['suggestion'] != null) {
      suggestion = json['suggestion'] as String;
    }
    if (json['sentAt'] != null) {
      sentAt = (json['sentAt'] as Timestamp).toDate();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (suggestionId != null) 'suggestionId': suggestionId,
      if (userId != null) 'userId': userId,
      if (suggestion != null) 'suggestion': suggestion,
      if (sentAt != null) 'sentAt': Timestamp.fromDate(sentAt!),
    };
  }
}
