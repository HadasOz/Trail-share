class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String id) => Comment(
        id: id,
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        text: map['text'] ?? '',
        createdAt: (map['createdAt']?.toDate()) ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'text': text,
        'createdAt': createdAt,
      };
}
