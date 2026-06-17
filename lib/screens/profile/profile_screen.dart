import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post.dart';
import '../../providers/app_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/post_card.dart';
import '../detail/detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _authService = AuthService();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  File? _pickedImage;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _uploadPost() async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('מלא כותרת ותיאור')));
      return;
    }
    setState(() => _uploading = true);
    try {
      final provider = context.read<AppProvider>();
      final user = FirebaseAuth.instance.currentUser!;
      String imageUrl = '';
      if (_pickedImage != null) {
        imageUrl = await _storageService.uploadPostImage(_pickedImage!, user.uid);
      }
      final post = Post(
        id: '',
        userId: user.uid,
        userName: provider.userName ?? 'משתמש',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: imageUrl,
        location: _locationCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await _firestoreService.addPost(post);
      _titleCtrl.clear();
      _descCtrl.clear();
      _locationCtrl.clear();
      setState(() => _pickedImage = null);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('המסלול הועלה בהצלחה!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('שגיאה: $e')));
    }
    if (mounted) setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('פרופיל', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.logout();
              provider.clear();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              color: Colors.green[50],
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.green[200],
                    child: Text(
                      (provider.userName ?? 'מ')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.userName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            // Settings
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('הגדרות', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('מצב כהה'),
                          Switch(value: provider.darkMode, onChanged: provider.setDarkMode, activeColor: Colors.green),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('גודל גופן: '),
                          Expanded(
                            child: Slider(
                              value: provider.fontSize,
                              min: 12,
                              max: 20,
                              divisions: 4,
                              label: '${provider.fontSize.toInt()}',
                              activeColor: Colors.green,
                              onChanged: provider.setFontSize,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Add post form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('שתף מסלול חדש', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'כותרת המסלול', prefixIcon: Icon(Icons.terrain)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _locationCtrl,
                        decoration: const InputDecoration(labelText: 'מיקום', prefixIcon: Icon(Icons.location_on)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'תיאור המסלול', prefixIcon: Icon(Icons.description)),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(_pickedImage!, fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                    Text('הוסף תמונה', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _uploading ? null : _uploadPost,
                          icon: _uploading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.upload),
                          label: Text(_uploading ? 'מעלה...' : 'פרסם מסלול'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // User's posts
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('המסלולים שלי', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  StreamBuilder<List<Post>>(
                    stream: _firestoreService.getUserPosts(user.uid),
                    builder: (_, snap) {
                      final posts = snap.data ?? [];
                      if (posts.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('עדיין לא העלית מסלולים'));
                      return Column(
                        children: posts.map((p) => PostCard(
                          post: p,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(post: p))),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
