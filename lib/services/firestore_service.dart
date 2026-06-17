import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/comment.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Post>> getPosts() => _db
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Post.fromMap(d.data(), d.id)).toList());

  Future<void> addPost(Post post) => _db.collection('posts').add(post.toMap());

  Stream<List<Comment>> getComments(String postId) => _db
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((s) => s.docs.map((d) => Comment.fromMap(d.data(), d.id)).toList());

  Future<void> addComment(String postId, Comment comment) => _db
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .add(comment.toMap());

  Stream<List<Post>> getUserPosts(String userId) => _db
      .collection('posts')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Post.fromMap(d.data(), d.id)).toList());
}
