import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/app_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/post_card.dart';
import '../../widgets/weather_widget.dart';
import '../detail/detail_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.terrain, color: Colors.white),
            SizedBox(width: 8),
            Text('Trail Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(provider.darkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
            onPressed: () => provider.setDarkMode(!provider.darkMode),
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: firestoreService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Offline mode - show favorites
            final favorites = provider.favorites;
            if (favorites.isEmpty) {
              return const Center(child: Text('אין חיבור לאינטרנט ואין מועדפים שמורים'));
            }
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('מצב לא מקוון - מציג מועדפים', style: TextStyle(color: Colors.orange)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (_, i) => PostCard(
                      post: favorites[i],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(post: favorites[i]))),
                    ),
                  ),
                ),
              ],
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('אין מסלולים עדיין. היה הראשון לשתף!'));
          }

          return ListView.builder(
            itemCount: posts.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return const WeatherWidget();
              final post = posts[i - 1];
              return PostCard(
                post: post,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(post: post))),
              );
            },
          );
        },
      ),
    );
  }
}
