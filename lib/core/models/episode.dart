class Episode {
  final String id;
  final String title;
  final String audioUrl;
  final String description;
  final Duration duration;
  final String podcastImageUrl;
  final String imageUrl;

  // KPFA & iTunes fields
  final String? summary;
  final String? contentHtml;
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
    this.imageUrl = '',
    this.summary,
    this.contentHtml,
    this.audioLength,
    this.audioType,
    this.pubDate,
    this.explicitTag,
  });
}
