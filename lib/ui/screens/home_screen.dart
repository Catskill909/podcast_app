import 'package:flutter/material.dart';
import '../../core/services/podcast_api_service.dart';
import '../../core/models/podcast.dart';

class HomeScreen extends StatelessWidget {
  final PodcastApiService apiService = PodcastApiService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcasts')),
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
                    backgroundImage: NetworkImage(podcast.imageUrl)),
                title: Text(podcast.title),
                subtitle: Text(podcast.author),
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
