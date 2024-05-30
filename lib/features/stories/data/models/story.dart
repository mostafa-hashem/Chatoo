import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  String? id;
  String? storyTitle;
  String? userId;
  String? mediaUrl;
  String? fileName;
  DateTime? uploadedAt;

  Story({
    this.id,
    this.storyTitle,
    this.fileName,
    required this.userId,
    required this.mediaUrl,
     this.uploadedAt,
  });

  Story.empty()
      : id = '',
        storyTitle = '',
        userId = '',
        mediaUrl = '',
        fileName = '',
        uploadedAt = DateTime.now().toLocal();

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
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fileName': fileName,
      if (storyTitle != null) 'storyTitle': storyTitle,
      'userId': userId,
      'mediaUrl': mediaUrl,
      'uploadedAt': Timestamp.fromDate(uploadedAt!).toDate().toLocal(),
    };
  }
}
