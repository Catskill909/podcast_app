import 'package:hive/hive.dart';
import 'episode.dart';
part 'podcast.g.dart';

@HiveType(typeId: 0)
class Podcast {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String author;
  @HiveField(3)
  final String imageUrl;
  @HiveField(4)
  final String description;
  @HiveField(5)
  final List<Episode> episodes;

  // KPFA & iTunes fields
  @HiveField(6)
  final String? subtitle;
  @HiveField(7)
  final String? summary;
  @HiveField(8)
  final String? language;
  @HiveField(9)
  final String? copyright;
  @HiveField(10)
  final String? category;
  @HiveField(11)
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

