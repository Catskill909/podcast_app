import 'package:flutter/material.dart';
// ignore_for_file: prefer_const_constructors
import '../../core/services/podcast_api_service.dart';
import '../../core/models/podcast.dart';
import '../widgets/podcast_drawer.dart';

class HomeScreen extends StatelessWidget {
  final PodcastApiService apiService = PodcastApiService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 56,
              child: Image.asset(
                'assets/images/header.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Text('Logo', style: TextStyle(color: Colors.white)),
              ),
            ),
            Positioned(
              right: 0,
              child: SizedBox(width: 56), // matches default leading icon width
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      drawer: const PodcastDrawer(),
      body: FutureBuilder<List<Podcast>>(
        future: apiService.fetchPodcasts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final podcasts = snapshot.data!;
          return ListView.builder(
            itemCount: podcasts.length,
            itemBuilder: (context, index) {
              final podcast = podcasts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(podcast.imageUrl),
                ),
                title: Text(podcast.title, key: ValueKey(podcast.title)),
                subtitle: Text(podcast.author, key: ValueKey(podcast.author)),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/podcast',
                    arguments: podcast,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
