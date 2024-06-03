import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  String? id;
  String? storyTitle;
  String? userId;
  String? mediaUrl;
  String? fileName;
  DateTime? uploadedAt;
  Map<String, dynamic>? seen;

  Story({
    this.id,
    this.storyTitle,
    this.fileName,
    required this.userId,
    required this.mediaUrl,
    this.uploadedAt,
    this.seen,
  });

  Story.empty()
      : id = '',
        storyTitle = '',
        userId = '',
        mediaUrl = '',
        fileName = '',
        uploadedAt = Timestamp.now().toDate(),
        seen = {};

  Story.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = json['id'] as String;
    }
    if (json['storyTitle'] != null) {
      storyTitle = json['storyTitle'] as String?;
    }
    userId = json['userId'] as String;
    mediaUrl = json['mediaUrl'] as String;
    uploadedAt = (json['uploadedAt'] as Timestamp).toDate().toLocal();
    if (json['seen'] != null) {
      seen = (json['seen'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value as Timestamp),
      );
    } else {
      seen = {};
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fileName': fileName,
      if (storyTitle != null) 'storyTitle': storyTitle,
      'userId': userId,
      'mediaUrl': mediaUrl,
      'uploadedAt': Timestamp.now(),
      if (seen != null) 'seen': seen,
    };
  }
}
