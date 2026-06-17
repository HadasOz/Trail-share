import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../providers/app_provider.dart';
import '../../services/firestore_service.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _firestoreService = FirestoreService();
  final _commentCtrl = TextEditingController();

  Future<void> _addComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final provider = context.read<AppProvider>();
    final comment = Comment(
      id: '',
      userId: user.uid,
      userName: provider.userName ?? 'משתמש',
      text: text,
      createdAt: DateTime.now(),
    );
    await _firestoreService.addComment(widget.post.id, comment);
    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isFav = provider.isFavorite(widget.post.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.post.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
            onPressed: () => provider.toggleFavorite(widget.post),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.post.imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: widget.post.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        if (widget.post.location.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(widget.post.location, style: const TextStyle(color: Colors.grey)),
                          ]),
                        ],
                        const SizedBox(height: 12),
                        Text(widget.post.description, style: TextStyle(fontSize: provider.fontSize, height: 1.5)),
                        const SizedBox(height: 16),
                        const Divider(),
                        const Text('תגובות', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        StreamBuilder<List<Comment>>(
                          stream: _firestoreService.getComments(widget.post.id),
                          builder: (_, snap) {
                            final comments = snap.data ?? [];
                            if (comments.isEmpty) return const Text('אין תגובות עדיין', style: TextStyle(color: Colors.grey));
                            return Column(
                              children: comments.map((c) => ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(c.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text(c.text),
                                contentPadding: EdgeInsets.zero,
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
          ),
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: InputDecoration(
                      hintText: 'הוסף תגובה...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
