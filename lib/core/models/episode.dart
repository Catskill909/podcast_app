import 'package:hive/hive.dart';
part 'episode.g.dart';

@HiveType(typeId: 1)
class Episode {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String audioUrl;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final Duration duration; // Make sure DurationAdapter is registered in main.dart: Hive.registerAdapter(DurationAdapter());
  @HiveField(5)
  final String podcastImageUrl;
  @HiveField(6)
  final String imageUrl;

  // KPFA & iTunes fields
  @HiveField(7)
  final String? summary;
  @HiveField(8)
  final String? contentHtml;
  @HiveField(9)
  final int? audioLength;
  @HiveField(10)
  final String? audioType;
  @HiveField(11)
  final DateTime? pubDate;
  @HiveField(12)
  final String? explicitTag;

  const Episode({
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
