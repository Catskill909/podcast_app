class Episode {
  final String id;
  final String title;
  final String audioUrl;
  final String description;
  final Duration duration;
  final String podcastImageUrl;

  // KPFA & iTunes fields
  final String? summary;
  final String? contentHtml;
  final String? imageUrl;
  final int? audioLength;
  final String? audioType;
  final DateTime? pubDate;
  final String? explicitTag;

  Episode({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.description,
    required this.duration,
    required this.podcastImageUrl,
    this.summary,
    this.contentHtml,
    this.imageUrl,
    this.audioLength,
    this.audioType,
    this.pubDate,
    this.explicitTag,
  });
}
