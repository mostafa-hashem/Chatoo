class Friend {
  final String friendName;
  final String friendId;
  final String friendBio;
  final String friendPhoto;
  final List<String> friendMessages;

  Friend({
    required this.friendName,
    required this.friendId,
    required this.friendBio,
    required this.friendPhoto,
    required this.friendMessages,
  });

  Friend.fromJson(Map<String, dynamic> json)
      : this(
          friendName: json['friendName'] as String,
          friendId: json['friendId'] as String,
          friendBio: json['friendBio'] as String,
          friendPhoto: json['friendPhoto'] as String,
          friendMessages: (json['friendMessages'] as List)
              .map((friendMessages) => friendMessages as String)
              .toList(),
        );

  Map<String, dynamic> toJson() => {
        'friendName': friendName,
        'friendId': friendId,
        'friendBio': friendBio,
        'friendPhoto': friendPhoto,
        'friendMessages': friendMessages,
      };
}
