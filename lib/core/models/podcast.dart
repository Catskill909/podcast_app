import 'episode.dart';

class Podcast {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String description;
  final List<Episode> episodes;

  Podcast({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
    required this.episodes,
  });
}
