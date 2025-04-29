import 'package:flutter/material.dart';
import '../../core/models/podcast.dart';

class PodcastDetailScreen extends StatelessWidget {
  final Podcast podcast;
  const PodcastDetailScreen({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(podcast.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(podcast.imageUrl),
              ),
            ),
            const SizedBox(height: 16),
            Text(podcast.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text('Episodes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: podcast.episodes.length,
                itemBuilder: (context, index) {
                  final episode = podcast.episodes[index];
                  return ListTile(
                    title: Text(episode.title),
                    subtitle: Text(episode.description),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/player',
                        arguments: episode,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
