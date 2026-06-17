class Post {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map, String id) => Post(
        id: id,
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        location: map['location'] ?? '',
        createdAt: (map['createdAt']?.toDate()) ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'location': location,
        'createdAt': createdAt,
      };
}
