class Episode {
  final String id;
  final String title;
  final String audioUrl;
  final String description;
  final Duration duration;
  final String podcastImageUrl;

  Episode({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.description,
    required this.duration,
    required this.podcastImageUrl,
  });
}
