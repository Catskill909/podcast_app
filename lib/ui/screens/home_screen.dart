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
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Logo', style: TextStyle(color: Colors.white)),
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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Podcasts',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: podcasts.length,
                    itemBuilder: (context, index) {
                      final podcast = podcasts[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.15 * 255).toInt()),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/podcast',
                                arguments: podcast,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(12),
                                    shadowColor: Colors.black.withAlpha((0.15 * 255).toInt()),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white24, width: 1.2),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.black,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: (podcast.imageUrl.isNotEmpty)
                                            ? Image.network(
                                                podcast.imageUrl,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/images/pacifica-news.png',
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          podcast.title,
                                          key: ValueKey(podcast.title),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          podcast.author,
                                          key: ValueKey(podcast.author),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
