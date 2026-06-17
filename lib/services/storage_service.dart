import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadPostImage(File file, String userId) =>
      uploadImage(file, 'posts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

  Future<String> uploadProfileImage(File file, String userId) =>
      uploadImage(file, 'profiles/$userId.jpg');
}
