// ignore_for_file: prefer_const_constructors
import '../models/podcast.dart';
import '../models/episode.dart';

class PodcastApiService {
  // For now, returns mock data
  Future<List<Podcast>> fetchPodcasts() async {
    return [
      Podcast(
        id: '1',
        title: 'Minimalist Podcast',
        author: 'Jane Doe',
        imageUrl: 'https://picsum.photos/200',
        description: 'A podcast about minimalism.',
        episodes: [
          Episode(
            id: 'e1',
            title: 'Episode 1: Getting Started',
            audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            description: 'Introduction to minimalism.',
            duration: Duration(minutes: 30),
          ),
        ],
      ),
    ];
  }
}
