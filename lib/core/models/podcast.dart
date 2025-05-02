import 'episode.dart';

class Podcast {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String description;
  final List<Episode> episodes;

  // KPFA & iTunes fields
  final String? subtitle;
  final String? summary;
  final String? language;
  final String? copyright;
  final String? category;
  final String? explicitTag;

  Podcast({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
    required this.episodes,
    this.subtitle,
    this.summary,
    this.language,
    this.copyright,
    this.category,
    this.explicitTag,
  });
}
