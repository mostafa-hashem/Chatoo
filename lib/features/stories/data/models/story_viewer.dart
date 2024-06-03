import 'package:cloud_firestore/cloud_firestore.dart';

class StoryViewer{
  String? userId;
  DateTime? viewAt;
  StoryViewer({
    this.userId,
    this.viewAt,
  });

  StoryViewer.empty()
      : userId = '',
        viewAt = Timestamp.now().toDate();

  StoryViewer.fromJson(Map<String, dynamic> json) {
    if (json['userId'] != null) {
      userId = json['userId'] as String?;
    }

    if (json['viewAt'] != null) {
      viewAt = (json['viewAt'] as Timestamp).toDate().toLocal();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      if (viewAt != null) 'viewAt': viewAt,
    };
  }
}
